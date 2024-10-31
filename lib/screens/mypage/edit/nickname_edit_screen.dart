import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/mypage/nickname_edit/nickname_edit_bloc.dart';
import 'package:onlyveyou/blocs/mypage/nickname_edit/nickname_edit_event.dart';
import 'package:onlyveyou/blocs/mypage/nickname_edit/nickname_edit_state.dart';
import 'package:onlyveyou/config/color.dart';

class NicknameEditScreen extends StatelessWidget {
  const NicknameEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NicknameEditBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '닉네임 변경',
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
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                '새로운 닉네임을 입력해주세요',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              BlocBuilder<NicknameEditBloc, NicknameEditState>(
                builder: (context, state) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    width: double.infinity,
                    child: TextField(
                      onChanged: (value) {
                        context
                            .read<NicknameEditBloc>()
                            .add(NicknameChanged(value));
                      },
                      decoration: const InputDecoration(
                        hintText: 'jb5767sy', // 원래 User 닉네임 값을 hinttext로
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                      ),
                    ),
                  );
                },
              ),
              const Spacer(),
              BlocBuilder<NicknameEditBloc, NicknameEditState>(
                builder: (context, state) {
                  bool isButtonEnabled =
                      state is NicknameEditing ? state.isButtonEnabled : false;
                  return SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.06,
                    child: ElevatedButton(
                      onPressed: isButtonEnabled
                          ? () {
                              context
                                  .read<NicknameEditBloc>()
                                  .add(SubmitNicknameChange());
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
