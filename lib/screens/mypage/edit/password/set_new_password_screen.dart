import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/mypage/set_new_password/set_new_password_bloc.dart';
import 'package:onlyveyou/blocs/mypage/set_new_password/set_new_password_event.dart';
import 'package:onlyveyou/blocs/mypage/set_new_password/set_new_password_state.dart';
import 'package:onlyveyou/config/color.dart';
import 'package:onlyveyou/core/router.dart';

class SetNewPasswordScreen extends StatelessWidget {
  const SetNewPasswordScreen({super.key});

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
            onPressed: () => context.pop()),
      ),
      body: BlocListener<SetNewPasswordBloc, SetNewPasswordState>(
        listener: (context, state) {
          if (state is SetNewPasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("비밀번호가 성공적으로 변경되었습니다.")),
            );
            context.pop();
            context.pop();
          } else if (state is SetNewPasswordFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        child: Padding(
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
                        decoration: const InputDecoration(
                          hintText: '새로운 비밀번호',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
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
                        decoration: const InputDecoration(
                          hintText: '비밀번호 확인',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const Spacer(),
              BlocBuilder<SetNewPasswordBloc, SetNewPasswordState>(
                builder: (context, state) {
                  bool isButtonEnabled =
                      state is SetNewPasswordEditing && state.isButtonEnabled;

                  // 비밀번호 변경 중일 때 로딩 인디케이터 표시
                  if (state is SetNewPasswordInProgress) {
                    return const Center(child: CircularProgressIndicator());
                  }

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
      ),
    );
  }
}
