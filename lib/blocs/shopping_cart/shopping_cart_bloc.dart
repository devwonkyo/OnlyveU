import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/models/product_model.dart';

// Events
abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class LoadCart extends CartEvent {}

class UpdateItemSelection extends CartEvent {
  final String productId;
  final bool isSelected;

  const UpdateItemSelection(this.productId, this.isSelected);

  @override
  List<Object> get props => [productId, isSelected];
}

class UpdateItemQuantity extends CartEvent {
  final String productId;
  final bool increment;

  const UpdateItemQuantity(this.productId, this.increment);

  @override
  List<Object> get props => [productId, increment];
}

class RemoveItem extends CartEvent {
  final ProductModel item;

  const RemoveItem(this.item);

  @override
  List<Object> get props => [item];
}

class SelectAllItems extends CartEvent {
  final bool value;

  const SelectAllItems(this.value);

  @override
  List<Object> get props => [value];
}

class DeleteSelectedItems extends CartEvent {}

class MoveToPickup extends CartEvent {}

class MoveToRegularDelivery extends CartEvent {}

// State
class CartState extends Equatable {
  final List<ProductModel> regularDeliveryItems;
  final List<ProductModel> pickupItems;
  final Map<String, bool> selectedItems;
  final Map<String, int> itemQuantities;
  final bool isAllSelected;
  final bool isLoading;
  final String? error;

  const CartState({
    this.regularDeliveryItems = const [],
    this.pickupItems = const [],
    this.selectedItems = const {},
    this.itemQuantities = const {},
    this.isAllSelected = false,
    this.isLoading = false,
    this.error,
  });

  CartState copyWith({
    List<ProductModel>? regularDeliveryItems,
    List<ProductModel>? pickupItems,
    Map<String, bool>? selectedItems,
    Map<String, int>? itemQuantities,
    bool? isAllSelected,
    bool? isLoading,
    String? error,
  }) {
    return CartState(
      regularDeliveryItems: regularDeliveryItems ?? this.regularDeliveryItems,
      pickupItems: pickupItems ?? this.pickupItems,
      selectedItems: selectedItems ?? this.selectedItems,
      itemQuantities: itemQuantities ?? this.itemQuantities,
      isAllSelected: isAllSelected ?? this.isAllSelected,
      isLoading: isLoading ?? this.isLoading,
      error: error,
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
      ];
}

// BLoC
class CartBloc extends Bloc<CartEvent, CartState> {
  final FirebaseFirestore _firestore;

  CartBloc({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(const CartState()) {
    on<LoadCart>(_onLoadCart);
    on<UpdateItemSelection>(_onUpdateItemSelection);
    on<UpdateItemQuantity>(_onUpdateItemQuantity);
    on<RemoveItem>(_onRemoveItem);
    on<SelectAllItems>(_onSelectAllItems);
    on<DeleteSelectedItems>(_onDeleteSelectedItems);
    on<MoveToPickup>(_onMoveToPickup);
    on<MoveToRegularDelivery>(_onMoveToRegularDelivery);
  }

  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final snapshot = await _firestore.collection('products').limit(5).get();
      final items =
          snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();

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
      emit(state.copyWith(
        error: '상품 정보를 불러오는데 실패했습니다.',
        isLoading: false,
      ));
    }
  }

  void _onUpdateItemSelection(
      UpdateItemSelection event, Emitter<CartState> emit) {
    final updatedSelectedItems = Map<String, bool>.from(state.selectedItems);
    updatedSelectedItems[event.productId] = event.isSelected;

    final isAllSelected = state.regularDeliveryItems.every(
      (item) => updatedSelectedItems[item.productId] == true,
    );

    emit(state.copyWith(
      selectedItems: updatedSelectedItems,
      isAllSelected: isAllSelected,
    ));
  }

  void _onUpdateItemQuantity(
      UpdateItemQuantity event, Emitter<CartState> emit) {
    final updatedQuantities = Map<String, int>.from(state.itemQuantities);
    final currentQuantity = updatedQuantities[event.productId] ?? 1;

    if (event.increment && currentQuantity < 99) {
      updatedQuantities[event.productId] = currentQuantity + 1;
    } else if (!event.increment && currentQuantity > 1) {
      updatedQuantities[event.productId] = currentQuantity - 1;
    }

    emit(state.copyWith(itemQuantities: updatedQuantities));
  }

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

  void _onSelectAllItems(SelectAllItems event, Emitter<CartState> emit) {
    final updatedSelectedItems = Map<String, bool>.from(state.selectedItems);
    for (var item in state.regularDeliveryItems) {
      updatedSelectedItems[item.productId] = event.value;
    }

    emit(state.copyWith(
      selectedItems: updatedSelectedItems,
      isAllSelected: event.value,
    ));
  }

  void _onDeleteSelectedItems(
      DeleteSelectedItems event, Emitter<CartState> emit) {
    final updatedRegularItems = state.regularDeliveryItems
        .where((item) => !state.selectedItems[item.productId]!)
        .toList();
    final updatedPickupItems = state.pickupItems
        .where((item) => !state.selectedItems[item.productId]!)
        .toList();

    final updatedSelectedItems = Map<String, bool>.from(state.selectedItems)
      ..removeWhere((key, value) => value);
    final updatedQuantities = Map<String, int>.from(state.itemQuantities)
      ..removeWhere((key, _) => state.selectedItems[key] == true);

    emit(state.copyWith(
      regularDeliveryItems: updatedRegularItems,
      pickupItems: updatedPickupItems,
      selectedItems: updatedSelectedItems,
      itemQuantities: updatedQuantities,
      isAllSelected: false,
    ));
  }

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
