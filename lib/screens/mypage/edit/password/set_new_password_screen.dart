import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/blocs/mypage/set_new_password/set_new_password_bloc.dart';
import 'package:onlyveyou/blocs/mypage/set_new_password/set_new_password_event.dart';
import 'package:onlyveyou/blocs/mypage/set_new_password/set_new_password_state.dart';
import 'package:onlyveyou/config/color.dart';

class SetNewPasswordScreen extends StatelessWidget {
  const SetNewPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '비밀번호 변경',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '새로운 비밀번호를 입력해주세요',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            BlocBuilder<SetNewPasswordBloc, SetNewPasswordState>(
              //비밀번호와 비밀번호 확인 TextField 입력을 처리
              builder: (context, state) {
                return Column(
                  children: [
                    TextField(
                      obscureText: true,
                      onChanged: (value) {
                        context
                            .read<SetNewPasswordBloc>()
                            .add(NewPasswordChanged(value));
                      },
                      decoration: InputDecoration(
                        hintText: '새로운 비밀번호',
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      obscureText: true,
                      onChanged: (value) {
                        context
                            .read<SetNewPasswordBloc>()
                            .add(ConfirmPasswordChanged(value));
                      },
                      decoration: InputDecoration(
                        hintText: '비밀번호 확인',
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                  ],
                );
              },
            ),
            const Spacer(),
            BlocBuilder<SetNewPasswordBloc, SetNewPasswordState>(
              //변경 완료 버튼의 활성화 여부를 상태(isButtonEnabled)에 따라 결정
              builder: (context, state) {
                bool isButtonEnabled =
                    state is SetNewPasswordEditing && state.isButtonEnabled;

                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isButtonEnabled
                        ? () {
                            context
                                .read<SetNewPasswordBloc>()
                                .add(SubmitNewPassword());
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isButtonEnabled
                          ? AppsColor.pastelGreen
                          : Colors.grey[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '변경 완료',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
