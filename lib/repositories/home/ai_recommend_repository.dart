import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:http/http.dart' as http;
import 'package:onlyveyou/models/product_model.dart';

class AIRecommendRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _apiKey =
      FirebaseRemoteConfig.instance.getString('openai_api_key');

  Future<Map<String, dynamic>> getUserBehaviorData(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      print('Firestore userDoc exists: ${userDoc.exists}');

      if (!userDoc.exists) {
        return {
          'viewHistory': [],
          'likedItems': [],
          'cartItems': [],
        };
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final cartItems = (userData['cartItems'] as List<dynamic>?)
              ?.map((item) {
                if (item is Map<String, dynamic>) {
                  return item['productId'] as String;
                }
                return '';
              })
              .where((id) => id.isNotEmpty)
              .toList() ??
          [];

      return {
        'viewHistory': List<String>.from(userData['viewHistory'] ?? []),
        'likedItems': List<String>.from(userData['likedItems'] ?? []),
        'cartItems': userData['cartItems']
                ?.map((item) => item['productId'] as String)
                .toList() ??
            [],
      };
    } catch (e) {
      print('getUserBehaviorData error: $e');
      throw Exception('사용자 데이터 조회 실패: $e');
    }
  }

  Future<Map<String, dynamic>> getAIRecommendations(
      Map<String, dynamic> userData) async {
    try {
      print('User data for AI: $userData');
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $_apiKey',
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
                응답 형식은 아래와 같은 JSON 형식이어야 합니다:
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
          'max_tokens': 1000,
        }),
      );

      print('OpenAI API Response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('AI 추천 API 오류: ${response.statusCode}');
      }

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      final content =
          responseData['choices'][0]['message']['content'] as String;

      try {
        final recommendations = jsonDecode(content) as Map<String, dynamic>;
        print('Parsed recommendations: $recommendations');
        return recommendations;
      } catch (e) {
        print('JSON parsing error: $e');
        throw Exception('AI 응답 파싱 실패: $e');
      }
    } catch (e) {
      print('getAIRecommendations error: $e');
      throw Exception('AI 추천 처리 실패: $e');
    }
  }

  Future<List<ProductModel>> getRecommendedProducts(
      List<String> productIds) async {
    try {
      print('Fetching products for IDs: $productIds');
      if (productIds.isEmpty) return [];

      final chunks = <List<String>>[];
      for (var i = 0; i < productIds.length; i += 10) {
        chunks.add(productIds.sublist(
            i, i + 10 > productIds.length ? productIds.length : i + 10));
      }

      final products = <ProductModel>[];
      for (final chunk in chunks) {
        final snapshot = await _firestore
            .collection('products')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        products.addAll(snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data()))
            .toList());
      }

      print('Found ${products.length} products');
      return products;
    } catch (e) {
      print('getRecommendedProducts error: $e');
      throw Exception('추천 상품 조회 실패: $e');
    }
  }
}
