import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/blocs/payment/payment_bloc.dart';
import 'package:onlyveyou/blocs/payment/payment_event.dart';
import 'package:onlyveyou/blocs/payment/payment_state.dart';
import 'package:onlyveyou/utils/styles.dart';

class PaymentScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '주문/결제',
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            height: 1,
            color: Colors.grey[400],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '배송지를 등록해 주세요',
                  style: AppStyles.headingStyle,
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    '변경',
                    style: AppStyles.bodyTextStyle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Divider(
            height: 1,
            thickness: 6,
            color: Colors.grey[200],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Text(
              '배송 요청사항',
              style: AppStyles.headingStyle,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          BlocBuilder<PaymentBloc, PaymentState>(
            builder: (context, state) {
              String selectedMessage = '배송 메시지를 선택해주세요.';
              if (state is PaymentMessageSelected) {
                selectedMessage = state.selectedMessage;
              }
              return DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  items: deliveryMessages
                      .map((message) => DropdownMenuItem<String>(
                            value: message,
                            child: Text(
                              message,
                              style: const TextStyle(fontSize: 14),
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
                        color: Colors.grey, // 테두리 색상 설정
                        width: 1.0, // 테두리 두께 설정
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
