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
import 'package:intl/intl.dart';

class OrderStatusScreen extends StatefulWidget {
  const OrderStatusScreen({super.key});

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  OrderType? selectedOrderType;
  @override
  void initState() {
    super.initState();
    // 화면이 로드될 때 데이터를 가져옵니다.
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
              // 버튼 영역
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedOrderType = null; // 전체 보기
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
                        selectedOrderType = OrderType.delivery; // 배송 필터링
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
                      print("매장 픽업 버튼 클릭");
                      setState(() {
                        selectedOrderType = OrderType.pickup; // 픽업 필터링
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
              const SizedBox(height: 30),

              // 주문 리스트
              BlocBuilder<OrderStatusBloc, OrderStatusState>(
                builder: (context, state) {
                  if (state is OrderStatusInitial) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is OrderFetch) {
                    final filteredOrders = selectedOrderType ==
                            null //selectedOrderType이 Null이면 전체 다 보여주기 만약에 아니면 선택된 Ordertype과 일치하는 Ordertype order만 보여주기
                        ? state.orders
                        : state.orders
                            .where(
                                (order) => order.orderType == selectedOrderType)
                            .toList();

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
                        final date = entry.key; // 날짜
                        final orders = entry.value; // 해당 날짜의 주문 목록

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 날짜 출력
                            Text(
                              date,
                              style: AppStyles.headingStyle,
                            ),
                            const SizedBox(height: 10),

                            // 해당 날짜의 주문 목록 출력
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

                                  // 상품 리스트 출력
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
                                            child: Column(
                                              // child로 Column 사용
                                              children: [
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.3,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.14,
                                                      child: Image.network(
                                                        item.productImageUrl, // 상품 이미지
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
                                                            item.productName, // 상품명
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: AppStyles
                                                                .subHeadingStyle,
                                                          ),
                                                          const SizedBox(
                                                              height: 5),
                                                          Text(
                                                            '수량: ${item.quantity}', // 수량
                                                            style: AppStyles
                                                                .smallTextStyle,
                                                          ),
                                                          const SizedBox(
                                                              height: 5),
                                                          Text(
                                                            '가격: ${intformatPrice(item.productPrice)}원', // 가격
                                                            style: AppStyles
                                                                .priceTextStyle,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 20),
                                              ],
                                            ),
                                          ),
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
                          '기간 내 주문내역이 없습니다', //만약 주문 내역이 없다면
                          style: TextStyle(
                            color: AppsColor.darkGray,
                            fontSize: 20,
                          ),
                        ),
                        //주문 내역이 있다면 해당 주문 내역을 보여준다
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
