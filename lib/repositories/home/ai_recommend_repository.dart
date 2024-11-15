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

  /// 안전한 문자열 맵 변환기
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

  /// 안전한 상품 ID 리스트 변환기
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
        data['productId'] = doc.id;
        return ProductModel.fromMap(data);
      }).toList();

      _lastFetchTime = DateTime.now();
      return _cachedProducts!;
    } catch (e) {
      throw Exception('상품 데이터를 불러오는데 실패했습니다: $e');
    }
  }

  /// 사용자 행동 데이터를 가져오는 메서드
  Future<Map<String, List<String>>> getUserBehaviorForAI(String userId) async {
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
        if (list == null) return <String>[];
        if (list is List) {
          return list.map((item) => item.toString()).toList();
        }
        return <String>[];
      }

      List<String> convertCartItems(dynamic cartItems) {
        if (cartItems == null) return <String>[];
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
        return <String>[];
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
      List<ProductModel> allProducts,
      Map<String, List<String>> userData) async {
    try {
      final List<String> interactedProducts = <String>[
        ...List<String>.from(userData['viewHistory'] ?? []),
        ...List<String>.from(userData['likedItems'] ?? []),
        ...List<String>.from(userData['cartItems'] ?? []),
      ].toSet().toList();

      final availableProducts = allProducts
          .where((p) =>
              p.productId.isNotEmpty &&
              !interactedProducts.contains(p.productId))
          .toList()
        ..sort((a, b) => b.salesVolume.compareTo(a.salesVolume));

      final productsForAI = availableProducts
          .take(30)
          .map((p) => {
                'id': p.productId,
                'categoryId': p.categoryId,
                'brandName': p.brandName,
              })
          .toList();

      final interactedDetails = allProducts
          .where((p) => interactedProducts.contains(p.productId))
          .take(5)
          .map((p) => {
                'id': p.productId,
                'categoryId': p.categoryId,
                'brandName': p.brandName,
              })
          .toList();

      final requestBody = {
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': '''쇼핑 추천 AI입니다. 정확한 JSON 형식으로만 응답하세요:
{
"products":["id1","id2","id3"],
"reasons":{"id1":"simple reason","id2":"simple reason","id3":"simple reason"}
}'''
          },
          {
            'role': 'user',
            'content': '''최근 상품:
${jsonEncode(interactedDetails)}

추천 가능 상품:
${jsonEncode(productsForAI)}

위 정보로 10개 상품 추천'''
          }
        ],
        'temperature': 0.3,
        'max_tokens': 500,
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
        final content = decodedResponse['choices']?[0]?['message']?['content']
                ?.toString() ??
            '{}';

        try {
          final aiResponse = jsonDecode(content.trim());
          return {
            'products': _safelyParseProductIds(aiResponse['products']),
            'reasons': _safelyParseReasonMap(aiResponse['reasons']),
          };
        } catch (e) {
          print('JSON parsing failed: $e');
          return {
            'products': <String>[],
            'reasons': <String, String>{},
          };
        }
      } else {
        print('API call failed: ${response.statusCode}');
        return {
          'products': <String>[],
          'reasons': <String, String>{},
        };
      }
    } catch (e) {
      print('AI recommendation error: $e');
      return {
        'products': <String>[],
        'reasons': <String, String>{},
      };
    }
  }

  Future<Map<String, dynamic>> getRecommendations() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return {
          'products': <String>[],
          'reasons': <String, String>{},
        };
      }

      final allProducts = await getAllProducts();
      final userData = await getUserBehaviorForAI(currentUser.uid);
      final recommendations =
          await _getAIRecommendations(allProducts, userData);

      if (recommendations['products'].isEmpty) {
        print('Warning: No products were recommended');
      }

      return recommendations;
    } catch (e) {
      print('Recommendation error: $e');
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
