part of 'category_product_bloc.dart';

abstract class CategoryProductEvent extends Equatable {
  const CategoryProductEvent();

  @override
  List<Object> get props => [];
}

// main 카테 고리 일 경우 에만 true
class GetProducts extends CategoryProductEvent {
  final String? filter;
  final bool? isMainCategory;

  const GetProducts({this.filter, this.isMainCategory = false});

  @override
  List<Object> get props => [filter ?? '', isMainCategory ?? false];
}



