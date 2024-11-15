import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/payment/payment_bloc.dart';
import 'package:onlyveyou/blocs/payment/payment_event.dart';
import 'package:onlyveyou/blocs/payment/payment_state.dart';
import 'package:onlyveyou/models/delivery_info_model.dart';

import 'package:onlyveyou/utils/styles.dart';

class DeliveryOrderInfo extends StatelessWidget {
  final DeliveryInfoModel? deliveryInfo;
  final List<String> deliveryMessages;
  final VoidCallback? onAddressChange; // 콜백 추가
  const DeliveryOrderInfo({
    super.key,
    required this.deliveryInfo,
    required this.deliveryMessages,
    this.onAddressChange, // 콜백 초기화
  });

  @override
  Widget build(BuildContext context) {
    // 배송지 정보 표시 부분
    String displayText = '';
    String address = '';
    String detailAddress = '';
    String recipientName = '';
    String recipientPhoneNumber = '';

    if (deliveryInfo != null) {
      displayText = deliveryInfo!.deliveryName;
      address = deliveryInfo!.address;
      detailAddress = deliveryInfo!.detailAddress;
      recipientName = deliveryInfo!.recipientName;
      recipientPhoneNumber = deliveryInfo!.recipientPhone;
    }

    return Column(
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // recipientName이 null이거나 비어있을 때만 '배송지를 등록해주세요' 텍스트를 표시
                  if (recipientName.isEmpty)
                    Text(
                      '배송지를 등록해주세요',
                      style: AppStyles.headingStyle,
                    ),
                  // recipientName이 있을 때는 배송지 정보를 표시
                  if (recipientName.isNotEmpty)
                    Text(
                      '$displayText ($recipientName)',
                      style: AppStyles.headingStyle,
                    ),
                  const SizedBox(height: 10),
                  Text(
                    '$address $detailAddress',
                    style: AppStyles.bodyTextStyle,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    recipientPhoneNumber,
                    style: AppStyles.bodyTextStyle,
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  //_showModalBottomSheet(context);
                  onAddressChange!(); // 콜백 함수 호출
                  //원래는 modalbottomsheet를 띄웠지만 상태관리 문제가 있을 수 있다고 판단하여 주석처리
                  //라우터에 문제가 있을 확률은?

                  // 배송지
                  // context.push('/new_delivery_address');
                },
                child: Text(
                  '변경',
                  style: AppStyles.bodyTextStyle,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Divider(
          height: 1,
          thickness: 6,
          color: Colors.grey[200],
        ),
        // 배송 요청사항 표시 부분
        _buildDeliveryMessageSection(context),
      ],
    );
  }

  // 배송 요청사항 섹션을 별도의 메서드로 분리
  Widget _buildDeliveryMessageSection(BuildContext context) {
    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, state) {
        String selectedMessage = '배송 메시지를 선택해주세요.';
        if (state is PaymentMessageSelected) {
          selectedMessage = state.selectedMessage;
        } else if (state is DeliveryInfoUpdated &&
            state.deliveryInfo.deliveryRequest != null) {
          selectedMessage = state.deliveryInfo.deliveryRequest!;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Text(
                '배송 요청사항',
                style: AppStyles.headingStyle,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                items: deliveryMessages
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
            ),
          ],
        );
      },
    );
  }

  // _showModalBottomSheet 함수도 위젯 내부로 이동
  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        // 모달 바텀 시트 내용 구현
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
              // 모달 바텀 시트 헤더
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('배송지 변경', style: AppStyles.headingStyle),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        context.pop();
                      },
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.black12),
              const SizedBox(height: 50),
              // 새 배송지 추가 버튼
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton(
                  onPressed: () {
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
}
