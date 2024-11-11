import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/payment/payment_bloc.dart';
import 'package:onlyveyou/blocs/payment/payment_event.dart';
import 'package:onlyveyou/blocs/payment/payment_state.dart';
import 'package:onlyveyou/models/order_item_model.dart';
import 'package:onlyveyou/utils/styles.dart';

class PaymentScreen extends StatefulWidget {
  final List<String> deliveryMessages = [
    '배송 메시지를 선택해주세요.',
    '그냥 문 앞에 놓아 주시면 돼요.',
    '직접 받을게요.(부재 시 문앞)',
    '벨을 누르지 말아주세요.',
    '도착 후 전화주시면 직접 받으러 갈게요.',
    '직접 입력하기'
  ];
  PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  void initState() {
    super.initState();
    // 주문 상품 가져오기 이벤트 추가
    context.read<PaymentBloc>().add(const FetchOrderItems());
  }

  String _selectedPaymentMethod = '빠른결제';
  bool _saveAsDefault = false;
  bool _agreeToAll = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '주문/결제',
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(
              height: 1,
              color: Colors.grey[400],
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '배송지를 등록해 주세요',
                    style: AppStyles.headingStyle,
                  ),
                  TextButton(
                    onPressed: () {
                      _showModalBottomSheet(context);
                    },
                    child: Text(
                      '변경',
                      style: AppStyles.bodyTextStyle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Divider(
              height: 1,
              thickness: 6,
              color: Colors.grey[200],
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Text(
                '배송 요청사항',
                style: AppStyles.headingStyle,
              ),
            ),
            const SizedBox(height: 10),
            BlocBuilder<PaymentBloc, PaymentState>(
              builder: (context, state) {
                String selectedMessage = '배송 메시지를 선택해주세요.';
                if (state is PaymentMessageSelected) {
                  selectedMessage = state.selectedMessage;
                }
                return DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    items: widget.deliveryMessages
                        .map((message) => DropdownMenuItem<String>(
                              value: message,
                              child: Text(
                                message,
                                style: AppStyles.subHeadingStyle,
                              ),
                            ))
                        .toList(),
                    value: selectedMessage,
                    onChanged: (value) {
                      if (value != null) {
                        context
                            .read<PaymentBloc>()
                            .add(SelectDeliveryMessage(value));
                      }
                    },
                    buttonStyleData: const ButtonStyleData(
                      height: 50,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Divider(
              height: 1,
              color: Colors.grey[200],
              thickness: 10,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '주문 상품',
                    style: AppStyles.headingStyle,
                  ),
                  const SizedBox(height: 10),
                  // payment_screen.dart
                  // payment_screen.dart
                  BlocBuilder<PaymentBloc, PaymentState>(
                    builder: (context, state) {
                      List<OrderItemModel> orderItems = [];
                      if (state is PaymentLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is PaymentLoaded) {
                        orderItems = state.orderItems;
                      } else if (state is PaymentMessageSelected) {
                        orderItems = state.orderItems; // 배송 메시지 선택 시 주문 상품 유지
                      } else if (state is PaymentError) {
                        return Center(child: Text(state.message));
                      }

                      // 주문 상품 리스트 UI 표시
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: orderItems.length,
                        itemBuilder: (context, index) {
                          final item = orderItems[index];
                          return ListTile(
                            leading: SizedBox(
                              width: 50,
                              height: 50,
                              child: Image.network(
                                item.productImageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(item.productName),
                            subtitle: Text('수량: ${item.quantity}'),
                            trailing: Text(
                              '${item.productPrice * item.quantity}원',
                              style: AppStyles.bodyTextStyle,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
            Divider(
              height: 1,
              thickness: 5,
              color: Colors.grey[200],
            ),
            const SizedBox(height: 10),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: BlocBuilder<PaymentBloc, PaymentState>(
                builder: (context, state) {
                  int totalAmount = 0;

                  if (state is PaymentLoaded) {
                    totalAmount = state.totalAmount;
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '최종 결제금액',
                        style: AppStyles.headingStyle,
                      ),
                      Text(
                        '$totalAmount원',
                        style: AppStyles.headingStyle,
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Divider(
              height: 1,
              thickness: 5,
              color: Colors.grey[200],
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Text(
                '결제 수단',
                style: AppStyles.headingStyle,
              ),
            ),
            Divider(
              height: 1,
              color: Colors.grey[200],
              thickness: 1,
            ),
            const SizedBox(height: 10),

            // "빠른결제" Option
            RadioListTile(
              value: '빠른결제',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value.toString();
                });
              },
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('빠른결제', style: AppStyles.bodyTextStyle),
                  const Icon(Icons.info_outline, color: Colors.grey, size: 18),
                ],
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),

            // Card Registration Button
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.17,
                child: OutlinedButton(
                  onPressed: () {
                    // Handle card registration action
                    print("결제 카드 등록 버튼 클릭");
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, size: 40, color: Colors.grey),
                      const SizedBox(height: 10),
                      Text(
                        '자주 사용하는 카드나 계좌를 등록하고\n더욱 빠르게 결제할 수 있습니다.',
                        style: AppStyles.smallTextStyle,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• 빠른결제 이용 시 더블적립 혜택이나 KB알파원카드 혜택은 적용되지 않습니다.',
                    style: AppStyles.smallTextStyle,
                  ),
                  Text(
                    '• 등록하신 결제수단이나 원터치결제 관리는 마이페이지 > 마이월렛 > 빠른결제 관리에서 가능합니다.',
                    style: AppStyles.smallTextStyle,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // "일반결제" Option
            RadioListTile(
              value: '일반결제',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value.toString();
                });
              },
              title: Text('일반결제', style: AppStyles.bodyTextStyle),
              controlAffinity: ListTileControlAffinity.leading,
            ),

            const SizedBox(height: 20),

            Divider(
              height: 1,
              color: Colors.grey[200],
              thickness: 10,
            ),

            // Agreement Checkbox
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Checkbox(
                    value: _saveAsDefault,
                    onChanged: (value) {
                      setState(() {
                        _saveAsDefault = value ?? false;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '지금 설정한 배송지와 결제정보를 기본으로 사용하기',
                      style: AppStyles.bodyTextStyle,
                    ),
                  ),
                ],
              ),
            ),

            // Agree to All Checkbox
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Checkbox(
                    value: _agreeToAll,
                    onChanged: (value) {
                      setState(() {
                        _agreeToAll = value ?? false;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '모두 동의합니다.',
                      style: AppStyles.bodyTextStyle,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Total Price Button
            BlocBuilder<PaymentBloc, PaymentState>(
              builder: (context, state) {
                int totalAmount = 0;

                if (state is PaymentLoaded) {
                  totalAmount = state.totalAmount;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle payment action
                        print("결제하기 버튼");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        '$totalAmount원 결제하기',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

void _showModalBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.2,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Column(
          children: [
            Container(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('배송지 변경', style: AppStyles.headingStyle),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 20,
                      ),
                      onPressed: () {
                        context.pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12)),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton(
                onPressed: () {
                  //새 배송지 추가 화면
                  context.pop();
                  context.push('/new_delivery_address');
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black54,
                  padding: const EdgeInsets.all(10.0),
                  textStyle: const TextStyle(fontSize: 12),
                ),
                child: Text(
                  '새 배송지 추가',
                  style: AppStyles.bodyTextStyle,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
