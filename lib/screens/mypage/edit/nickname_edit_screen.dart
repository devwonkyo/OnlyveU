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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '닉네임 변경',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: BlocListener<NicknameEditBloc, NicknameEditState>(
        listener: (context, state) {
          if (state is NicknameEditInitial) {
            context.read<NicknameEditBloc>().add(LoadCurrentNickname());
          }
        },
        child: Padding(
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
                  String hintText = '닉네임을 입력하세요';
                  if (state is NicknameLoaded) {
                    hintText = state.nickname;
                  }

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    width: double.infinity,
                    child: TextField(
                      onChanged: (value) {
                        context
                            .read<NicknameEditBloc>()
                            .add(NicknameChanged(value));
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
              BlocBuilder<NicknameEditBloc, NicknameEditState>(
                builder: (context, state) {
                  bool isButtonEnabled =
                      state is NicknameEditing ? state.isButtonEnabled : false;
                  String nickname =
                      state is NicknameEditing ? state.nickname : '';

                  return SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.06,
                    child: ElevatedButton(
                      onPressed: isButtonEnabled
                          ? () async {
                              print("닉네임 변경 버튼 클릭: $nickname");

                              // 닉네임 변경 및 상태 갱신이 완료될 때까지 대기
                              context
                                  .read<NicknameEditBloc>()
                                  .add(SubmitNicknameChange(nickname));

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
