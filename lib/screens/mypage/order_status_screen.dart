import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/blocs/mypage/order_status/order_status_bloc.dart';
import 'package:onlyveyou/blocs/mypage/order_status/order_status_event.dart';
import 'package:onlyveyou/blocs/mypage/order_status/order_status_state.dart';
import 'package:onlyveyou/models/order_model.dart';
import 'package:onlyveyou/utils/format_price.dart';
import 'package:onlyveyou/utils/styles.dart';
import 'package:intl/intl.dart';

class OrderStatusScreen extends StatefulWidget {
  const OrderStatusScreen({super.key});

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  @override
  void initState() {
    super.initState();
    // 화면이 로드될 때 데이터를 가져옵니다.
    context.read<OrderStatusBloc>().add(const FetchOrder());
  }

  @override
  Widget build(BuildContext context) {
    String? selectedOrderType; // 선택된 주문 타입 (null이면 전체)
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
                      style: AppStyles.subHeadingStyle,
                    ),
                  ),
                  const SizedBox(width: 15),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedOrderType = 'delivery'; // 배송 필터링
                      });
                    },
                    child: Text(
                      '배송',
                      style: AppStyles.subHeadingStyle,
                    ),
                  ),
                  const SizedBox(width: 15),
                  GestureDetector(
                    onTap: () {
                      print("매장 픽업 버튼 클릭");
                      setState(() {
                        selectedOrderType = 'pickup'; // 픽업 필터링
                      });
                    },
                    child: Text(
                      '매장픽업',
                      style: AppStyles.subHeadingStyle,
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
                    // 날짜별로 주문 데이터를 그룹화
                    final filteredOrders = selectedOrderType == null
                        ? state.orders // 전체 보기
                        : state.orders.where((order) {
                            return order.orderType == selectedOrderType;
                          }).toList();

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
                                    order.status.name, // 주문 상태
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
                                          Row(
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
                                                  item.productImageUrl, // 상품 이미지
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item.productName, // 상품명
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: AppStyles
                                                          .subHeadingStyle,
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      '수량: ${item.quantity}', // 수량
                                                      style: AppStyles
                                                          .smallTextStyle,
                                                    ),
                                                    const SizedBox(height: 5),
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
                                          const SizedBox(
                                            height: 20,
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
                    return const Center(child: Text('No orders found'));
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
