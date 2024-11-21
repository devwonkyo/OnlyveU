import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/mypage/password/password_bloc.dart';
import 'package:onlyveyou/blocs/mypage/password/password_event.dart';
import 'package:onlyveyou/blocs/mypage/password/password_state.dart';
import 'package:onlyveyou/config/color.dart';

class VerifyCurrentPasswordScreen extends StatelessWidget {
  const VerifyCurrentPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '비밀번호 변경',
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<PasswordBloc, PasswordState>(
        listener: (context, state) {
          if (state is PasswordEditSuccess) {
            // 비밀번호 확인 성공 시 '/set_new_password' 경로로 이동
            context.push('/set_new_password');
          } else if (state is PasswordVerificationFailure) {
            // 비밀번호 확인 실패 시 메시지 표시
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '안전한 변경을 위해 현재 비밀번호를 확인할게요',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              BlocBuilder<PasswordBloc, PasswordState>(
                //textfield 관련 blocbuilder
                builder: (context, state) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    width: double.infinity,
                    child: TextField(
                      obscureText: true,
                      onChanged: (value) {
                        context
                            .read<PasswordBloc>()
                            .add(PasswordChanged(value));
                      },
                      decoration: const InputDecoration(
                        hintText: '현재 비밀번호',
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                      ),
                    ),
                  );
                },
              ),
              const Spacer(),
              BlocBuilder<PasswordBloc, PasswordState>(
                //버튼 활성화 관련 blocbuilder
                builder: (context, state) {
                  bool isButtonEnabled =
                      state is PasswordEditing && state.isButtonEnabled;

                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isButtonEnabled
                          ? () {
                              context
                                  .read<PasswordBloc>()
                                  .add(SubmitPasswordChange());
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
                        '다음',
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
      ),
    );
  }
}
