import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/payment/payment_bloc.dart';
import 'package:onlyveyou/blocs/payment/payment_event.dart';
import 'package:onlyveyou/models/delivery_info_model.dart';
import 'package:onlyveyou/screens/payment/widgets/address_search_field.dart';
import 'package:onlyveyou/screens/payment/widgets/custom_text_field.dart';
import 'package:onlyveyou/utils/styles.dart';

import '../../blocs/payment/payment_state.dart';

class NewDeliveryAddressScreen extends StatefulWidget {
  const NewDeliveryAddressScreen({super.key});

  @override
  State<NewDeliveryAddressScreen> createState() =>
      _NewDeliveryAddressScreenState();
}

class _NewDeliveryAddressScreenState extends State<NewDeliveryAddressScreen> {
  bool isChecked = false;

  final TextEditingController _deliveryNameController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _detailedAddressController =
      TextEditingController();

  @override
  void dispose() {
    _deliveryNameController.dispose();
    _recipientController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _detailedAddressController.dispose();
    super.dispose();
  }

  void _showWarningPopup(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('에러'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  bool _isFormFilled() {
    return _deliveryNameController.text.isNotEmpty &&
        _recipientController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _detailedAddressController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '새 배송지 추가',
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(
                height: 1,
                color: Colors.grey[400],
                thickness: 2,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _deliveryNameController,
                label: '배송지 명',
                hintText: '예) 올리브네 집, 회사 (최대 10자)',
                maxLength: 10,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _recipientController,
                label: '받으실 분',
                hintText: '최대 10자로 작성해주세요',
                maxLength: 10,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _phoneController,
                label: '휴대폰 번호',
                hintText: '010-0000-0000',
                maxLength: 13,
              ),
              const SizedBox(height: 20),
              AddressSearchField(
                addressController: _addressController,
                detailedAddressController: _detailedAddressController,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (value) {
                      setState(() {
                        isChecked = value!;
                      });
                    },
                  ),
                  Text(
                    '기본 배송지로 설정',
                    style: AppStyles.bodyTextStyle,
                  ),
                ],
              ),
              const SizedBox(height: 80),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.06,
                  child: BlocBuilder<PaymentBloc, PaymentState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: () {
                          if (_isFormFilled()) {
                            final updatedDeliveryInfo = DeliveryInfoModel(
                              deliveryName: _deliveryNameController.text,
                              address: _addressController.text,
                              detailAddress: _detailedAddressController.text,
                              recipientName: _recipientController.text,
                              recipientPhone: _phoneController.text,
                            );
                            context.read<PaymentBloc>().add(UpdateDeliveryInfo(
                                  deliveryName: _deliveryNameController.text,
                                  address: _addressController.text,
                                  detailAddress:
                                      _detailedAddressController.text,
                                  recipientName: _recipientController.text,
                                  recipientPhone: _phoneController.text,
                                ));
                            // Pop과 함께 데이터를 전달
                            Navigator.pop(context, updatedDeliveryInfo);
                            print("버튼 눌럿을 때 : $state");
                            //a화면 blocbuilder생성-> b화면에서 에빈트 발생 시, a화면에서 b에서 발생시킨 emit state 값을 못 가져온다
                          } else {
                            _showWarningPopup('모두 입력해주세요');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          '확인',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
