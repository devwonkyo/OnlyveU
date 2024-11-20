import 'package:fpdart/fpdart.dart';

abstract interface class SearchProductRepository {
  Future<Either<String, String>> getProductByName({required String name});
  Future<Either<String, String>> getProductByBrend({required String brend});
  Future<Either<String, String>> getProductByCategory(
      {required String category});
  // 검색제품을 정렬없이 가져옴 => 로컬에서 정렬
}
