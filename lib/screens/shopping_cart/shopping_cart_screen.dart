import 'package:flutter/material.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/screens/history/widgets/dummy_products.dart';

import 'widgets/cart_pricesection_widget.dart';
import 'widgets/cart_productlist_widget.dart';

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

    regularDeliveryItems = dummyProducts.take(5).toList();
    pickupItems = dummyProducts.skip(5).take(2).toList();

    for (var item in [...regularDeliveryItems, ...pickupItems]) {
      selectedItems[item.productId] = false;
      itemQuantities[item.productId] = 1;
    }
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

  String formatPrice(String price) {
    return price.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(text: '일반 배송(${regularDeliveryItems.length})'),
          Tab(text: '픽업(${pickupItems.length})'),
        ],
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.black,
      ),
    );
  }

  Widget _buildBottomBar() {
    List<ProductModel> currentItems =
        _tabController.index == 0 ? regularDeliveryItems : pickupItems;
    final totalPrice = CartPriceSectionWidget.calculateTotalPrice(
      items: currentItems,
      selectedItems: selectedItems,
      itemQuantities: itemQuantities,
    );
    final totalDiscount = CartPriceSectionWidget.calculateTotalDiscount(
      items: currentItems,
      selectedItems: selectedItems,
      itemQuantities: itemQuantities,
    );
    final finalPrice = totalPrice - totalDiscount;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              child: Text('선물하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              child: Text('구매하기 (${formatPrice(finalPrice.toString())}원)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          _buildTabs(), // TabBar는 고정되어 스크롤되지 않음
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 일반 배송 탭 내용
                SingleChildScrollView(
                  child: Column(
                    children: [
                      CartProductListWidget(
                        items: regularDeliveryItems,
                        isPickup: false,
                        selectedItems: selectedItems,
                        itemQuantities: itemQuantities,
                        updateQuantity: updateQuantity,
                        onRemoveItem: (item) => setState(() {
                          regularDeliveryItems.remove(item);
                          selectedItems.remove(item.productId);
                          itemQuantities.remove(item.productId);
                        }),
                      ),
                      CartPriceSectionWidget(
                        items: regularDeliveryItems,
                        selectedItems: selectedItems,
                        itemQuantities: itemQuantities,
                      ),
                    ],
                  ),
                ),
                // 픽업 탭 내용
                SingleChildScrollView(
                  child: Column(
                    children: [
                      CartProductListWidget(
                        items: pickupItems,
                        isPickup: true,
                        selectedItems: selectedItems,
                        itemQuantities: itemQuantities,
                        updateQuantity: updateQuantity,
                        onRemoveItem: (item) => setState(() {
                          pickupItems.remove(item);
                          selectedItems.remove(item.productId);
                          itemQuantities.remove(item.productId);
                        }),
                      ),
                      CartPriceSectionWidget(
                        items: pickupItems,
                        selectedItems: selectedItems,
                        itemQuantities: itemQuantities,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(), // 하단 버튼 영역
    );
  }
}
