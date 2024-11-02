import 'package:flutter/material.dart';
import 'package:onlyveyou/models/product_model.dart';

import 'widgets/cart_bottombar_widget.dart';
import 'widgets/cart_tab_header_widget.dart';

class ShoppingCartScreen extends StatefulWidget {
  @override
  _ShoppingCartScreenState createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isAllSelected = false;
  Map<String, bool> selectedItems = {};
  Map<String, int> itemQuantities = {};
  late List<ProductModel> regularDeliveryItems;
  late List<ProductModel> pickupItems;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // TODO: 실제 데이터로 초기화 필요
    regularDeliveryItems = [
      // 샘플 데이터 추가
    ];
    pickupItems = [
      // 샘플 데이터 추가
    ];

    for (var item in [...regularDeliveryItems, ...pickupItems]) {
      selectedItems[item.productId] = false;
      itemQuantities[item.productId] = 1;
    }

    _tabController.addListener(() {
      setState(() {
        isAllSelected = false;
        selectedItems.clear();
      });
    });
  }

  void updateItemSelection(String productId, bool? value) {
    setState(() {
      selectedItems[productId] = value ?? false;
      final currentItems =
          _tabController.index == 0 ? regularDeliveryItems : pickupItems;
      isAllSelected =
          currentItems.every((item) => selectedItems[item.productId] == true);
    });
  }

  void moveToRegularDelivery() {
    setState(() {
      List<ProductModel> itemsToMove = pickupItems
          .where((item) => selectedItems[item.productId] == true)
          .toList();
      pickupItems.removeWhere((item) => selectedItems[item.productId] == true);
      regularDeliveryItems.addAll(itemsToMove);
      selectedItems.clear();
      isAllSelected = false;
      _tabController.animateTo(0);
    });
  }

  void onSelectAll(bool? value) {
    setState(() {
      final currentItems =
          _tabController.index == 0 ? regularDeliveryItems : pickupItems;
      for (var item in currentItems) {
        selectedItems[item.productId] = value ?? false;
      }
      isAllSelected = value ?? false;
    });
  }

  void onDeleteSelected() {
    setState(() {
      if (_tabController.index == 0) {
        regularDeliveryItems
            .removeWhere((item) => selectedItems[item.productId] == true);
      } else {
        pickupItems
            .removeWhere((item) => selectedItems[item.productId] == true);
      }
      selectedItems.clear();
      isAllSelected = false;
    });
  }

  void moveToPickup() {
    setState(() {
      List<ProductModel> itemsToMove = regularDeliveryItems
          .where((item) => selectedItems[item.productId] == true)
          .toList();
      regularDeliveryItems
          .removeWhere((item) => selectedItems[item.productId] == true);
      pickupItems.addAll(itemsToMove);
      selectedItems.clear();
      isAllSelected = false;
      _tabController.animateTo(1);
    });
  }

  void updateQuantity(String productId, bool increment) {
    setState(() {
      int currentQuantity = itemQuantities[productId] ?? 1;
      if (increment && currentQuantity < 99) {
        itemQuantities[productId] = currentQuantity + 1;
      } else if (!increment && currentQuantity > 1) {
        itemQuantities[productId] = currentQuantity - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentItems =
        _tabController.index == 0 ? regularDeliveryItems : pickupItems;

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
      body: CartTabHeaderWidget(
        regularDeliveryItems: regularDeliveryItems,
        pickupItems: pickupItems,
        selectedItems: selectedItems,
        itemQuantities: itemQuantities,
        isAllSelected: isAllSelected,
        onSelectAll: onSelectAll,
        onRemoveItem: (item) => setState(() {
          if (_tabController.index == 0) {
            regularDeliveryItems.remove(item);
          } else {
            pickupItems.remove(item);
          }
          selectedItems.remove(item.productId);
          itemQuantities.remove(item.productId);
        }),
        updateQuantity: updateQuantity,
        onUpdateSelection: updateItemSelection,
        onDeleteSelected: onDeleteSelected,
        moveToPickup: moveToPickup,
        moveToRegularDelivery: moveToRegularDelivery,
        tabController: _tabController,
      ),
      bottomNavigationBar: CartBottomBarWidget(
        currentItems: currentItems,
        selectedItems: selectedItems,
        itemQuantities: itemQuantities,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
