import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/blocs/theme/theme_bloc.dart';
import 'package:onlyveyou/blocs/theme/theme_state.dart';
import 'package:onlyveyou/utils/styles.dart';

import 'package:kpostal/kpostal.dart';

class AddressSearchField extends StatefulWidget {
  final TextEditingController addressController; // 외부에서 전달받는 컨트롤러
  final TextEditingController detailedAddressController; // 외부에서 전달받는 컨트롤러

  const AddressSearchField({
    super.key,
    required this.addressController,
    required this.detailedAddressController,
  });

  @override
  State<AddressSearchField> createState() => _AddressSearchFieldState();
}

class _AddressSearchFieldState extends State<AddressSearchField> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeBloc>().state is ThemeDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('주소',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                )),
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
                controller: widget.addressController,
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
                  // print("주소 검색");

                  // KopoModel model = await Navigator.push(
                  //   context,
                  //   CupertinoPageRoute(
                  //     builder: (context) => RemediKopo(),
                  //   ),
                  // );
                  // _AddressController.text =
                  //     '${model.address!} ${model.buildingName!}';
                  // print(_AddressController.text);

                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return KpostalView(
                      callback: (Kpostal result) {
                        widget.addressController.text = result.address;
                      },
                    );
                  }));
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  side: BorderSide(
                    color: context.watch<ThemeBloc>().state is ThemeDark
                        ? Colors.white // 다크 모드 테두리 색상
                        : Colors.black, // 라이트 모드 테두리 색상
                    width: 1.5, // 테두리 두께
                  ),
                  backgroundColor: context.watch<ThemeBloc>().state is ThemeDark
                      ? Colors.grey[800] // 다크 모드 배경색
                      : Colors.black, // 라이트 모드 배경색
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
          controller: widget.detailedAddressController,
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
