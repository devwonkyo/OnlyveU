import 'package:flutter/material.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/screens/history/widgets/dummy_products.dart'; // 경로 확인 필요

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

  int calculateTotalPrice(List<ProductModel> items) {
    return items.fold(0, (sum, item) {
      if (selectedItems[item.productId] == true) {
        int quantity = itemQuantities[item.productId] ?? 1;
        return sum + (int.parse(item.price) * quantity);
      }
      return sum;
    });
  }

  int calculateTotalDiscount(List<ProductModel> items) {
    return items.fold(0, (sum, item) {
      if (selectedItems[item.productId] == true) {
        int quantity = itemQuantities[item.productId] ?? 1;
        int originalPrice = int.parse(item.price);
        int discountedPrice = item.discountedPrice;
        return sum + ((originalPrice - discountedPrice) * quantity);
      }
      return sum;
    });
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

  Widget _buildRegularDeliveryTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSelectAllSection(),
          _buildProductList(regularDeliveryItems, false),
          _buildPriceSection(regularDeliveryItems),
        ],
      ),
    );
  }

  Widget _buildPickupTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSelectAllSection(),
          _buildProductList(pickupItems, true),
          _buildPriceSection(pickupItems),
        ],
      ),
    );
  }

  Widget _buildSelectAllSection() {
    List<ProductModel> currentItems =
        _tabController.index == 0 ? regularDeliveryItems : pickupItems;

    return Container(
      color: Color(0xFFF5F5F5),
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Checkbox(
            value: currentItems
                .every((item) => selectedItems[item.productId] == true),
            onChanged: (value) {
              setState(() {
                for (var item in currentItems) {
                  selectedItems[item.productId] = value ?? false;
                }
              });
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Text('전체'),
          SizedBox(width: 16),
          Text('배송방법 변경 >', style: TextStyle(color: Colors.grey)),
          Spacer(),
          Text('선택삭제', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildProductList(List<ProductModel> items, bool isPickup) {
    return Column(
      children: items.map((item) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isPickup)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text('픽업 매장: 거여역점',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: selectedItems[item.productId] ?? false,
                    onChanged: (value) {
                      setState(() {
                        selectedItems[item.productId] = value ?? false;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      item.productImageList.first,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            if (item.isBest)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.pink[50],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'BEST',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.pink,
                                  ),
                                ),
                              ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '픽업가능',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.amber),
                            SizedBox(width: 4),
                            Text(
                              item.rating.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              '(${item.reviewList.length})',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 20),
                    onPressed: () {
                      setState(() {
                        selectedItems.remove(item.productId);
                        itemQuantities.remove(item.productId);
                        if (isPickup) {
                          pickupItems.remove(item);
                        } else {
                          regularDeliveryItems.remove(item);
                        }
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(width: 50),
                  Container(
                    height: 28,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: IconButton(
                            icon: Icon(Icons.remove, size: 16),
                            onPressed: () =>
                                updateQuantity(item.productId, false),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        Container(
                          width: 30,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(color: Colors.grey[300]!),
                              right: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          child: Text(
                            '${itemQuantities[item.productId] ?? 1}',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: IconButton(
                            icon: Icon(Icons.add, size: 16),
                            onPressed: () =>
                                updateQuantity(item.productId, true),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${formatPrice(item.price)}원',
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${formatPrice(item.discountedPrice.toString())}원',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceSection(List<ProductModel> items) {
    final totalPrice = calculateTotalPrice(items);
    final totalDiscount = calculateTotalDiscount(items);
    final finalPrice = totalPrice - totalDiscount;

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('총 상품금액'),
              Text('${formatPrice(totalPrice.toString())}원',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('총 할인금액'),
              Text('${formatPrice(totalDiscount.toString())}원',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('총 배송비'),
              Text('0원', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('최종 결제금액'),
              Text('${formatPrice(finalPrice.toString())}원',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    List<ProductModel> currentItems =
        _tabController.index == 0 ? regularDeliveryItems : pickupItems;
    final totalPrice = calculateTotalPrice(currentItems);
    final totalDiscount = calculateTotalDiscount(currentItems);
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
          _buildTabs(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRegularDeliveryTab(),
                _buildPickupTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }
}
