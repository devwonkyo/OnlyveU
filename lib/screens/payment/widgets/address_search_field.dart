import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onlyveyou/utils/styles.dart';
import 'package:remedi_kopo/remedi_kopo.dart';

class AddressSearchField extends StatefulWidget {
  const AddressSearchField({super.key});

  @override
  State<AddressSearchField> createState() => _AddressSearchFieldState();
}

class _AddressSearchFieldState extends State<AddressSearchField> {
  final TextEditingController _AddressController = TextEditingController();

  @override
  void dispose() {
    _AddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '주소',
              style: AppStyles.headingStyle,
            ),
            const Text(
              ' *',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _AddressController,
                decoration: InputDecoration(
                  hintText: '주소를 검색해주세요',
                  hintStyle: const TextStyle(color: Colors.grey),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.053,
              child: ElevatedButton(
                onPressed: () async {
                  // 주소 검색 기능
                  print("주소 검색");

                  KopoModel? model = await Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => RemediKopo(),
                    ),
                  );

                  // null 체크
                  if (model != null) {
                    _AddressController.text =
                        '${model.address!} ${model.buildingName ?? ''}';
                    print(_AddressController.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text(
                  '주소검색',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(
            hintText: '상세주소를 입력해주세요',
            hintStyle: const TextStyle(color: Colors.grey),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
