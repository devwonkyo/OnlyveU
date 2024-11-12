import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/shopping_cart/shopping_cart_bloc.dart';
import 'package:onlyveyou/screens/shopping_cart/widgets/cart_bottombar_widget.dart';
import 'package:onlyveyou/screens/shopping_cart/widgets/cart_tab_header_widget.dart';

class ShoppingCartScreen extends StatefulWidget {
  @override
  _ShoppingCartScreenState createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<CartBloc>().add(LoadCart());

    _tabController.addListener(() {
      final cartBloc = context.read<CartBloc>();
      cartBloc.add(UpdateCurrentTab(_tabController.index == 0));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              '장바구니',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.search, color: Colors.black),
                onPressed: () => context.go('/search'),
              ),
              IconButton(
                icon: Icon(Icons.home_outlined, color: Colors.black),
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
          body: state.isLoading
              ? Center(child: CircularProgressIndicator())
              : CartTabHeaderWidget(
                  regularDeliveryItems: state.regularDeliveryItems,
                  pickupItems: state.pickupItems,
                  selectedItems: state.selectedItems,
                  itemQuantities: state.itemQuantities,
                  isAllSelected: state.isAllSelected,
                  isRegularDeliveryTab: state.isRegularDeliveryTab,
                  onSelectAll: (value, isPickup) {
                    context
                        .read<CartBloc>()
                        .add(SelectAllItems(value ?? true, isPickup));
                  },
                  onRemoveItem: (productId, isPickup) {
                    context
                        .read<CartBloc>()
                        .add(RemoveItem(productId, isPickup));
                  },
                  onUpdateQuantity: (productId, increment, isPickup) {
                    context.read<CartBloc>().add(
                          UpdateItemQuantity(productId, increment, isPickup),
                        );
                  },
                  onUpdateSelection: (productId, value) {
                    context.read<CartBloc>().add(
                          UpdateItemSelection(productId, value ?? true),
                        );
                  },
                  onDeleteSelected: (isPickup) {
                    context.read<CartBloc>().add(DeleteSelectedItems(isPickup));
                  },
                  onMoveToPickup: (selectedIds) {
                    context.read<CartBloc>().add(MoveToPickup(selectedIds));
                  },
                  onMoveToRegularDelivery: (selectedIds) {
                    context
                        .read<CartBloc>()
                        .add(MoveToRegularDelivery(selectedIds));
                  },
                  tabController: _tabController,
                ),
          bottomNavigationBar: state.isLoading
              ? null
              : CartBottomBarWidget(
                  currentItems: state.isRegularDeliveryTab
                      ? state.regularDeliveryItems
                      : state.pickupItems,
                  selectedItems: state.selectedItems,
                  itemQuantities: state.itemQuantities,
                ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
