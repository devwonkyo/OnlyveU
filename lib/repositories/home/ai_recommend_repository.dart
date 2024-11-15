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

  List<ProductModel>? _cachedProducts;
  DateTime? _lastFetchTime;
  static const cacheDuration = Duration(minutes: 30);

  /// 모든 상품 데이터를 Firestore에서 가져오거나 캐싱된 데이터를 반환
  Future<List<ProductModel>> _getAllProducts() async {
    // 캐시가 유효한 경우 캐시된 데이터 반환
    if (_cachedProducts != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < cacheDuration) {
      return _cachedProducts!;
    }

    try {
      // Firestore에서 상품 데이터 가져오기
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

  /// 사용자 행동 데이터를 AI가 사용할 수 있는 형식으로 변환
  Future<Map<String, dynamic>> getUserBehaviorForAI(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return {
          'viewHistory': <String>[],
          'likedItems': <String>[],
          'cartItems': <String>[],
        };
      }

      final userData = userDoc.data()!;

      // List<dynamic>을 List<String>으로 안전하게 변환
      List<String> convertToStringList(dynamic list) {
        if (list == null) return [];
        if (list is List) {
          return list.map((item) => item.toString()).toList();
        }
        return [];
      }

      // cartItems 처리를 위한 특별 변환 함수
      List<String> convertCartItems(dynamic cartItems) {
        if (cartItems == null) return [];
        if (cartItems is List) {
          return cartItems
              .map((item) {
                if (item is Map) {
                  return item['productId']?.toString() ?? '';
                }
                return item.toString();
              })
              .where((id) => id.isNotEmpty)
              .toList();
        }
        return [];
      }

      return {
        'viewHistory': convertToStringList(userData['viewHistory']),
        'likedItems': convertToStringList(userData['likedItems']),
        'cartItems': convertCartItems(userData['cartItems']),
      };
    } catch (e) {
      print('사용자 행동 데이터 가져오기 실패: $e');
      return {
        'viewHistory': <String>[],
        'likedItems': <String>[],
        'cartItems': <String>[],
      };
    }
  }

  /// AI 추천 시스템에 요청하여 추천 상품 받아오기
  Future<Map<String, dynamic>> _getAIRecommendations(
      List<ProductModel> allProducts, Map<String, dynamic> userData) async {
    try {
      // 사용자가 이미 상호작용한 상품 ID 목록 생성
      final List<String> interactedProducts = [
        ...List<String>.from(userData['viewHistory'] ?? []),
        ...List<String>.from(userData['likedItems'] ?? []),
        ...List<String>.from(userData['cartItems'] ?? []),
      ].toSet().toList(); // 중복 제거

      // 상호작용하지 않은 상품만 필터링
      final availableProducts = allProducts
          .where((p) =>
              p.productId.isNotEmpty &&
              !interactedProducts.contains(p.productId))
          .toList()
        ..sort((a, b) =>
            ((b.salesVolume * 0.4) + (b.rating * 0.3) + (b.visitCount * 0.3))
                .compareTo((a.salesVolume * 0.4) +
                    (a.rating * 0.3) +
                    (a.visitCount * 0.3)));

      // 상품 데이터를 직렬화 가능한 형태로 변환
      final productsForAI = availableProducts
          .take(100)
          .map((p) => {
                'id': p.productId,
                'name': p.name,
                'price': p.price.replaceAll(',', ''),
                'rating': p.rating,
                'salesVolume': p.salesVolume,
                'visitCount': p.visitCount,
                'brandName': p.brandName,
                'categoryId': p.categoryId,
                'discountPercent': p.discountPercent,
                'tagList': p.tagList,
              })
          .toList();

      // 사용자가 상호작용한 상품들의 상세 정보
      final interactedProductsDetails = allProducts
          .where((p) => interactedProducts.contains(p.productId))
          .map((p) => {
                'id': p.productId,
                'name': p.name,
                'categoryId': p.categoryId,
                'brandName': p.brandName,
                'tagList': p.tagList,
              })
          .toList();

      final requestBody = {
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': """
당신은 사용자 맞춤형 쇼핑 추천 AI입니다. JSON 형식으로만 응답하세요:
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
사용자의 상호작용 정보:
${jsonEncode(userData)}

사용자가 이미 본/관심/장바구니에 담은 상품들:
${jsonEncode(interactedProductsDetails)}

추천 가능한 새로운 상품 목록:
${jsonEncode(productsForAI)}

요청사항:
1. 사용자가 이미 본 상품, 관심상품, 장바구니에 담은 상품은 제외합니다.
2. 대신 이러한 상품들과 연관성이 높은 새로운 상품을 추천해주세요.
3. 연관성 판단 기준:
   - 같은 브랜드의 다른 상품
   - 같은 카테고리의 비슷한 가격대 상품
   - 비슷한 태그를 가진 상품
   - 같은 스타일/용도의 상품
4. 각 추천 상품에 대해 구체적인 추천 이유를 설명해주세요.

위 조건을 만족하는 10개의 상품을 추천해주세요."""
          }
        ],
        'temperature': 0.3,
        'max_tokens': 1000,
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
        return jsonDecode(content);
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

  /// 추천 상품 목록을 반환하는 메인 메서드
  Future<Map<String, dynamic>> getRecommendations() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('로그인이 필요합니다.');

      final allProducts = await _getAllProducts();
      final userData = await getUserBehaviorForAI(currentUser.uid);
      final rawRecommendations =
          await _getAIRecommendations(allProducts, userData);

      // API 응답 검증 및 타입 변환
      if (!rawRecommendations.containsKey('products') ||
          !rawRecommendations.containsKey('reasons')) {
        throw Exception('잘못된 추천 데이터 형식');
      }

      return {
        'products': rawRecommendations['products'],
        'reasons': rawRecommendations['reasons'] as Map<String, dynamic>
      };
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

  Future<List<ProductModel>> getAllProducts() async {
    return _getAllProducts();
  }
}
