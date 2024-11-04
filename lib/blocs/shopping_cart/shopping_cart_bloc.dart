import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/models/product_model.dart';

//
// Events
// CartEvent: 장바구니 관련 이벤트의 기본 클래스
abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object> get props => [];
}

// 각 이벤트 정의
class LoadCart extends CartEvent {} // 장바구니 로드

class UpdateItemSelection extends CartEvent {
  // 아이템 선택 상태 업데이트
  final String productId;
  final bool isSelected;
  const UpdateItemSelection(this.productId, this.isSelected);
  @override
  List<Object> get props => [productId, isSelected];
}

class UpdateItemQuantity extends CartEvent {
  // 아이템 수량 업데이트
  final String productId;
  final bool increment;
  const UpdateItemQuantity(this.productId, this.increment);
  @override
  List<Object> get props => [productId, increment];
}

class RemoveItem extends CartEvent {
  // 아이템 제거
  final ProductModel item;
  const RemoveItem(this.item);
  @override
  List<Object> get props => [item];
}

class SelectAllItems extends CartEvent {
  // 모든 항목 선택/해제
  final bool value;
  const SelectAllItems(this.value);
  @override
  List<Object> get props => [value];
}

class DeleteSelectedItems extends CartEvent {
  final bool isRegularDelivery; // 현재 탭이 일반배송인지 여부
  const DeleteSelectedItems(this.isRegularDelivery);

  @override
  List<Object> get props => [isRegularDelivery];
} // 선택된 항목 삭제

class MoveToPickup extends CartEvent {} // 항목을 픽업으로 이동

class MoveToRegularDelivery extends CartEvent {} // 항목을 일반 배송으로 이동

class UpdateCurrentTab extends CartEvent {
  final bool isRegularDelivery;
  const UpdateCurrentTab(this.isRegularDelivery);

  @override
  List<Object> get props => [isRegularDelivery];
}

// State
// CartState: 장바구니 상태를 나타내는 클래스
class CartState extends Equatable {
  final List<ProductModel> regularDeliveryItems; // 일반 배송 항목 목록
  final List<ProductModel> pickupItems; // 픽업 항목 목록
  final Map<String, bool> selectedItems; // 각 항목의 선택 여부
  final Map<String, int> itemQuantities; // 각 항목의 수량
  final bool isAllSelected; // 모든 항목 선택 여부
  final bool isLoading; // 로딩 중 여부
  final String? error; // 오류 메시지
  final bool isRegularDeliveryTab;

  const CartState({
    this.regularDeliveryItems = const [],
    this.pickupItems = const [],
    this.selectedItems = const {},
    this.itemQuantities = const {},
    this.isAllSelected = true,
    this.isLoading = false,
    this.error,
    this.isRegularDeliveryTab = true,
  });

  // 현재 상태에서 필요한 일부 값만 수정하여 새로운 상태를 반환하는 copyWith 메서드
  CartState copyWith({
    List<ProductModel>? regularDeliveryItems,
    List<ProductModel>? pickupItems,
    Map<String, bool>? selectedItems,
    Map<String, int>? itemQuantities,
    bool? isAllSelected,
    bool? isLoading,
    String? error,
    bool? isRegularDeliveryTab,
  }) {
    return CartState(
      regularDeliveryItems: regularDeliveryItems ?? this.regularDeliveryItems,
      pickupItems: pickupItems ?? this.pickupItems,
      selectedItems: selectedItems ?? this.selectedItems,
      itemQuantities: itemQuantities ?? this.itemQuantities,
      isAllSelected: isAllSelected ?? this.isAllSelected,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isRegularDeliveryTab: isRegularDeliveryTab ?? this.isRegularDeliveryTab,
    );
  }

  @override
  List<Object?> get props => [
        regularDeliveryItems,
        pickupItems,
        selectedItems,
        itemQuantities,
        isAllSelected,
        isLoading,
        error,
        isRegularDeliveryTab,
      ];
}

// BLoC 시작
// CartBloc: 장바구니 관련 이벤트를 받아 상태를 업데이트하는 로직을 정의
class CartBloc extends Bloc<CartEvent, CartState> {
  final FirebaseFirestore _firestore;

