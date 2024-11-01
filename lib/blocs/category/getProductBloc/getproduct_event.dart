part of 'getproduct_bloc.dart';

// get_product_event.dart
abstract class GetProductEvent extends Equatable {
  const GetProductEvent();

  @override
  List<Object> get props => [];
}

//main카테고리일 경우에만 true
class GetProducts extends GetProductEvent {
  final String? filter;
  final bool? isMainCategory;

  const GetProducts({this.filter, this.isMainCategory = false});

  @override
  List<Object> get props => [filter ?? '', isMainCategory ?? false];
}