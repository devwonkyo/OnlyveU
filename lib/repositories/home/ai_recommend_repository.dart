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
          'Content-Type': 'application/json; charset=utf-8', // charset 추가
          'Authorization': 'Bearer $openAIApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content':
                  '당신은 e-commerce 추천 시스템입니다. 사용자의 행동 데이터를 기반으로 상품을 추천하고 추천 이유도 제공해주세요.'
            },
            {
              'role': 'user',
              'content': '''
              사용자의 행동 데이터:
              최근 본 상품: ${userData['viewHistory'].join(', ')}
              좋아요한 상품: ${userData['likedItems'].join(', ')}
              장바구니 상품: ${userData['cartItems'].join(', ')}
              
              이 사용자에게 적합한 상품 10개를 추천해주시고, 각 상품별로 추천 이유도 함께 알려주세요.
              다음 JSON 형식으로 응답해주세요:
              {
                "products": ["product_id1", "product_id2", ...],
                "reasons": {
                  "product_id1": "추천 이유 1",
                  "product_id2": "추천 이유 2"
                }
              }
            '''
            }
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        print('AI Response: ${response.body}'); // 디버깅용 로그 추가
        final decodedResponse = utf8.decode(response.bodyBytes); // utf8 디코딩 추가
        return jsonDecode(decodedResponse);
      } else {
        throw Exception('AI API 호출 실패: ${response.statusCode}');
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
    late final Map<String, dynamic> userData;
    late final Map<String, dynamic> aiResponse;
    late final String content;
    late final Map<String, dynamic> recommendations;

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('로그인이 필요합니다');
      }

      print('Requesting recommendations for userId: ${currentUser.uid}');

      userData = await getUserBehaviorForAI(currentUser.uid);
      aiResponse = await _getAIRecommendations(userData);

      content = aiResponse['choices'][0]['message']['content'];
      recommendations = jsonDecode(content);

      final List<String> productIds =
          List<String>.from(recommendations['products'] ?? []);
      final Map<String, String> reasons =
          Map<String, String>.from(recommendations['reasons'] ?? {});

      final products = await _fetchProductsByIds(productIds);

      return {'products': products, 'reasons': reasons};
    } catch (e) {
      print('Error in getRecommendations: $e');
      throw Exception('추천 상품 로드 실패: $e');
    }
  }
}
