part of 'category_bloc.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object> get props => [];
}

class GetProducts extends CategoryEvent {
  final String? filter;

  const GetProducts({this.filter});

  @override
  List<Object> get props => [filter ?? ''];
}
