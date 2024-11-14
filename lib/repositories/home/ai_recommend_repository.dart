import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:http/http.dart' as http;
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/models/user_model.dart';

class AIRecommendRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String openAIApiKey =
      FirebaseRemoteConfig.instance.getString('openai_api_key');

  Future<UserModel> _getUserData(String userId) async {
    // private로 변경
    try {
      print('Fetching user data for userId: $userId');
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        print('Creating new user data'); // 디버깅용
        // 기본 UserModel 생성
        return UserModel(
          uid: userId,
          email: FirebaseAuth.instance.currentUser?.email ?? '',
          nickname: FirebaseAuth.instance.currentUser?.displayName ?? '사용자',
          viewHistory: [],
          likedItems: [],
          cartItems: [],
          pickupItems: [],
        );
      }

      final data = userDoc.data();
      if (data == null) {
        throw Exception('사용자 데이터가 null입니다');
      }

      return UserModel.fromMap(data);
    } catch (e) {
      print('Error in getUserData: $e');
      throw Exception('사용자 데이터 로드 실패: $e');
    }
  }

  Future<Map<String, dynamic>> getUserBehaviorForAI(String userId) async {
    try {
      final user = await _getUserData(userId);
      return {
        'viewHistory': user.viewHistory,
        'likedItems': user.likedItems,
        'cartItems': user.cartItems.map((item) => item.productId).toList(),
      };
    } catch (e) {
      print('Error getting user behavior: $e');
      // 에러 발생 시 빈 데이터 반환
      return {
        'viewHistory': <String>[],
        'likedItems': <String>[],
        'cartItems': <String>[],
      };
    }
  }

  Future<Map<String, dynamic>> _getAIRecommendations(
      Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $openAIApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': '정확한 JSON 형식으로만 응답해주세요. 반드시 10개의 상품을 추천해주세요.'
            },
            {
              'role': 'user',
              'content': '''
              다음 사용자 데이터를 기반으로 10개의 상품을 추천해주세요:
              최근 본 상품: ${userData['viewHistory'].join(', ')}
              좋아요한 상품: ${userData['likedItems'].join(', ')}
              장바구니 상품: ${userData['cartItems'].join(', ')}
              
              다음 JSON 형식으로만 응답하세요:
              {
                "products": ["상품ID1", "상품ID2", "상품ID3", "상품ID4", "상품ID5", "상품ID6", "상품ID7", "상품ID8", "상품ID9", "상품ID10"],
                "reasons": {
                  "상품ID1": "추천이유1",
                  "상품ID2": "추천이유2",
                  "상품ID3": "추천이유3",
                  "상품ID4": "추천이유4",
                  "상품ID5": "추천이유5",
                  "상품ID6": "추천이유6",
                  "상품ID7": "추천이유7",
                  "상품ID8": "추천이유8",
                  "상품ID9": "추천이유9",
                  "상품ID10": "추천이유10"
                }
              }
              '''
            }
          ],
          'temperature': 0.3,
          'max_tokens': 1000, // 토큰 수도 늘림
        }),
      );

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        return jsonDecode(decodedResponse);
      } else {
        throw Exception('AI API 호출 실패 (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('AI 추천 요청 실패: $e');
    }
  }

  Future<List<ProductModel>> _fetchProductsByIds(
      List<String> productIds) async {
    try {
      final snapshots = await Future.wait(productIds
          .map((id) => _firestore.collection('products').doc(id).get()));

      return snapshots
          .where((snap) => snap.exists)
          .map((snap) => ProductModel.fromMap(snap.data()!))
          .toList();
    } catch (e) {
      throw Exception('상품 데이터 로드 실패: $e');
    }
  }

  Future<void> toggleFavorite(String productId, String userId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final userData = await userRef.get();

      if (!userData.exists) throw Exception('사용자를 찾을 수 없습니다');

      final user = UserModel.fromMap(userData.data()!);
      final likedItems = List<String>.from(user.likedItems);

      if (likedItems.contains(productId)) {
        likedItems.remove(productId);
      } else {
        likedItems.add(productId);
      }

      await userRef.update({'likedItems': likedItems});
    } catch (e) {
      throw Exception('즐겨찾기 업데이트 실패: $e');
    }
  }

  // 새로운 통합 메소드
  Future<Map<String, dynamic>> getRecommendations() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('로그인이 필요합니다');
      }

      print('Requesting recommendations for userId: ${currentUser.uid}');

      final userData = await getUserBehaviorForAI(currentUser.uid);
      final aiResponse = await _getAIRecommendations(userData);

      // 응답 체크 추가
      if (aiResponse == null ||
          !aiResponse.containsKey('choices') ||
          aiResponse['choices'].isEmpty ||
          !aiResponse['choices'][0].containsKey('message') ||
          !aiResponse['choices'][0]['message'].containsKey('content')) {
        throw Exception('AI 응답 형식이 올바르지 않습니다');
      }

      try {
        final content = aiResponse['choices'][0]['message']['content'];
        print('Raw content from AI: $content'); // 디버깅용

        final recommendations = jsonDecode(content);

        // 필수 키 체크
        if (!recommendations.containsKey('products') ||
            !recommendations.containsKey('reasons')) {
          throw Exception('AI 추천 데이터 형식이 올바르지 않습니다');
        }

        final List<String> productIds =
            List<String>.from(recommendations['products'] ?? []);
        final Map<String, String> reasons =
            Map<String, String>.from(recommendations['reasons'] ?? {});

        // 빈 결과 체크
        if (productIds.isEmpty) {
          throw Exception('추천할 상품이 없습니다');
        }

        final products = await _fetchProductsByIds(productIds);

        return {'products': products, 'reasons': reasons};
      } catch (parseError) {
        print('Error parsing AI response: $parseError');
        throw Exception('AI 응답 파싱 실패: $parseError');
      }
    } catch (e) {
      print('Error in getRecommendations: $e');
      throw Exception('추천 상품 로드 실패: $e');
    }
  }

  // 새로 추가된 실시간 사용자 활동 데이터 구독 메서드
  Stream<Map<String, int>> getUserActivityCountsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return {
          'viewCount': 0,
          'likeCount': 0,
          'cartCount': 0,
        };
      }

      try {
        final userData = UserModel.fromMap(snapshot.data()!);

        return {
          'viewCount': userData.viewHistory.length,
          'likeCount': userData.likedItems.length,
          'cartCount': userData.cartItems.length,
        };
      } catch (e) {
        print('Error parsing user activity counts: $e');
        return {
          'viewCount': 0,
          'likeCount': 0,
          'cartCount': 0,
        };
      }
    });
  }

  // 현재 로그인된 사용자의 활동 데이터 구독
  Stream<Map<String, int>> getCurrentUserActivityCountsStream() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // 로그인되지 않은 경우 빈 데이터 반환
      return Stream.value({
        'viewCount': 0,
        'likeCount': 0,
        'cartCount': 0,
      });
    }

    return getUserActivityCountsStream(currentUser.uid);
  }
}
