import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/mypage/phone_number/phone_number_bloc.dart';
import 'package:onlyveyou/blocs/mypage/phone_number/phone_number_event.dart';
import 'package:onlyveyou/blocs/mypage/phone_number/phone_number_state.dart';
import 'package:onlyveyou/config/color.dart';

class PhoneNumberEditScreen extends StatelessWidget {
  const PhoneNumberEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '휴대폰 번호 변경',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: BlocListener<PhoneNumberBloc, PhoneNumberState>(
        listener: (context, state) {
          if (state is PhoneNumberInitial) {
            context.read<PhoneNumberBloc>().add(LoadPhoneNumber());
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                '새로운 휴대폰 번호를 입력해주세요',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              BlocBuilder<PhoneNumberBloc, PhoneNumberState>(
                builder: (context, state) {
                  String hintText = '휴대폰 번호를 입력하세요';
                  if (state is PhoneNumberLoaded) {
                    hintText = state.phoneNumber;
                  }
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    width: double.infinity,
                    child: TextField(
                      keyboardType: TextInputType.phone,
                      onChanged: (value) {
                        context
                            .read<PhoneNumberBloc>()
                            .add(PhoneNumberChanged(value));
                      },
                      decoration: InputDecoration(
                        hintText: hintText,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 14),
                      ),
                    ),
                  );
                },
              ),
              const Spacer(),
              BlocBuilder<PhoneNumberBloc, PhoneNumberState>(
                builder: (context, state) {
                  bool isButtonEnabled = state is PhoneNumberEditing
                      ? state.isButtonEnabled
                      : false;
                  String phoneNumber =
                      state is PhoneNumberEditing ? state.phoneNumber : '';

                  return SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.06,
                    child: ElevatedButton(
                      onPressed: isButtonEnabled
                          ? () {
                              print("휴대폰 번호 변경 버튼 클릭: $phoneNumber");
                              context
                                  .read<PhoneNumberBloc>()
                                  .add(SubmitPhoneNumberChange(phoneNumber));
                              context.pop(); // 이전 화면으로 돌아감
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isButtonEnabled
                            ? AppsColor.pastelGreen
                            : Colors.grey[400],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '변경 완료',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
