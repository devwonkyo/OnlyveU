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

  Future<List<ProductModel>> _getAllProducts() async {
    if (_cachedProducts != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < cacheDuration) {
      return _cachedProducts!;
    }

    try {
      print('Fetching all products from Firestore...');
      final snapshot = await _firestore.collection('products').get();
      _cachedProducts = snapshot.docs.map((doc) {
        final data = doc.data();
        data['productId'] = doc.id;
        return ProductModel.fromMap(data);
      }).toList();
      _lastFetchTime = DateTime.now();
      print('Fetched ${_cachedProducts!.length} products');
      return _cachedProducts!;
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('전체 상품 로드 실패: $e');
    }
  }

  Future<UserModel> _getUserData(String userId) async {
    try {
      print('Fetching user data for userId: $userId');
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        print('Creating new user data');
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
      return {
        'viewHistory': <String>[],
        'likedItems': <String>[],
        'cartItems': <String>[],
      };
    }
  }

  //여기가 핵심. AI 에게 물어보는곳
  Future<Map<String, dynamic>> _getAIRecommendations(
      List<ProductModel> allProducts, Map<String, dynamic> userData) async {
    try {
      print('=== Starting AI Recommendations ===');
      print('Total products available: ${allProducts.length}');
      print('User data received: $userData');

      // 1. 상품 정렬 및 필터링
      final topProducts = allProducts
          .where((p) => p.productId.isNotEmpty)
          .toList()
        ..sort((a, b) =>
            ((b.salesVolume * 0.4) + (b.rating * 0.3) + (b.visitCount * 0.3))
                .compareTo((a.salesVolume * 0.4) +
                    (a.rating * 0.3) +
                    (a.visitCount * 0.3)));

      print('Sorted products count: ${topProducts.length}');

      // 2. 상품 데이터 변환
      final productsData = topProducts
          .take(100)
          .map((product) => {
                'id': product.productId,
                'name': product.name,
                'brand': product.brandName,
                'category': product.categoryId,
                'price': int.tryParse(product.price.replaceAll(',', '')) ?? 0,
                'discount': product.discountPercent,
                'rating': product.rating,
                'popular': product.isPopular || product.isBest,
              })
          .toList();

      // 3. 사용자 데이터 정제
      final userHistory = {
        'viewHistory': (userData['viewHistory'] as List?)
                ?.take(5)
                .where((id) => id != null && id.toString().isNotEmpty)
                .toList() ??
            [],
        'likedItems': (userData['likedItems'] as List?)
                ?.take(5)
                .where((id) => id != null && id.toString().isNotEmpty)
                .toList() ??
            [],
        'cartItems': (userData['cartItems'] as List?)
                ?.take(5)
                .where((id) => id != null && id.toString().isNotEmpty)
                .toList() ??
            [],
      };

      // 4. API 요청 데이터 준비
      final userHistoryStr = """
최근 조회: ${jsonEncode(userHistory['viewHistory'])}
관심 상품: ${jsonEncode(userHistory['likedItems'])}
장바구니: ${jsonEncode(userHistory['cartItems'])}""";

      final productsDataStr = jsonEncode(productsData);

      print('Request data prepared');
      print('User history length: ${userHistoryStr.length}');
      print('Products data length: ${productsDataStr.length}');

      final requestBody = {
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': """
다음 형식의 JSON으로만 응답하세요:
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
다음 사용자의 구매 이력을 바탕으로 상품을 추천해주세요.

사용자 행동:
$userHistoryStr

가능한 상품 목록:
$productsDataStr

반드시 위 상품 목록에 있는 상품 ID만 사용하여 10개를 추천해주세요."""
          }
        ],
        'temperature': 0.3,
        'max_tokens': 800,
      };

      // 5. API 호출
      print('Calling OpenAI API...');
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $openAIApiKey',
        },
        body: jsonEncode(requestBody),
      );

      print('API Response status: ${response.statusCode}');

      // 6. 응답 처리
      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final responseData = jsonDecode(decodedResponse);

        print('Full API Response: $responseData');

        if (!responseData.containsKey('choices') ||
            responseData['choices'].isEmpty ||
            !responseData['choices'][0].containsKey('message') ||
            !responseData['choices'][0]['message'].containsKey('content')) {
          throw Exception('AI 응답 형식이 올바르지 않습니다');
        }

        final content = responseData['choices'][0]['message']['content'];
        print('AI Raw Response: $content');

        try {
          // 응답 문자열 전처리
          final cleanedContent = content
              .trim()
              .replaceAll(RegExp(r'```json\s*|\s*```'), '') // 코드 블록 제거
              .replaceAll(RegExp(r'[\u0000-\u001F]'), ''); // 제어 문자 제거

          print('Cleaned content: $cleanedContent');

          final parsedContent = jsonDecode(cleanedContent);

          if (!parsedContent.containsKey('products') ||
              !parsedContent.containsKey('reasons')) {
            print('Invalid content structure: $parsedContent');
            throw Exception('필수 필드가 누락되었습니다');
          }

          final products = List<String>.from(parsedContent['products']);
          final reasons = Map<String, String>.from(parsedContent['reasons']);

          // 반환 전 유효성 검사
          if (products.isEmpty || reasons.isEmpty) {
            throw Exception('추천 데이터가 비어있습니다');
          }

          print('Successfully parsed response');
          print('Products: $products');
          print('Reasons: $reasons');

          return {
            'products': products,
            'reasons': reasons,
          };
        } catch (e) {
          print('Error parsing content: $e');
          print('Problematic content: $content');
          throw Exception('응답 파싱 실패: $e');
        }
      } else {
        throw Exception(
            'AI API 호출 실패 (${response.statusCode}): ${response.body}');
      }
    } catch (e, stackTrace) {
      print('=== Error in AI recommendations ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      throw Exception('AI 추천 요청 실패: $e');
    }
  }

  Future<void> toggleFavorite(String productId, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
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
      });
    } catch (e) {
      throw Exception('즐겨찾기 업데이트 실패: $e');
    }
  }

  Future<Map<String, dynamic>> getRecommendations() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('로그인이 필요합니다');
      }

      print('Requesting recommendations for userId: ${currentUser.uid}');

      final allProducts = await _getAllProducts();
      final userData = await getUserBehaviorForAI(currentUser.uid);
      final recommendations =
          await _getAIRecommendations(allProducts, userData);

      if (!recommendations.containsKey('products') ||
          !recommendations.containsKey('reasons')) {
        throw Exception('AI 추천 데이터 형식이 올바르지 않습니다');
      }

      final List<String> recommendedIds =
          List<String>.from(recommendations['products'] ?? []);

      if (recommendedIds.isEmpty) {
        throw Exception('추천할 상품이 없습니다');
      }

      final recommendedProducts = allProducts
          .where((product) => recommendedIds.contains(product.productId))
          .toList();

      return {
        'products': recommendedProducts,
        'reasons': recommendations['reasons'] ?? {},
      };
    } catch (e) {
      print('Error in getRecommendations: $e');
      throw Exception('추천 상품 로드 실패: $e');
    }
  }

  Stream<Map<String, int>> getCurrentUserActivityCountsStream() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // 로그인하지 않은 경우 기본값 반환
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
        return {
          'viewCount': 0,
          'likeCount': 0,
          'cartCount': 0,
        };
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
