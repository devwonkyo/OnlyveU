// today_sale_bloc.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/models/product_model.dart';

// Events
abstract class TodaySaleEvent {}

class LoadTodaySaleProducts extends TodaySaleEvent {}

class ShuffleProducts extends TodaySaleEvent {} // 시간 지나면 섞을려고

// States
abstract class TodaySaleState {}

class TodaySaleInitial extends TodaySaleState {}

class TodaySaleLoading extends TodaySaleState {}

class TodaySaleLoaded extends TodaySaleState {
  final List<ProductModel> products;

  TodaySaleLoaded(this.products);
}

class TodaySaleError extends TodaySaleState {
  final String message;

  TodaySaleError(this.message);
}

// BLoC
class TodaySaleBloc extends Bloc<TodaySaleEvent, TodaySaleState> {
  final FirebaseFirestore _firestore;

  TodaySaleBloc({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(TodaySaleInitial()) {
    on<LoadTodaySaleProducts>((event, emit) async {
      emit(TodaySaleLoading());
      try {
        final QuerySnapshot snapshot = await _firestore
            .collection('products')
            .where('discountPercent', isGreaterThanOrEqualTo: 40)
            .orderBy('discountPercent', descending: true)
            .get();

        final products = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['productId'] = doc.id;
          return ProductModel.fromMap(data);
        }).toList();

        emit(TodaySaleLoaded(products));
      } catch (e) {
        print('Error loading today sale products: $e');
        emit(TodaySaleError('특가 상품을 불러오는데 실패했습니다.'));
      }
    });
    // ShuffleProducts 이벤트 핸들러 추가
    on<ShuffleProducts>((event, emit) async {
      if (state is TodaySaleLoaded) {
        final currentState = state as TodaySaleLoaded;
        final shuffledProducts = List<ProductModel>.from(currentState.products)
          ..shuffle();
        print(
            'Products shuffled. New order length: ${shuffledProducts.length}');
        emit(TodaySaleLoaded(shuffledProducts));
      }
    });
  }
}
