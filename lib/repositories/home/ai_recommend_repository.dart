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

  /// API 응답에서 안전하게 문자열 맵으로 변환하는 유틸리티 메서드
  Map<String, String> _safelyParseReasonMap(dynamic rawReasons) {
    if (rawReasons == null) return {};

    try {
      if (rawReasons is Map) {
        return rawReasons.map((key, value) =>
            MapEntry(key.toString(), value?.toString() ?? '회원님 취향과 일치'));
      }
    } catch (e) {
      print('Reason map parsing error: $e');
    }
    return {};
  }

  /// API 응답에서 안전하게 상품 ID 리스트로 변환하는 유틸리티 메서드
  List<String> _safelyParseProductIds(dynamic rawProducts) {
    if (rawProducts == null) return [];

    try {
      if (rawProducts is List) {
        return rawProducts.map((item) => item.toString()).toList();
      }
    } catch (e) {
      print('Product IDs parsing error: $e');
    }
    return [];
  }

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
        data['productId'] = doc.id;
        return ProductModel.fromMap(data);
      }).toList();

      _lastFetchTime = DateTime.now();
      return _cachedProducts!;
    } catch (e) {
      throw Exception('상품 데이터를 불러오는데 실패했습니다: $e');
    }
  }

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

      List<String> convertToStringList(dynamic list) {
        if (list == null) return [];
        if (list is List) {
          return list.map((item) => item.toString()).toList();
        }
        return [];
      }

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

  Future<Map<String, dynamic>> _getAIRecommendations(
      List<ProductModel> allProducts, Map<String, dynamic> userData) async {
    try {
      final List<String> interactedProducts = [
        ...List<String>.from(userData['viewHistory'] ?? []),
        ...List<String>.from(userData['likedItems'] ?? []),
        ...List<String>.from(userData['cartItems'] ?? []),
      ].toSet().toList();

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
            'content': '''당신은 사용자 맞춤형 쇼핑 추천 AI입니다. 
반드시 아래와 같은 정확한 JSON 형식으로만 응답해야 합니다:

{
  "products": ["product_id_1", "product_id_2"],
  "reasons": {
    "product_id_1": "simple reason without quotes or special chars",
    "product_id_2": "simple reason without quotes or special chars"
  }
}

주의사항:
1. 모든 문자열은 쌍따옴표(")로 감싸야 합니다
2. 문자열 내부에 쌍따옴표(")를 사용하지 마세요
3. 특수문자나 줄바꿈을 사용하지 마세요
4. 추천 이유는 간단한 텍스트로만 작성하세요
5. 설명이나 부가 정보를 추가하지 마세요
6. 정확히 위 형식만 반환하세요'''
          },
          {
            'role': 'user',
            'content': '''사용자의 상호작용 정보:
${jsonEncode(userData)}

사용자가 이미 본/관심/장바구니에 담은 상품들:
${jsonEncode(interactedProductsDetails)}

추천 가능한 새로운 상품 목록:
${jsonEncode(productsForAI)}

위 정보를 바탕으로 10개의 상품을 추천해주세요. 반드시 지정된 JSON 형식으로만 응답하세요.'''
          }
        ],
        'temperature': 0.3,
        'max_tokens': 1000,
        'response_format': {'type': 'json_object'}
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
        String content = decodedResponse['choices']?[0]?['message']?['content']
                ?.toString() ??
            '{}';

        // 문자열 정리 (이스케이프 처리 제거)
        content = content.trim();

        // JSON 파싱 시도
        try {
          // 첫 번째 파싱 시도
          Map<String, dynamic> aiResponse = jsonDecode(content);
          return {
            'products': _safelyParseProductIds(aiResponse['products']),
            'reasons': _safelyParseReasonMap(aiResponse['reasons']),
          };
        } catch (e) {
          print('First JSON parsing attempt failed: $e');
          print('Content causing error: $content');

          try {
            // 백업 파싱: JSON 형식이 깨진 경우 정규식으로 추출 시도
            final productsMatch =
                RegExp(r'"products":\s*\[(.*?)\]').firstMatch(content);
            final reasonsMatch =
                RegExp(r'"reasons":\s*\{(.*?)\}').firstMatch(content);

            final products = productsMatch
                    ?.group(1)
                    ?.split(',')
                    .map((s) => s.trim().replaceAll('"', ''))
                    .where((s) => s.isNotEmpty)
                    .toList() ??
                [];

            final reasons = <String, String>{};
            if (reasonsMatch != null) {
              final reasonsStr = reasonsMatch.group(1) ?? '';
              final reasonPairs = reasonsStr.split(',');
              for (var pair in reasonPairs) {
                final parts = pair.split(':');
                if (parts.length == 2) {
                  final key = parts[0].trim().replaceAll('"', '');
                  final value = parts[1].trim().replaceAll('"', '');
                  if (key.isNotEmpty && value.isNotEmpty) {
                    reasons[key] = value;
                  }
                }
              }
            }

            if (products.isNotEmpty) {
              return {
                'products': products,
                'reasons': reasons,
              };
            }
          } catch (e2) {
            print('Backup parsing failed: $e2');
          }

          // 모든 파싱 시도가 실패한 경우 빈 결과 반환
          return {
            'products': <String>[],
            'reasons': <String, String>{},
          };
        }
      } else {
        print('API call failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('AI API 호출 실패: ${response.body}');
      }
    } catch (e) {
      print('AI recommendation error: $e');
      return {
        'products': <String>[],
        'reasons': <String, String>{},
      };
    }
  }

  Future<void> toggleFavorite(String productId, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(userId);
        final userData = await userRef.get();

        if (!userData.exists) throw Exception('사용자 데이터가 없습니다.');

        final user = UserModel.fromMap(userData.data()!);
        final likedItems = List<String>.from(user.likedItems);

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

  Future<Map<String, dynamic>> getRecommendations() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('로그인이 필요합니다.');

      final allProducts = await getAllProducts();
      final userData = await getUserBehaviorForAI(currentUser.uid);
      final rawRecommendations =
          await _getAIRecommendations(allProducts, userData);

      if (rawRecommendations['products'].isEmpty) {
        print('Warning: No products were recommended');
      }

      return rawRecommendations;
    } catch (e) {
      print('Recommendation error: $e');
      return {
        'products': <String>[],
        'reasons': <String, String>{},
      };
    }
  }

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
