import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';
import 'package:onlyveyou/models/order_model.dart';
import 'package:onlyveyou/models/order_item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductTagSelector extends StatefulWidget {
  final Function(List<String>) onTagsSelected;
  final List<String> initialTags;
  final bool isReadOnly;
  final Color? selectedColor;

  const ProductTagSelector({
    Key? key,
    required this.onTagsSelected,
    this.initialTags = const [],
    this.isReadOnly = false,
    required this.selectedColor,
  }) : super(key: key);

  @override
  _ProductTagSelectorState createState() => _ProductTagSelectorState();
}

class _ProductTagSelectorState extends State<ProductTagSelector> {
  List<OrderItemModel> purchasedProducts = [];
  List<String> selectedTags = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedTags = List.from(widget.initialTags);
    if (!widget.isReadOnly) {
      _loadPurchasedProducts();
    }
  }

  Future<void> _loadPurchasedProducts() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';

      final QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();

      final Set<String> uniqueProductIds = {};
      final List<OrderItemModel> products = [];

      for (var doc in ordersSnapshot.docs) {
        final order = OrderModel.fromMap(doc.data() as Map<String, dynamic>);
        for (var item in order.items) {
          if (!uniqueProductIds.contains(item.productId)) {
            uniqueProductIds.add(item.productId);
            products.add(item);
          }
        }
      }

      setState(() {
        purchasedProducts = products;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading purchased products: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.isReadOnly) ...[
          Text(
            '구매한 제품 태그하기',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
        ],
        if (isLoading && !widget.isReadOnly)
          Center(child: CircularProgressIndicator())
        else if (purchasedProducts.isEmpty && !widget.isReadOnly)
          Text('구매한 제품이 없습니다.')
        else
          Container(
            width: double.infinity,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.isReadOnly
                  ? selectedTags.map((tag) => _buildProductChip(tag)).toList()
                  : purchasedProducts
                      .map((product) => _buildFilterChip(product))
                      .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildProductChip(String productId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get(),
      builder: (context, snapshot) {
        String productName = '로딩중...';
        if (snapshot.hasData && snapshot.data != null) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          productName = data?['name'] ?? '제품 없음';
        }

        return Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.4,
          ),
          child: Chip(
            label: Text(
              productName,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            backgroundColor: widget.selectedColor?.withOpacity(0.1),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(OrderItemModel product) {
    final isSelected = selectedTags.contains(product.productId);
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.4,
      ),
      child: FilterChip(
        label: Text(
          product.productName,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        selected: isSelected,
        selectedColor: widget.selectedColor?.withOpacity(0.2),
        onSelected: widget.isReadOnly
            ? null
            : (selected) {
                setState(() {
                  if (selected) {
                    selectedTags.add(product.productId);
                  } else {
                    selectedTags.remove(product.productId);
                  }
                  widget.onTagsSelected(selectedTags);
                });
              },
      ),
    );
  }
}
