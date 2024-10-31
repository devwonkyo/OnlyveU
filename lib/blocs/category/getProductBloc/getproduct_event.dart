part of 'getproduct_bloc.dart';

// get_product_event.dart
abstract class GetProductEvent extends Equatable {
  const GetProductEvent();

  @override
  List<Object> get props => [];
}

class LoadProducts extends GetProductEvent {
  final String? filter;

  const LoadProducts({this.filter});

  @override
  List<Object> get props => [filter ?? ''];
}