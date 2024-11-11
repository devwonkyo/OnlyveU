import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class SuggestionModel extends Equatable {
  final String term;
  final int popularity;
  final double trendScore; // 트렌드 점수 추가
  final String sourceCollection; // 데이터를 가져온 컬렉션을 표시하는 필드 추가

  const SuggestionModel({
    required this.term,
    this.popularity = 0,
    this.trendScore = 0.0,
    this.sourceCollection = '', // 기본값 설정
  });

  @override
  List<Object> get props => [term, popularity, trendScore, sourceCollection];

  @override
  String toString() =>
      'SuggestionModel(term: $term, popularity: $popularity, trendScore: $trendScore, sourceCollection: $sourceCollection)';

  factory SuggestionModel.fromMap(Map<String, dynamic> map) {
    return SuggestionModel(
      term: map['term'] ?? '',
      popularity: map['popularity'] ?? 0,
      trendScore: (map['trendScore'] is int)
          ? (map['trendScore'] as int).toDouble()
          : map['trendScore'] ?? 0.0,
      sourceCollection: map['sourceCollection'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'term': term,
      'popularity': popularity,
      'trendScore': trendScore,
      'sourceCollection': sourceCollection, // 새로운 필드 추가
    };
  }
}

class TrendCalculator {
  final FirebaseFirestore _firestore;

  TrendCalculator({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<double> calculateTrendScore(String term) async {
    // 지난 7일 동안의 인기도 데이터를 가져옵니다.
    final querySnapshot = await _firestore
        .collection('popularity')
        .where('term', isEqualTo: term)
        .orderBy('date', descending: true)
        .limit(7)
        .get();

    final List<int> popularityData = querySnapshot.docs
        .map((doc) => (doc.data() as Map)['popularity'] as int)
        .toList();

    if (popularityData.length < 2) {
      return 0.0; // 데이터가 부족하면 트렌드 점수를 0으로 설정
    }

    // 변화율을 계산합니다.
    double totalChangeRate = 0.0;
    for (int i = 1; i < popularityData.length; i++) {
      final changeRate =
          (popularityData[i] - popularityData[i - 1]) / popularityData[i - 1];
      totalChangeRate += changeRate;
    }

    // 평균 변화율을 트렌드 점수로 사용합니다.
    final trendScore = totalChangeRate / (popularityData.length - 1);
    return trendScore;
  }
}
