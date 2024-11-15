import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:http/http.dart' as http;
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/models/user_model.dart';

// 가중치 붙여서 100개 추린다음 AI 에게 100개 안에서 물어보기
// 내가 본거 관심 장바구니와 연관된거를 10개 추천 - 안본게 포함되어 있음
// 몇개는 내가 본거와 중복이지만 20개가 넘어가기 때문에
// 추천해주는 10개중 1,2개 섞여도 상관 없음

// AI 추천 관련 로직을 관리하는 Repository
class AIRecommendRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String openAIApiKey =
      FirebaseRemoteConfig.instance.getString('openai_api_key');

  List<ProductModel>? _cachedProducts;
  DateTime? _lastFetchTime;
  static const cacheDuration = Duration(minutes: 30);

  /// 모든 상품 데이터를 Firestore에서 가져오거나 캐싱된 데이터를 반환
  Future<List<ProductModel>> _getAllProducts() async {
    if (_cachedProducts != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < cacheDuration) {
      return _cachedProducts!;
    }

    try {
      final snapshot = await _firestore.collection('products').get();
      _cachedProducts = snapshot.docs.map((doc) {
        final data = doc.data();
        data['productId'] = doc.id; // 상품 ID를 데이터에 포함
        return ProductModel.fromMap(data);
      }).toList();
      _lastFetchTime = DateTime.now();
      return _cachedProducts!;
    } catch (e) {
      throw Exception('상품 데이터를 불러오는데 실패했습니다: $e');
    }
  }

  /// 특정 사용자 데이터를 Firestore에서 가져오거나 기본 데이터를 생성
  Future<UserModel> _getUserData(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
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
      if (data == null) throw Exception('사용자 데이터가 없습니다.');
      return UserModel.fromMap(data);
    } catch (e) {
      throw Exception('사용자 데이터를 불러오는데 실패했습니다: $e');
    }
  }

  /// 사용자 행동 데이터를 AI가 사용할 수 있는 형식으로 변환
  Future<Map<String, dynamic>> getUserBehaviorForAI(String userId) async {
    try {
      final user = await _getUserData(userId);
      return {
        'viewHistory': user.viewHistory,
        'likedItems': user.likedItems,
        'cartItems': user.cartItems.map((item) => item.productId).toList(),
      };
    } catch (e) {
      return {
        'viewHistory': <String>[],
        'likedItems': <String>[],
        'cartItems': <String>[],
      };
    }
  }

  /// OpenAI API를 호출하여 추천 결과를 반환
  Future<Map<String, dynamic>> _getAIRecommendations(
      List<ProductModel> allProducts, Map<String, dynamic> userData) async {
    try {
      final topProducts = allProducts
          .where((p) => p.productId.isNotEmpty)
          .toList()
        ..sort((a, b) =>
            ((b.salesVolume * 0.4) + (b.rating * 0.3) + (b.visitCount * 0.3))
                .compareTo((a.salesVolume * 0.4) +
                    (a.rating * 0.3) +
                    (a.visitCount * 0.3)));

      final requestBody = {
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': """
JSON 형식으로 응답하세요:
{
 "products": ["상품ID1", "상품ID2", ...],
 "reasons": {
   "상품ID1": "추천이유1",
   "상품ID2": "추천이유2"
 }
}"""
          },
          {
            'role': 'user',
            'content': """
사용자 행동:
${jsonEncode(userData)}

가능한 상품 목록:
${jsonEncode(topProducts.take(100).map((p) => {
                      'id': p.productId,
                      'name': p.name,
                      'price': int.tryParse(p.price.replaceAll(',', '')) ?? 0,
                      'rating': p.rating
                    }).toList())}

10개의 상품을 추천해주세요."""
          }
        ],
        'temperature': 0.3,
        'max_tokens': 800,
      };

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $openAIApiKey',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final content =
            decodedResponse['choices'][0]['message']['content'].trim();
        final aiResponse = jsonDecode(content) as Map<String, dynamic>;
        final recommendedProductIds =
            (aiResponse['products'] as List<dynamic>).cast<String>();

        final recommendedProducts = allProducts
            .where((p) => recommendedProductIds.contains(p.productId))
            .toList();

        return {
          'products': recommendedProducts,
          'reasons': Map<String, String>.from(aiResponse['reasons'] as Map),
        };
      } else {
        throw Exception('AI API 호출 실패: ${response.body}');
      }
    } catch (e) {
      throw Exception('AI 추천 요청 실패: $e');
    }
  }

  /// 사용자의 즐겨찾기 상태를 업데이트
  Future<void> toggleFavorite(String productId, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(userId);
        final userData = await userRef.get();

        if (!userData.exists) throw Exception('사용자 데이터가 없습니다.');

        final user = UserModel.fromMap(userData.data()!);
        final likedItems = List<String>.from(user.likedItems);

        // 즐겨찾기 상태를 토글
        if (likedItems.contains(productId)) {
          likedItems.remove(productId);
        } else {
          likedItems.add(productId);
        }

        await userRef.update({'likedItems': likedItems});
      });
    } catch (e) {
      throw Exception('즐겨찾기 업데이트 실패: $e');
    }
  }

  /// 추천 상품 목록을 반환
  Future<Map<String, dynamic>> getRecommendations() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('로그인이 필요합니다.');

      final allProducts = await _getAllProducts();
      final userData = await getUserBehaviorForAI(currentUser.uid);
      return await _getAIRecommendations(allProducts, userData);
    } catch (e) {
      throw Exception('추천 데이터를 불러오는데 실패했습니다: $e');
    }
  }

  /// 사용자 활동 데이터를 실시간으로 수신
  Stream<Map<String, int>> getCurrentUserActivityCountsStream() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Stream.value({
        'viewCount': 0,
        'likeCount': 0,
        'cartCount': 0,
      });
    }

    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return {'viewCount': 0, 'likeCount': 0, 'cartCount': 0};
      }
      final data = snapshot.data()!;
      return {
        'viewCount': (data['viewHistory'] as List?)?.length ?? 0,
        'likeCount': (data['likedItems'] as List?)?.length ?? 0,
        'cartCount': (data['cartItems'] as List?)?.length ?? 0,
      };
    });
  }
}
