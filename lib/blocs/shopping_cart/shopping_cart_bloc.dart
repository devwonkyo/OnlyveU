import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/repositories/shopping_cart_repository.dart';

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

class DeleteSelectedItems extends CartEvent {
  final bool isRegularDelivery;
  const DeleteSelectedItems(this.isRegularDelivery);
  @override
  List<Object> get props => [isRegularDelivery];
}

class MoveToPickup extends CartEvent {}

class MoveToRegularDelivery extends CartEvent {}

class UpdateCurrentTab extends CartEvent {
  final bool isRegularDelivery;
  const UpdateCurrentTab(this.isRegularDelivery);
  @override
  List<Object> get props => [isRegularDelivery];
}

// State
class CartState extends Equatable {
  final List<ProductModel> regularDeliveryItems;
  final List<ProductModel> pickupItems;
  final Map<String, bool> selectedItems;
  final Map<String, int> itemQuantities;
  final bool isAllSelected;
  final bool isLoading;
  final String? error;
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

// Bloc
class CartBloc extends Bloc<CartEvent, CartState> {
  final ShoppingCartRepository _cartRepository;

  CartBloc({required ShoppingCartRepository cartRepository})
      : _cartRepository = cartRepository,
        super(const CartState()) {
    on<LoadCart>(_onLoadCart);
    on<UpdateItemSelection>(_onUpdateItemSelection);
    on<UpdateItemQuantity>(_onUpdateItemQuantity);
    on<RemoveItem>(_onRemoveItem);
    on<SelectAllItems>(_onSelectAllItems);
    on<DeleteSelectedItems>(_onDeleteSelectedItems);
    on<MoveToPickup>(_onMoveToPickup);
    on<MoveToRegularDelivery>(_onMoveToRegularDelivery);
    on<UpdateCurrentTab>(_onUpdateCurrentTab);
  }

  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final items = await _cartRepository.loadCartItems();

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
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  void _onUpdateItemSelection(
      UpdateItemSelection event, Emitter<CartState> emit) {
    final updatedSelectedItems = Map<String, bool>.from(state.selectedItems);
    updatedSelectedItems[event.productId] = event.isSelected;

    final currentItems = state.isRegularDeliveryTab
        ? state.regularDeliveryItems
        : state.pickupItems;

    final isAllSelected = currentItems.every(
      (item) => updatedSelectedItems[item.productId] == true,
    );

    emit(state.copyWith(
      selectedItems: updatedSelectedItems,
      isAllSelected: isAllSelected,
    ));
  }

  Future<void> _onUpdateItemQuantity(
      UpdateItemQuantity event, Emitter<CartState> emit) async {
    final updatedQuantities = Map<String, int>.from(state.itemQuantities);
    final currentQuantity = updatedQuantities[event.productId] ?? 1;

    if (event.increment && currentQuantity < 99) {
      updatedQuantities[event.productId] = currentQuantity + 1;
      await _cartRepository.updateProductQuantity(
          event.productId, currentQuantity + 1);
    } else if (!event.increment && currentQuantity > 1) {
      updatedQuantities[event.productId] = currentQuantity - 1;
      await _cartRepository.updateProductQuantity(
          event.productId, currentQuantity - 1);
    }

    emit(state.copyWith(itemQuantities: updatedQuantities));
  }

  Future<void> _onRemoveItem(RemoveItem event, Emitter<CartState> emit) async {
    try {
      await _cartRepository.removeProduct(event.item.productId);

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
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _onSelectAllItems(SelectAllItems event, Emitter<CartState> emit) {
    final updatedSelectedItems = Map<String, bool>.from(state.selectedItems);
    final currentItems = state.isRegularDeliveryTab
        ? state.regularDeliveryItems
        : state.pickupItems;

    for (var item in currentItems) {
      updatedSelectedItems[item.productId] = event.value;
    }

    emit(state.copyWith(
      selectedItems: updatedSelectedItems,
      isAllSelected: event.value,
    ));
  }

  Future<void> _onDeleteSelectedItems(
      DeleteSelectedItems event, Emitter<CartState> emit) async {
    try {
      final itemsToDelete = event.isRegularDelivery
          ? state.regularDeliveryItems
              .where((item) => state.selectedItems[item.productId] == true)
          : state.pickupItems
              .where((item) => state.selectedItems[item.productId] == true);

      final itemIds = itemsToDelete.map((e) => e.productId).toList();
      await _cartRepository.removeSelectedProducts(itemIds);

      if (event.isRegularDelivery) {
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
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onMoveToPickup(
      MoveToPickup event, Emitter<CartState> emit) async {
    try {
      final itemsToMove = state.regularDeliveryItems
          .where((item) => state.selectedItems[item.productId] == true)
          .toList();

      // Update delivery method in Firestore
      for (var item in itemsToMove) {
        await _cartRepository.updateDeliveryMethod(item.productId, true);
      }

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
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onMoveToRegularDelivery(
      MoveToRegularDelivery event, Emitter<CartState> emit) async {
    try {
      final itemsToMove = state.pickupItems
          .where((item) => state.selectedItems[item.productId] == true)
          .toList();

      // Update delivery method in Firestore
      for (var item in itemsToMove) {
        await _cartRepository.updateDeliveryMethod(item.productId, false);
      }

      final updatedPickupItems = state.pickupItems
          .where((item) => state.selectedItems[item.productId] != true)
          .toList();

      final updatedRegularItems = [
        ...state.regularDeliveryItems,
        ...itemsToMove
      ];
      final updatedSelectedItems = Map<String, bool>.from(state.selectedItems)
        ..removeWhere((key, value) => value);

      emit(state.copyWith(
        regularDeliveryItems: updatedRegularItems,
        pickupItems: updatedPickupItems,
        selectedItems: updatedSelectedItems,
        isAllSelected: false,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _onUpdateCurrentTab(UpdateCurrentTab event, Emitter<CartState> emit) {
    emit(state.copyWith(isRegularDeliveryTab: event.isRegularDelivery));

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
}
