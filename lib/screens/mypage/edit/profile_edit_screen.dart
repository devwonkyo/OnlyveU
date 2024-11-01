import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/mypage/phone_number/phone_number_event.dart';
import 'package:onlyveyou/blocs/mypage/nickname_edit/nickname_edit_bloc.dart';
import 'package:onlyveyou/blocs/mypage/nickname_edit/nickname_edit_event.dart';
import 'package:onlyveyou/blocs/mypage/nickname_edit/nickname_edit_state.dart';
import 'package:onlyveyou/blocs/mypage/profile_edit/profile_edit_bloc.dart';
import 'package:onlyveyou/blocs/mypage/profile_edit/profile_edit_event.dart';
import 'package:onlyveyou/blocs/mypage/profile_edit/profile_edit_state.dart';
import 'package:onlyveyou/blocs/mypage/phone_number/phone_number_bloc.dart';

import 'package:onlyveyou/blocs/mypage/phone_number/phone_number_state.dart';
import 'package:onlyveyou/config/color.dart';
import 'package:onlyveyou/screens/mypage/widgets/profile_info_tile.dart';

class ProfileEditScreen extends StatelessWidget {
  const ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print("ProfileEditScreen - build() 호출");
    context.read<NicknameEditBloc>().add(LoadCurrentNickname());
    context.read<ProfileEditBloc>().add(LoadEmail());
    context.read<PhoneNumberBloc>().add(LoadPhoneNumber());

    print("빌드 됨");
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
            print("ProfileEditScreen - 뒤로가기 버튼 클릭");
            context.pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
          ),
        ),
      ),
      body: BlocListener<NicknameEditBloc, NicknameEditState>(
        listener: (context, state) {
          if (state is NicknameEditSuccess) {
            print("닉네임 변경 성공 - LoadCurrentNickname 호출");
            context.read<NicknameEditBloc>().add(LoadCurrentNickname());
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  print("ProfileEditScreen - 프로필 사진 선택 클릭");
                  context.read<ProfileEditBloc>().add(PickProfileImage());
                },
                child: BlocBuilder<ProfileEditBloc, ProfileEditState>(
                  builder: (context, state) {
                    if (state is ProfileImagePicked) {
                      print("ProfileEditScreen - ProfileImagePicked 상태");
                      return CircleAvatar(
                        radius: 45,
                        backgroundImage: FileImage(state.image),
                      );
                    } else {
                      print("ProfileEditScreen - 기본 프로필 이미지 상태");
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 닉네임 로드 상태 관리
                    BlocBuilder<NicknameEditBloc, NicknameEditState>(
                      builder: (context, state) {
                        String nickname = '닉네임을 불러오는 중...';
                        if (state is NicknameLoaded) {
                          nickname = state.nickname;
                          print(
                              "ProfileEditScreen - NicknameLoaded 상태: $nickname");
                        } else if (state is NicknameEditInProgress ||
                            state is NicknameLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        return ProfileInfoTile(
                          title: "닉네임",
                          trailingText: nickname,
                          onTap: () {
                            print("ProfileEditScreen - 닉네임 수정 화면으로 이동");
                            context.push('/nickname_edit');
                          },
                        );
                      },
                    ),
                    // 이메일 로드 상태 관리
                    BlocBuilder<ProfileEditBloc, ProfileEditState>(
                      builder: (context, state) {
                        if (state is EmailLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else if (state is EmailLoaded) {
                          return ProfileInfoTile(
                            title: "이메일 확인",
                            trailingText: state.email,
                            onTap: () {
                              print("ProfileEditScreen - 이메일 확인 클릭");
                            },
                          );
                        }
                        return ProfileInfoTile(
                          title: "이메일 확인",
                          trailingText: "이메일을 불러오는 중...",
                          onTap: () {},
                        );
                      },
                    ),

                    ProfileInfoTile(
                      title: "비밀번호 변경",
                      onTap: () {
                        print("ProfileEditScreen - 비밀번호 변경 화면으로 이동");
                        context.push('/verify_password');
                      },
                    ),
                    // 전화번호 로드 상태 관리
                    BlocBuilder<PhoneNumberBloc, PhoneNumberState>(
                      builder: (context, state) {
                        if (state is PhoneNumberLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else if (state is PhoneNumberLoaded) {
                          return ProfileInfoTile(
                            title: "휴대폰 번호 변경",
                            trailingText: state.phoneNumber,
                            onTap: () {
                              print("ProfileEditScreen - 휴대폰 번호 확인 클릭");
                              context.push('/phone_number_edit');
                            },
                          );
                        }
                        return ProfileInfoTile(
                          title: "휴대폰 번호 확인",
                          trailingText: "번호 불러오는 중...",
                          onTap: () {},
                        );
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
                      print("ProfileEditScreen - 로그아웃 클릭");
                    },
                    child: const Text(
                      '로그아웃',
                      style: TextStyle(color: AppsColor.darkGray),
                    ),
                  ),
                  const Text('|'),
                  TextButton(
                    onPressed: () {
                      print("ProfileEditScreen - 회원 탈퇴 클릭");
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
      ),
    );
  }
}
