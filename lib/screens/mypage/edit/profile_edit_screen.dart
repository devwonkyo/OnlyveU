import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/auth/auth_bloc.dart';
import 'package:onlyveyou/blocs/auth/auth_event.dart';
import 'package:onlyveyou/blocs/auth/auth_state.dart';
import 'package:onlyveyou/blocs/mypage/nickname_edit/nickname_edit_bloc.dart';
import 'package:onlyveyou/blocs/mypage/nickname_edit/nickname_edit_event.dart';
import 'package:onlyveyou/blocs/mypage/nickname_edit/nickname_edit_state.dart';
import 'package:onlyveyou/blocs/mypage/phone_number/phone_number_bloc.dart';
import 'package:onlyveyou/blocs/mypage/phone_number/phone_number_event.dart';
import 'package:onlyveyou/blocs/mypage/phone_number/phone_number_state.dart';
import 'package:onlyveyou/blocs/mypage/profile_edit/profile_edit_bloc.dart';
import 'package:onlyveyou/blocs/mypage/profile_edit/profile_edit_event.dart';
import 'package:onlyveyou/blocs/mypage/profile_edit/profile_edit_state.dart';
import 'package:onlyveyou/config/color.dart';
import 'package:onlyveyou/screens/mypage/widgets/profile_info_tile.dart';
import 'package:onlyveyou/utils/styles.dart';

class ProfileEditScreen extends StatelessWidget {
  const ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // initState와 같은 효과를 위해 build 메서드 시작 부분에서 한 번만 호출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<NicknameEditBloc>().add(LoadCurrentNickname());
        context.read<ProfileEditBloc>().add(LoadEmail());
        context.read<PhoneNumberBloc>().add(LoadPhoneNumber());
      }
    });

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LogoutSuccess || state is DeleteAccountSuccess) {
          context.go('/login');
        }
      },
      child: Scaffold(
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
                          if (state is NicknameLoading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          } else if (state is NicknameLoaded) {
                            print(
                                "ProfileEditScreen - NicknameLoaded 상태: ${state.nickname}");
                            return ProfileInfoTile(
                              title: "닉네임",
                              trailingText: state.nickname,
                              onTap: () {
                                print("ProfileEditScreen - 닉네임 수정 화면으로 이동");
                                context.push('/nickname_edit');
                              },
                            );
                          } else if (state is NicknameEditFailure) {
                            return ProfileInfoTile(
                              title: "닉네임",
                              trailingText: "오류: ${state.errorMessage}",
                              onTap: () {
                                print("ProfileEditScreen - 닉네임 수정 화면으로 이동");
                                context.push('/nickname_edit');
                              },
                            );
                          }

                          return ProfileInfoTile(
                            title: "닉네임",
                            trailingText: "닉네임을 불러오는 중...",
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
                            return ProfileInfoTile(
                              title: "이메일 확인",
                              trailingText: "이메일을 불러오는 중...",
                              onTap: () {}, // 빈 함수 전달
                            );
                          } else if (state is EmailLoaded) {
                            return ProfileInfoTile(
                              title: "이메일 확인",
                              trailingText: state.email,
                              onTap: () {
                                print("ProfileEditScreen - 이메일 확인 클릭");
                              },
                            );
                          } else if (state is ProfileEditError) {
                            return ProfileInfoTile(
                              title: "이메일 확인",
                              trailingText: "이메일 로드 실패",
                              onTap: () {
                                context
                                    .read<ProfileEditBloc>()
                                    .add(LoadEmail());
                              },
                            );
                          }
                          return ProfileInfoTile(
                            title: "이메일 확인",
                            trailingText: "이메일을 불러오는 중...",
                            onTap: () {
                              context.read<ProfileEditBloc>().add(LoadEmail());
                            },
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
                            return ProfileInfoTile(
                              title: "휴대폰 번호 변경",
                              trailingText: "번호를 불러오는 중...",
                              onTap: () {
                                // 로딩 중에도 전화번호 수정 화면으로 이동 가능
                                context.push('/phone_number_edit');
                              },
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
                          } else if (state is PhoneNumberError) {
                            return ProfileInfoTile(
                              title: "휴대폰 번호 변경",
                              trailingText: "번호 로드 실패",
                              onTap: () {
                                // 다시 로드 시도
                                context
                                    .read<PhoneNumberBloc>()
                                    .add(LoadPhoneNumber());
                                context.push('/phone_number_edit');
                              },
                            );
                          }
                          return ProfileInfoTile(
                            title: "휴대폰 번호 변경",
                            trailingText: "번호를 불러오는 중...",
                            onTap: () {
                              // 초기 상태에서 로드 시도
                              context
                                  .read<PhoneNumberBloc>()
                                  .add(LoadPhoneNumber());
                              context.push('/phone_number_edit');
                            },
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
                        context.read<AuthBloc>().add(LogoutRequested());
                      },
                      child: const Text(
                        '로그아웃',
                        style: TextStyle(color: AppsColor.darkGray),
                      ),
                    ),
                    const Text('|'),
                    TextButton(
                      onPressed: () {
                        _showDeleteConfirmationDialog(context);
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
      ),
    );
  }
}

// 회원 탈퇴 경고창 표시 함수

void _showDeleteConfirmationDialog(BuildContext context) {
  bool isAgreed = false;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '탈퇴하기',
                    style: AppStyles.headingStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '정말 탈퇴하시겠습니까?',
                    textAlign: TextAlign.center,
                    style: AppStyles.bodyTextStyle,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: isAgreed,
                        onChanged: (bool? value) {
                          setState(() {
                            isAgreed = value ?? false;
                          });
                        },
                      ),
                      const Text('동의합니다'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.25,
                        height: MediaQuery.of(context).size.height * 0.05,
                        child: ElevatedButton(
                          onPressed: () {
                            context.pop();
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10), // 직사각형 모양으로 설정
                            ),
                          ),
                          child: Text(
                            '취소',
                            style: AppStyles.bodyTextStyle,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.25,
                        height: MediaQuery.of(context).size.height * 0.05,
                        child: ElevatedButton(
                          onPressed: isAgreed
                              ? () {
                                  // 회원 탈퇴 이벤트 추가
                                  context
                                      .read<AuthBloc>()
                                      .add(DeleteAccountRequested());
                                  context.go('/login');
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppsColor.pastelGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10), // 직사각형 모양으로 설정
                            ),
                          ),
                          child: Text(
                            '확인',
                            style: AppStyles.bodyTextStyle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}