  CartBloc({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(const CartState()) {
    on<LoadCart>(_onLoadCart); // 장바구니 로드 처리
    on<UpdateItemSelection>(_onUpdateItemSelection); // 아이템 선택 상태 업데이트
    on<UpdateItemQuantity>(_onUpdateItemQuantity);
    on<RemoveItem>(_onRemoveItem);
    on<SelectAllItems>(_onSelectAllItems); // 모든 항목 선택/해제
    on<DeleteSelectedItems>(_onDeleteSelectedItems); // 선택된 항목 삭제
    on<MoveToPickup>(_onMoveToPickup); // 항목을 픽업으로 이동
    on<MoveToRegularDelivery>(_onMoveToRegularDelivery);
    on<UpdateCurrentTab>(_onUpdateCurrentTab); // 항목을 일반 배송으로 이동
  }

  // 장바구니 데이터를 Firestore에서 불러오는 로직
  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    emit(state.copyWith(isLoading: true)); // 로딩 시작
    try {
      // Firestore에서 제품 데이터를 불러와 장바구니에 저장
      final snapshot = await _firestore.collection('products').limit(5).get();
      final items = snapshot.docs
          .map(
              (doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // 초기 선택 상태 및 수량 설정
      final initialSelectedItems = Map.fromEntries(
        items.map((item) => MapEntry(item.productId, true)),
      );
      final initialQuantities = Map.fromEntries(
        items.map((item) => MapEntry(item.productId, 1)),
      );

      emit(state.copyWith(
        regularDeliveryItems: items,
        selectedItems: initialSelectedItems,
        itemQuantities: initialQuantities,
        isLoading: false,
      ));
    } catch (e) {
      // 오류 발생 시 오류 메시지 설정
      emit(state.copyWith(
        error: '상품 정보를 불러오는데 실패했습니다.',
        isLoading: false,
      ));
    }
  }

  // 특정 아이템의 선택 상태를 업데이트
  void _onUpdateItemSelection(
      UpdateItemSelection event, Emitter<CartState> emit) {
    final updatedSelectedItems = Map<String, bool>.from(state.selectedItems);
    updatedSelectedItems[event.productId] = event.isSelected;

    // 모든 항목이 선택되었는지 여부 확인
    final isAllSelected = state.regularDeliveryItems.every(
      (item) => updatedSelectedItems[item.productId] == true,
    );

    emit(state.copyWith(
      selectedItems: updatedSelectedItems,
      isAllSelected: isAllSelected,
    ));
  }

  // 특정 아이템의 수량을 증가 또는 감소
  void _onUpdateItemQuantity(
      UpdateItemQuantity event, Emitter<CartState> emit) {
    final updatedQuantities = Map<String, int>.from(state.itemQuantities);
    final currentQuantity = updatedQuantities[event.productId] ?? 1;

    if (event.increment && currentQuantity < 99) {
      updatedQuantities[event.productId] = currentQuantity + 1; // 수량 증가
    } else if (!event.increment && currentQuantity > 1) {
      updatedQuantities[event.productId] = currentQuantity - 1; // 수량 감소
    }

    emit(state.copyWith(itemQuantities: updatedQuantities));
  }

  // 특정 아이템을 장바구니에서 제거
  void _onRemoveItem(RemoveItem event, Emitter<CartState> emit) {
    final updatedRegularItems =
        List<ProductModel>.from(state.regularDeliveryItems)
          ..removeWhere((item) => item.productId == event.item.productId);
    final updatedPickupItems = List<ProductModel>.from(state.pickupItems)
      ..removeWhere((item) => item.productId == event.item.productId);

    final updatedSelectedItems = Map<String, bool>.from(state.selectedItems)
      ..remove(event.item.productId);
    final updatedQuantities = Map<String, int>.from(state.itemQuantities)
      ..remove(event.item.productId);

    emit(state.copyWith(
      regularDeliveryItems: updatedRegularItems,
      pickupItems: updatedPickupItems,
      selectedItems: updatedSelectedItems,
      itemQuantities: updatedQuantities,
    ));
  }

  // 모든 항목 선택/해제 처리
  void _onSelectAllItems(SelectAllItems event, Emitter<CartState> emit) {
    final updatedSelectedItems = Map<String, bool>.from(state.selectedItems);

    // 현재 선택된 아이템 리스트 결정
    final currentItems = state.regularDeliveryItems + state.pickupItems;

    // 모든 아이템의 선택 상태를 업데이트
    for (var item in currentItems) {
      updatedSelectedItems[item.productId] = event.value;
    }

    emit(state.copyWith(
      selectedItems: updatedSelectedItems,
      isAllSelected: event.value,
    ));
  }

  // 선택된 항목을 삭제
  void _onDeleteSelectedItems(
      DeleteSelectedItems event, Emitter<CartState> emit) {
    if (event.isRegularDelivery) {
      // 일반배송 탭에서의 삭제
      final updatedRegularItems = state.regularDeliveryItems
          .where((item) => !state.selectedItems[item.productId]!)
          .toList();

      final updatedSelectedItems = Map<String, bool>.from(state.selectedItems)
        ..removeWhere((key, value) =>
            value &&
            state.regularDeliveryItems.any((item) => item.productId == key));

      final updatedQuantities = Map<String, int>.from(state.itemQuantities)
        ..removeWhere((key, _) => state.regularDeliveryItems.any((item) =>
            item.productId == key && state.selectedItems[key] == true));

      emit(state.copyWith(
        regularDeliveryItems: updatedRegularItems,
        selectedItems: updatedSelectedItems,
        itemQuantities: updatedQuantities,
        isAllSelected: false,
      ));
    } else {
      // 픽업 탭에서의 삭제
      final updatedPickupItems = state.pickupItems
          .where((item) => !state.selectedItems[item.productId]!)
          .toList();

      final updatedSelectedItems = Map<String, bool>.from(state.selectedItems)
        ..removeWhere((key, value) =>
            value && state.pickupItems.any((item) => item.productId == key));

      final updatedQuantities = Map<String, int>.from(state.itemQuantities)
        ..removeWhere((key, _) => state.pickupItems.any((item) =>
            item.productId == key && state.selectedItems[key] == true));

      emit(state.copyWith(
        pickupItems: updatedPickupItems,
        selectedItems: updatedSelectedItems,
        itemQuantities: updatedQuantities,
        isAllSelected: false,
      ));
    }
  }

  // 선택된 항목을 픽업 목록으로 이동
  void _onMoveToPickup(MoveToPickup event, Emitter<CartState> emit) {
    final itemsToMove = state.regularDeliveryItems
        .where((item) => state.selectedItems[item.productId] == true)
        .toList();

    final updatedRegularItems = state.regularDeliveryItems
        .where((item) => state.selectedItems[item.productId] != true)
        .toList();

    final updatedPickupItems = [...state.pickupItems, ...itemsToMove];
    final updatedSelectedItems = Map<String, bool>.from(state.selectedItems)
      ..removeWhere((key, value) => value);

    emit(state.copyWith(
      regularDeliveryItems: updatedRegularItems,
      pickupItems: updatedPickupItems,
      selectedItems: updatedSelectedItems,
      isAllSelected: false,
    ));
  }

  void _onUpdateCurrentTab(UpdateCurrentTab event, Emitter<CartState> emit) {
    // 현재 탭 업데이트
    emit(state.copyWith(isRegularDeliveryTab: event.isRegularDelivery));

    // 현재 탭의 아이템들 전체 선택
    final currentItems = event.isRegularDelivery
        ? state.regularDeliveryItems
        : state.pickupItems;

    final updatedSelectedItems = Map<String, bool>.from(state.selectedItems);
    for (var item in currentItems) {
      updatedSelectedItems[item.productId] = true;
    }

    emit(state.copyWith(
      selectedItems: updatedSelectedItems,
      isAllSelected: true,
    ));
  }

  // 선택된 항목을 일반 배송 목록으로 이동
  void _onMoveToRegularDelivery(
      MoveToRegularDelivery event, Emitter<CartState> emit) {
    final itemsToMove = state.pickupItems
        .where((item) => state.selectedItems[item.productId] == true)
        .toList();

    final updatedPickupItems = state.pickupItems
        .where((item) => state.selectedItems[item.productId] != true)
        .toList();

    final updatedRegularItems = [...state.regularDeliveryItems, ...itemsToMove];
    final updatedSelectedItems = Map<String, bool>.from(state.selectedItems)
      ..removeWhere((key, value) => value);

    emit(state.copyWith(
      regularDeliveryItems: updatedRegularItems,
      pickupItems: updatedPickupItems,
      selectedItems: updatedSelectedItems,
      isAllSelected: false,
    ));
  }
}
