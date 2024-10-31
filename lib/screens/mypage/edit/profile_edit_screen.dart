import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/mypage/profile_edit/profile_edit_bloc.dart';
import 'package:onlyveyou/blocs/mypage/profile_edit/profile_edit_event.dart';
import 'package:onlyveyou/blocs/mypage/profile_edit/profile_edit_state.dart';
import 'package:onlyveyou/config/color.dart';
import 'package:onlyveyou/screens/mypage/widgets/profile_info_tile.dart';

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
            context.pop();
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
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                // 프로필 사진 선택 이벤트 호출
                context.read<ProfileEditBloc>().add(PickProfileImage());
              },
              child: BlocBuilder<ProfileEditBloc, ProfileEditState>(
                builder: (context, state) {
                  if (state is ProfileImagePicked) {
                    return CircleAvatar(
                      radius: 45,
                      backgroundImage: FileImage(state.image),
                    );
                  } else {
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
            const SizedBox(height: 50),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // 컨테이너의 높이를 내용에 맞춤
                children: [
                  ProfileInfoTile(
                    title: "닉네임",
                    trailingText: "jb5767sy",
                    onTap: () {
                      // 닉네임 수정 화면으로 이동
                      context.push('/nickname_edit');
                    },
                  ),
                  ProfileInfoTile(
                    title: "이메일 변경",
                    trailingText: "rlatjddus5767@naver.com",
                    onTap: () {
                      // 이메일 변경 화면으로 이동
                      context.push('/email_edit');
                    },
                  ),
                  ProfileInfoTile(
                    title: "비밀번호 변경",
                    onTap: () {
                      // 비밀번호 변경 화면으로 이동
                      context.push('/verify_password');
                    },
                  ),
                  ProfileInfoTile(
                    title: "휴대폰 번호 변경",
                    onTap: () {
                      // 전화번호 변경 화면으로 이동
                      context.push('/phone_number_edit');
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    // 로그아웃 기능 로직
                  },
                  child: const Text(
                    '로그아웃',
                    style: TextStyle(color: AppsColor.darkGray),
                  ),
                ),
                const Text('|'),
                TextButton(
                  onPressed: () {
                    // 회원 탈퇴 기능 로직
                  },
                  child: const Text(
                    '회원 탈퇴',
                    style: TextStyle(color: AppsColor.darkGray),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
