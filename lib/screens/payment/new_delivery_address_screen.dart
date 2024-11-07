import 'package:flutter/material.dart';
import 'package:onlyveyou/screens/payment/widgets/address_search_field.dart';
import 'package:onlyveyou/screens/payment/widgets/custom_text_field.dart';
import 'package:onlyveyou/utils/styles.dart';

class NewDeliveryAddressScreen extends StatefulWidget {
  const NewDeliveryAddressScreen({super.key});

  @override
  State<NewDeliveryAddressScreen> createState() =>
      _NewDeliveryAddressScreenState();
}

class _NewDeliveryAddressScreenState extends State<NewDeliveryAddressScreen> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '새 배송지 추가',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(
              height: 1,
              color: Colors.grey[400],
              thickness: 2,
            ),
            const SizedBox(
              height: 20,
            ),
            const CustomTextField(
              label: '배송지 명',
              hintText: '예) 올리브네 집, 회사 (최대 10자)',
              maxLength: 10,
            ),
            const SizedBox(height: 20),
            const CustomTextField(
              label: '받으실 분',
              hintText: '최대 10자로 작성해주세요',
              maxLength: 10,
            ),
            const SizedBox(height: 20),
            const CustomTextField(
              label: '휴대폰 번호',
              hintText: '010-0000-0000',
              maxLength: 13,
            ),
            const SizedBox(
              height: 20,
            ),

             AddressSearchField(), // 새로운 커스텀 위젯
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
            const SizedBox(
              height: 80,
            ),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.06,
                child: ElevatedButton(
                  onPressed: () {},
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
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
