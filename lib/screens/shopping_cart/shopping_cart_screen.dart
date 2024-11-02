import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/shopping_cart/shopping_cart_bloc.dart';
import 'widgets/cart_bottombar_widget.dart';
import 'widgets/cart_tab_header_widget.dart';
//스크린에서 1탭헤더. 2바텀바만 쓰고
//위젯이 1탭헤더에서 프라이스 위젯쓰고, 프로덕트리스트 위젯쓴다.
///     2바텀바에서 프라이스 위젯 쓴다

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
      cartBloc.add(const SelectAllItems(false));
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
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.home_outlined, color: Colors.black),
                onPressed: () {},
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
                  onSelectAll: (value) {
                    context
                        .read<CartBloc>()
                        .add(SelectAllItems(value ?? false));
                  },
                  onRemoveItem: (item) {
                    context.read<CartBloc>().add(RemoveItem(item));
                  },
                  updateQuantity: (productId, increment) {
                    context
                        .read<CartBloc>()
                        .add(UpdateItemQuantity(productId, increment));
                  },
                  onUpdateSelection: (productId, value) {
                    context
                        .read<CartBloc>()
                        .add(UpdateItemSelection(productId, value ?? false));
                  },
                  onDeleteSelected: () {
                    context.read<CartBloc>().add(DeleteSelectedItems());
                  },
                  moveToPickup: () {
                    context.read<CartBloc>().add(MoveToPickup());
                  },
                  moveToRegularDelivery: () {
                    context.read<CartBloc>().add(MoveToRegularDelivery());
                  },
                  tabController: _tabController,
                ),
          bottomNavigationBar: state.isLoading
              ? null
              : CartBottomBarWidget(
                  currentItems: _tabController.index == 0
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
