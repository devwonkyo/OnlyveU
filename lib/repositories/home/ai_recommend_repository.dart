import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:http/http.dart' as http;
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/models/user_model.dart';

class AIRecommendRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String openAIApiKey =
      FirebaseRemoteConfig.instance.getString('openai_api_key');

  Future<UserModel> getUserData(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('사용자 데이터 로드 실패: $e');
    }
  }

  Future<Map<String, dynamic>> getUserBehaviorForAI(String userId) async {
    final user = await getUserData(userId);
    return {
      'viewHistory': user.viewHistory,
      'likedItems': user.likedItems,
      'cartItems': user.cartItems.map((item) => item.productId).toList(),
    };
  }

  Future<Map<String, dynamic>> _getAIRecommendations(
      Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
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
                   "product_id2": "추천 이유 2",
                   ...
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
        return jsonDecode(response.body);
      } else {
        throw Exception('AI API 호출 실패');
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

  // 즐겨찾기 토글
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

  Future<(List<ProductModel>, Map<String, String>)> getRecommendedProducts(
      String userId) async {
    try {
      final userData = await getUserBehaviorForAI(userId);
      final aiResponse = await _getAIRecommendations(userData);

      final recommendations =
          jsonDecode(aiResponse['choices'][0]['message']['content']);

      final List<String> productIds =
          List<String>.from(recommendations['products']);
      final Map<String, String> reasons =
          Map<String, String>.from(recommendations['reasons']);

      final products = await _fetchProductsByIds(productIds);

      return (products, reasons);
    } catch (e) {
      throw Exception('추천 상품 로드 실패: $e');
    }
  }
}
