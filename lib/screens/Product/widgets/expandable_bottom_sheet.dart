import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/product/cart/product_cart_bloc.dart';
import 'package:onlyveyou/config/color.dart';
import 'package:onlyveyou/core/router.dart';
import 'package:onlyveyou/main.dart';
import 'package:onlyveyou/models/order_item_model.dart';
import 'package:onlyveyou/models/order_model.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/utils/format_price.dart';

class ExpandableBottomSheet extends StatefulWidget {
  final ProductModel productModel;
  final String userId;

  const ExpandableBottomSheet({super.key, required this.productModel, required this.userId});

  @override
  State<ExpandableBottomSheet> createState() => _ExpandableBottomSheetState();
}

class _ExpandableBottomSheetState extends State<ExpandableBottomSheet> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isExpanded = false;
  int _quantity = 1;
  late final int _price; // 상품 가격 예시

  @override
  void initState() {
    super.initState();
    _price = formatDiscountedPriceToInt(
        widget.productModel.price, widget.productModel.discountPercent.toDouble());

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
            IconButton(
              padding: EdgeInsets.zero,
              color: Colors.grey,
              icon: Icon(
                _isExpanded ? Icons.keyboard_arrow_down_outlined : Icons.keyboard_arrow_up,
                size: 24.sp,
              ),
              onPressed: _toggleExpand,
            ),

            // Expandable Content
            SizeTransition(
              sizeFactor: _animation,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    // Quantity Control
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove, size: 20.sp),
                            onPressed: () {
                              if (_quantity > 1) {
                                setState(() => _quantity--);
                              }
                            },
                          ),
                          SizedBox(width: 16.w),
                          Text(
                            '$_quantity',
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 16.w),
                          IconButton(
                            icon: Icon(Icons.add, size: 20.sp),
                            onPressed: () {
                              setState(() => _quantity++);
                            },
                          ),
                        ],
                      ),
                    ),

                    // Price Information
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                '구매수량: ',
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              Text(
                                _quantity.toString(),
                                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '개',
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ],
                          ),
                          Text(
                            '총 ${formatPrice((_price * _quantity).toStringAsFixed(0))}원',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(thickness: 1.h),
                    SizedBox(height : 16.h),
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            Padding(
              padding: EdgeInsets.fromLTRB(16.w,0,16.w,16.w),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<ProductCartBloc>().add(AddToCartEvent(widget.productModel, quantity: _quantity));
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        '장바구니',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: () {
                        final orderItem = OrderItemModel(
                            productId: widget.productModel.productId,
                            productName: widget.productModel.name,
                            productImageUrl: widget.productModel.productImageList[0],
                            productPrice: formatDiscountedPriceToInt(widget.productModel.price, widget.productModel.discountPercent.toDouble()),
                            quantity: _quantity);

                        final items = [orderItem];

                        final order = OrderModel(userId: widget.userId, items: items, orderType: OrderType.delivery);
                        context.push(
                          '/payment', extra: order,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        '바로구매',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }
}