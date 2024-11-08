import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:onlyveyou/models/product_model.dart';

import '../../../../repositories/product_repository.dart';

part 'search_result_event.dart';
part 'search_result_state.dart';

class SearchResultBloc extends Bloc<SearchResultEvent, SearchResultState> {
  final ProductRepository productRepository;
  SearchResultBloc({required this.productRepository})
      : super(SearchResultInitial()) {
    on<FetchSearchResults>(_onFetchSearchResults);
  }

// 파이어스토어에 저장되어있는걸 검색함
  // Future<void> _onFetchSearchResults(
  //     FetchSearchResults event, Emitter<SearchResultState> emit) async {
  //   emit(SearchResultLoading());
  //   try {
  //     await Future.delayed(const Duration(seconds: 1));
  //     final products = await productRepository.search(event.query);
  //     emit(SearchResultLoaded(products));
  //   } catch (e) {
  //     emit(SearchResultError(e.toString()));
  //   }
  // }

  // 로컬에 저장한 후 검색함
  Future<void> _onFetchSearchResults(
      FetchSearchResults event, Emitter<SearchResultState> emit) async {
    emit(SearchResultLoading());
    try {
      final sanitizedText = event.query.replaceAll(
          RegExp(r'[^\p{L}\p{N}\s]+', unicode: true), ''); // 특수문자 제거
      await Future.delayed(const Duration(seconds: 1));
      final products = await productRepository.searchLocal(sanitizedText);
      if (products.isEmpty) {
        emit(SearchResultEmpty());
      } else {
        emit(SearchResultLoaded(products));
      }
    } catch (e) {
      emit(SearchResultError(e.toString()));
    }
  }
}
