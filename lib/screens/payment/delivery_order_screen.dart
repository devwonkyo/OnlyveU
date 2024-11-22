import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/payment/payment_bloc.dart';
import 'package:onlyveyou/blocs/payment/payment_event.dart';
import 'package:onlyveyou/blocs/payment/payment_state.dart';
import 'package:onlyveyou/blocs/theme/theme_bloc.dart';
import 'package:onlyveyou/blocs/theme/theme_state.dart';
import 'package:onlyveyou/models/delivery_info_model.dart';
import 'package:onlyveyou/utils/styles.dart';

class DeliveryOrderInfo extends StatelessWidget {
  final DeliveryInfoModel? deliveryInfo;
  final List<String> deliveryMessages;
  final VoidCallback? onAddressChange;
  final ValueChanged<String>? onDeliveryMessageSelected;

  const DeliveryOrderInfo({
    super.key,
    required this.deliveryInfo,
    required this.deliveryMessages,
    this.onAddressChange,
    this.onDeliveryMessageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeBloc>().state is ThemeDark;

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
          color: isDarkMode ? Colors.grey[800] : Colors.grey[400],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (recipientName.isEmpty)
                    Text(
                      '배송지를 등록해주세요',
                      style: AppStyles.headingStyle.copyWith(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  if (recipientName.isNotEmpty)
                    Text(
                      '$displayText ($recipientName)',
                      style: AppStyles.headingStyle.copyWith(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    '$address $detailAddress',
                    style: AppStyles.bodyTextStyle.copyWith(
                      color: isDarkMode ? Colors.grey[300] : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    recipientPhoneNumber,
                    style: AppStyles.bodyTextStyle.copyWith(
                      color: isDarkMode ? Colors.grey[300] : Colors.black,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: onAddressChange,
                child: Text(
                  '변경',
                  style: AppStyles.bodyTextStyle.copyWith(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Divider(
          height: 1,
          thickness: 6,
          color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
        ),
        _buildDeliveryMessageSection(context, isDarkMode),
      ],
    );
  }

  Widget _buildDeliveryMessageSection(BuildContext context, bool isDarkMode) {
    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, state) {
        String selectedMessage = '없음';
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
                style: AppStyles.headingStyle.copyWith(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
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
                            style: AppStyles.subHeadingStyle.copyWith(
                              color:
                                  isDarkMode ? Colors.grey[300] : Colors.black,
                            ),
                          ),
                        ))
                    .toList(),
                value: selectedMessage,
                onChanged: (value) {
                  if (value != null) {
                    onDeliveryMessageSelected?.call(value);
                    context
                        .read<PaymentBloc>()
                        .add(SelectDeliveryMessage(value));
                  }
                },
                buttonStyleData: ButtonStyleData(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[850] : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey,
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
}
