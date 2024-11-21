import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/mypage/order_status/order_status_bloc.dart';
import 'package:onlyveyou/blocs/mypage/order_status/order_status_event.dart';
import 'package:onlyveyou/blocs/mypage/order_status/order_status_state.dart';
import 'package:onlyveyou/config/color.dart';
import 'package:onlyveyou/models/order_model.dart';
import 'package:onlyveyou/utils/format_price.dart';
import 'package:onlyveyou/utils/order_status_util.dart';
import 'package:onlyveyou/utils/styles.dart';

class OrderStatusScreen extends StatefulWidget {
  const OrderStatusScreen({super.key});

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  OrderType? selectedOrderType;
  bool sortByNewest = true; // 기본값: 최신순

  @override
  void initState() {
    super.initState();
    context.read<OrderStatusBloc>().add(const FetchOrder());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주문/배송 조회'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 필터 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedOrderType = null;
                          });
                        },
                        child: Text(
                          '전체',
                          style: selectedOrderType == null
                              ? AppStyles.headingStyle
                              : AppStyles.bodyTextStyle,
                        ),
                      ),
                      const SizedBox(width: 15),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedOrderType = OrderType.delivery;
                          });
                        },
                        child: Text(
                          '배송',
                          style: selectedOrderType == OrderType.delivery
                              ? AppStyles.headingStyle
                              : AppStyles.bodyTextStyle,
                        ),
                      ),
                      const SizedBox(width: 15),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedOrderType = OrderType.pickup;
                          });
                        },
                        child: Text(
                          '매장픽업',
                          style: selectedOrderType == OrderType.pickup
                              ? AppStyles.headingStyle
                              : AppStyles.bodyTextStyle,
                        ),
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      setState(() {
                        sortByNewest = value == '최신순';
                      });
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: '최신순',
                        child: Text('최신순'),
                      ),
                      const PopupMenuItem(
                        value: '주문순',
                        child: Text('주문순'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // 주문 리스트
              BlocBuilder<OrderStatusBloc, OrderStatusState>(
                builder: (context, state) {
                  if (state is OrderStatusInitial) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is OrderFetch) {
                    // 필터링된 주문
                    final filteredOrders = selectedOrderType == null
                        ? state.orders
                        : state.orders
                            .where(
                                (order) => order.orderType == selectedOrderType)
                            .toList();

                    // 정렬 로직
                    filteredOrders.sort((a, b) => sortByNewest
                        ? b.createdAt.compareTo(a.createdAt)
                        : a.createdAt.compareTo(b.createdAt));

                    if (filteredOrders.isEmpty) {
                      return const Center(
                        child: Text('해당 조건의 주문이 없습니다.'),
                      );
                    }

                    final groupedOrders = groupOrdersByDate(filteredOrders);

                    return ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: groupedOrders.entries.map((entry) {
                        final date = entry.key;
                        final orders = entry.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              date,
                              style: AppStyles.headingStyle,
                            ),
                            const SizedBox(height: 10),
                            ...orders.map((order) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    orderStatusToKorean[order.status] ??
                                        "알 수 없음",
                                    style: AppStyles.bodyTextStyle,
                                  ),
                                  const SizedBox(height: 10),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: order.items.length,
                                    itemBuilder: (context, itemIndex) {
                                      final item = order.items[itemIndex];
                                      return Column(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              context.push("/product-detail",
                                                  extra: item.productId);
                                            },
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.3,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.14,
                                                  child: Image.network(
                                                    item.productImageUrl,
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        item.productName,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: AppStyles
                                                            .subHeadingStyle,
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        '수량: ${item.quantity}',
                                                        style: AppStyles
                                                            .smallTextStyle,
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        '가격: ${intformatPrice(item.productPrice)}원',
                                                        style: AppStyles
                                                            .priceTextStyle,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              );
                            }),
                          ],
                        );
                      }).toList(),
                    );
                  } else {
                    return const Column(
                      children: [
                        Icon(
                          Icons.error,
                          size: 80,
                          color: Colors.grey,
                        ),
                        Text(
                          '기간 내 주문내역이 없습니다',
                          style: TextStyle(
                            color: AppsColor.darkGray,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
