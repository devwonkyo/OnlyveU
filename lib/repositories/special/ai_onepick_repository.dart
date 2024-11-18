import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:http/http.dart' as http;
import 'package:onlyveyou/models/product_model.dart';

class AIOnepickRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _openAIApiKey =
      FirebaseRemoteConfig.instance.getString('openai_api_key');
  List<Map<String, String>> _chatHistory = [];
  int _currentStep = 0;

  // 대화 단계 반환
  int get currentStep => _currentStep;

  // 대화 이력 반환
  List<Map<String, String>> get chatHistory => _chatHistory;

  // 대화 초기화
  void resetChat() {
    _chatHistory = [];
    _currentStep = 0;
  }

  /// 첫 인사 메시지 생성
  Future<String> startChat() async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAIApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': '''
당신은 화장품 전문가입니다. 사용자와의 첫 인사를 시작하세요.
- 친근하고 공감적인 톤을 유지하세요
- 사용자의 상황이나 목적을 물어보세요
- 예시: "안녕하세요! 어떤 상황을 위한 제품을 찾으시나요?"
'''
            }
          ],
          'temperature': 0.3,
          'max_tokens': 200,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final message = data['choices'][0]['message']['content'];

        // 대화 이력에 추가
        _chatHistory.add({
          'role': 'assistant',
          'content': message,
        });

        return message;
      } else {
        throw Exception('Failed to generate initial message');
      }
    } catch (e) {
      throw Exception('Error starting chat: $e');
    }
  }

  /// 사용자 메시지 처리 및 AI 응답 생성
  Future<String> handleUserMessage(String userMessage) async {
    try {
      // 사용자 메시지를 대화 이력에 추가
      _chatHistory.add({
        'role': 'user',
        'content': userMessage,
      });

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAIApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': '''
당신은 화장품 전문가입니다. 사용자와 5단계 대화를 통해 최적의 제품을 추천해주세요.
현재 대화 단계: ${_currentStep + 1}/5
- 친근하고 공감적인 톤을 유지하세요
- 이전 대화 내용을 참고하여 자연스럽게 대화하세요
- 각 답변에 대해 맥락에 맞는 후속 질문을 해주세요
- 마지막 5단계에서는 제품 추천을 위한 충분한 정보를 수집하세요
'''
            },
            ..._chatHistory,
          ],
          'temperature': 0.3,
          'max_tokens': 200,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final message = data['choices'][0]['message']['content'];

        // AI 응답을 대화 이력에 추가
        _chatHistory.add({
          'role': 'assistant',
          'content': message,
        });

        // 대화 단계 증가
        _currentStep++;

        return message;
      } else {
        throw Exception('Failed to generate chat response');
      }
    } catch (e) {
      throw Exception('Error handling message: $e');
    }
  }

  /// 대화 내용을 분석하여 제품 추천
  Future<Map<String, dynamic>> recommendProduct() async {
    try {
      // 1. OpenAI API로 대화 내용 분석
      final analysisResponse = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAIApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': '''
대화 내용을 분석하여 다음 정보를 JSON 형식으로 추출하세요:
{
  "situation": "상황 (ex: 면접, 데이트)",
  "skinType": "피부 타입",
  "concerns": ["주요 고민1", "주요 고민2"],
  "preferences": ["선호도1", "선호도2"],
  "priceRange": "가격대 범위"
}'''
            },
            ..._chatHistory,
          ],
          'temperature': 0.3,
          'max_tokens': 200,
        }),
      );

      if (analysisResponse.statusCode != 200) {
        throw Exception('Failed to analyze chat content');
      }

      final analysis = jsonDecode(
          jsonDecode(utf8.decode(analysisResponse.bodyBytes))['choices'][0]
              ['message']['content']);

      // 2. Firestore에서 제품 검색
      final productsQuery = await _firestore
          .collection('products')
          .where('isBest', isEqualTo: true) // 우선 베스트 상품 중에서 검색
          .get();

      final products = productsQuery.docs.map((doc) {
        final data = doc.data();
        data['productId'] = doc.id;
        return ProductModel.fromMap(data);
      }).toList();

      // 3. OpenAI로 최적의 제품 선택
      final recommendationResponse = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAIApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': '''
사용자의 요구사항과 제품 목록을 비교하여 가장 적합한 제품 하나를 선택하고,
추천 이유를 JSON 형식으로 반환하세요:
{
  "productId": "선택한 제품 ID",
  "reason": "추천 이유"
}'''
            },
            {
              'role': 'user',
              'content': '''
사용자 요구사항:
${jsonEncode(analysis)}

제품 목록:
${jsonEncode(products.map((p) => {
                        'id': p.productId,
                        'name': p.name,
                        'brand': p.brandName,
                        'price': p.price,
                        'tags': p.tagList,
                      }).toList())}
'''
            },
          ],
          'temperature': 0.3,
          'max_tokens': 200,
        }),
      );

      if (recommendationResponse.statusCode != 200) {
        throw Exception('Failed to get product recommendation');
      }

      final recommendation = jsonDecode(
          jsonDecode(utf8.decode(recommendationResponse.bodyBytes))['choices']
              [0]['message']['content']);

      // 4. 선택된 제품 정보 반환
      final selectedProduct = products.firstWhere(
        (p) => p.productId == recommendation['productId'],
        orElse: () => throw Exception('Selected product not found'),
      );

      return {
        'product': selectedProduct,
        'reason': recommendation['reason'],
      };
    } catch (e) {
      throw Exception('Error recommending product: $e');
    }
  }
}
