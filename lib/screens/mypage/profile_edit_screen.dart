import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/mypage/profile_edit/profile_edit_bloc.dart';
import 'package:onlyveyou/blocs/mypage/profile_edit/profile_edit_event.dart';
import 'package:onlyveyou/blocs/mypage/profile_edit/profile_edit_state.dart';
import 'package:onlyveyou/config/color.dart';

class ProfileEditScreen extends StatelessWidget {
  const ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '내 정보 수정',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            // context.pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: () {
                // 프로필 사진 선택 이벤트 호출
                context.read<ProfileEditBloc>().add(PickProfileImage());
              },
              child: BlocBuilder<ProfileEditBloc, ProfileEditState>(
                builder: (context, state) {
                  // 선택된 이미지가 있는 경우 그 이미지를 표시, 아니면 기본 아이콘 표시
                  if (state is ProfileImagePicked) {
                    // 선택된 이미지가 있을 경우
                    return CircleAvatar(
                      radius: 45,
                      backgroundImage: FileImage(state.image),
                    );
                  } else {
                    // 선택된 이미지가 없을 경우 - 기본 아이콘 표시
                    return const Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: AppsColor.pastelGreen,
                          child: Icon(
                            Icons.person,
                            size: 70,
                            color: AppsColor.lightGray,
                          ),
                        ),
                        CircleAvatar(
                          radius: 15,
                          backgroundColor: AppsColor.lightGray,
                          child: Icon(
                            Icons.camera_alt,
                            size: 16,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
