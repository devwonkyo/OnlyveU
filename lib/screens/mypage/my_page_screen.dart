import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/auth/auth_bloc.dart';
import 'package:onlyveyou/blocs/auth/auth_event.dart';
import 'package:onlyveyou/blocs/auth/auth_state.dart';
import 'package:onlyveyou/blocs/home/ai_recommend_bloc.dart';
import 'package:onlyveyou/blocs/mypage/nickname_edit/nickname_edit_bloc.dart';
import 'package:onlyveyou/blocs/mypage/nickname_edit/nickname_edit_event.dart';
import 'package:onlyveyou/blocs/mypage/nickname_edit/nickname_edit_state.dart';
import 'package:onlyveyou/blocs/mypage/order_status/order_status_bloc.dart';
import 'package:onlyveyou/blocs/mypage/order_status/order_status_event.dart';
import 'package:onlyveyou/blocs/mypage/order_status/order_status_state.dart';
import 'package:onlyveyou/blocs/mypage/profile_edit/profile_edit_bloc.dart';
import 'package:onlyveyou/blocs/mypage/profile_edit/profile_edit_event.dart';
import 'package:onlyveyou/blocs/mypage/profile_edit/profile_edit_state.dart';
import 'package:onlyveyou/blocs/theme/theme_bloc.dart';
import 'package:onlyveyou/blocs/theme/theme_event.dart';
import 'package:onlyveyou/blocs/theme/theme_state.dart';
import 'package:onlyveyou/config/color.dart';
import 'package:onlyveyou/utils/order_status_util.dart';
import 'package:onlyveyou/utils/styles.dart';
import 'package:onlyveyou/widgets/my_page_widget/build_icon_with_label.dart';
import 'package:onlyveyou/widgets/my_page_widget/custom_section.dart';
import 'package:onlyveyou/widgets/my_page_widget/order_status.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  @override
  void initState() {
    super.initState();

    context.read<OrderStatusBloc>().add(const FetchOrder());
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeBloc>().state is ThemeDark;
    context.read<NicknameEditBloc>().add(LoadCurrentNickname());
    context.read<ProfileBloc>().add(LoadProfileImage());
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          context.go('/login');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '마이페이지',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    context.push('/cart');
                  },
                  icon: const Icon(
                    Icons.shopping_bag_outlined,
                  ),
                ),
              ],
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(
                height: 1,
                color: Color.fromARGB(255, 206, 204, 204),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BlocBuilder<NicknameEditBloc, NicknameEditState>(
                              builder: (context, state) {
                                if (state is NicknameLoading) {
                                  return const CircularProgressIndicator();
                                } else if (state is NicknameLoaded) {
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '안녕하세요 ', // "안녕하세요" 텍스트
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '${state.nickname}님', // state.nickname 텍스트
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                } else {
                                  return const Text('닉네임을 불러올 수 없다');
                                }
                              },
                            ),
                            // TextButton(
                            //   onPressed: () {
                            //     // 버튼 클릭 시 동작
                            //   },
                            //   style: TextButton.styleFrom(
                            //     foregroundColor: AppsColor.pastelGreen,
                            //     padding: EdgeInsets.zero,
                            //     minimumSize: Size.zero,
                            //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            //   ),
                            //   child: const Row(
                            //     children: [
                            //       Text(
                            //         'Baby Olive',
                            //         style: TextStyle(fontSize: 18),
                            //       ),
                            //       Icon(
                            //         Icons.arrow_forward_ios_rounded,
                            //         size: 18,
                            //       ),
                            //     ],
                            //   ),
                            // )
                          ],
                        ),
                        Container(
                          width: 140.w,
                          height: 60.h,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF1E1E1E) // 다크모드 배경 색상
                                : Colors.white, // 라이트모드 배경 색상
                            borderRadius: BorderRadius.circular(12), // 둥근 모서리
                            border: Border.all(
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.6)
                                  : Colors.black
                                      .withOpacity(0.3), // 테두리 색상에 투명도 추가
                              width: 1.5, // 테두리 두께
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(
                                  12), // 클릭 시 모서리 애니메이션 적용
                              onTap: () {
                                context.push('/profile_edit');
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  BlocBuilder<ProfileBloc, ProfileState>(
                                    builder: (context, state) {
                                      if (state is ProfileImageUrlLoaded) {
                                        if(state.imageUrl != ""){
                                          return CircleAvatar(
                                            radius: 20, // 프로필 이미지 크기 조정
                                            backgroundImage:
                                            NetworkImage(state.imageUrl),
                                          );
                                        }
                                        return const CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.grey,
                                          child: Icon(Icons.person, size: 20),
                                        );
                                      }
                                      return Icon(
                                        Icons.person,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black, // 기본 아이콘 색상
                                        size: 28, // 기본 아이콘 크기
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 10), // 텍스트와 아이콘 간격
                                  Text(
                                    '프로필 변경',
                                    style: TextStyle(
                                      fontSize: 16.sp, // 텍스트 크기 조정
                                      fontWeight: FontWeight.w500,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black, // 텍스트 색상
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // const Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //   children: [
                    //     // BuildIconWithLabel(
                    //     //   Icons.loyalty,
                    //     //   'CJ ONE',
                    //     //   '1,582P',
                    //     //   () {
                    //     //     print("아이콘 클릭");
                    //     //   },
                    //     // ),
                    //     // BuildIconWithLabel(
                    //     //   Icons.confirmation_number,
                    //     //   '쿠폰',
                    //     //   '0',
                    //     //   () {
                    //     //     print("아이콘 클릭");
                    //     //   },
                    //     // ),
                    //     // BuildIconWithLabel(
                    //     //   Icons.credit_card,
                    //     //   '기프트\n카드',
                    //     //   '',
                    //     //   () {
                    //     //     print("아이콘 클릭");
                    //     //   },
                    //     // ),
                    //     // BuildIconWithLabel(
                    //     //   Icons.qr_code_scanner,
                    //     //   '멤버십\n바코드',
                    //     //   '',
                    //     //   () {
                    //     //     print("F아이콘 클릭");
                    //     //   },
                    //     // ),
                    //   ],
                    // ),
                    Container(
                      decoration: const BoxDecoration(),
                      child: Column(
                        children: [
                          SizedBox(height: 16.h),
                          // AI 분석 요약 카드들 - BlocBuilder로 실시간 데이터 표시
                          BlocBuilder<AIRecommendBloc, AIRecommendState>(
                            builder: (context, state) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  left: 10.0,
                                  right: 10,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildAnalysisCard(
                                      icon: Icons.remove_red_eye,
                                      title: '최근 본 상품',
                                      value:
                                          '${state.activityCounts['viewCount']}개',
                                    ),
                                    _buildAnalysisCard(
                                      icon: Icons.favorite,
                                      
                                      title: '관심 상품',
                                      value:
                                          '${state.activityCounts['likeCount']}개',
                                    ),
                                    InkWell(
                                      onTap: () {
                                        context.push('/cart');
                                      },
                                      child: _buildAnalysisCard(
                                        icon: Icons.shopping_cart,
                                        title: '장바구니',
                                        value:
                                            '${state.activityCounts['cartCount']}개',
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          // 버튼 클릭 시 동작
                          context.push("/review_list");
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '리뷰쓰기 ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                color: const Color.fromARGB(195, 232, 227, 227),
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0, vertical: 30.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '주문/배송 조회',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        TextButton(
                            onPressed: () {
                              context.push('/order-status');
                            },
                            child: const Row(
                              children: [
                                Text(
                                  '전체보기',
                                  style: TextStyle(fontSize: 15),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 15,
                                ),
                              ],
                            )),
                      ],
                    ),
                    const SizedBox(height: 18),
                    BlocBuilder<OrderStatusBloc, OrderStatusState>(
                      builder: (context, state) {
                        if (state is OrderFetch) {
                          // 상태별 주문 수량 계산
                          final statusCounts = {
                            "주문 대기": 0,
                            "상품 준비중": 0,
                            "배송중": 0,
                            "배송 완료": 0,
                          };

                          // 상태별 주문 수량 카운팅
                          for (var order in state.orders) {
                            final status =
                                orderStatusToKorean[order.status] ?? "알 수 없음";
                            if (statusCounts.containsKey(status)) {
                              statusCounts[status] = statusCounts[status]! + 1;
                            }
                          }

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              OrderStatus('${statusCounts["주문 대기"]}', '주문 대기'),
                              const Icon(Icons.arrow_forward_ios,
                                  size: 14, color: Colors.grey),
                              OrderStatus(
                                  '${statusCounts["상품 준비중"]}', '상품 준비중'),
                              const Icon(Icons.arrow_forward_ios,
                                  size: 14, color: Colors.grey),
                              OrderStatus('${statusCounts["배송중"]}', '배송중'),
                              const Icon(Icons.arrow_forward_ios,
                                  size: 14, color: Colors.grey),
                              OrderStatus('${statusCounts["배송 완료"]}', '배송 완료'),
                            ],
                          );
                        } else {
                          // 로딩 상태 또는 오류 처리
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ],
                ),
              ),
              Container(
                height: 8,
                color: const Color.fromARGB(195, 232, 227, 227),
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: InkWell(
                    onTap: () {
                      print("쿠폰 눌림");
                    },
                    child: Image.asset(
                      'assets/image/mypage/coupon_image.jpeg',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  buildListItem(
                    Icons.logout,
                    '로그아웃',
                    onTap: () {
                      context.read<AuthBloc>().add(LogoutRequested());
                    },
                  ),
                  buildListItem(
                    Icons.person_off,
                    '회원탈퇴',
                    onTap: () {
                      _showDeleteConfirmationDialog(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.brightness_4,
                    ),
                    title: const Text(
                      '다크 모드',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    trailing: BlocBuilder<ThemeBloc, ThemeState>(
                      builder: (context, state) {
                        final themeBloc = context.read<ThemeBloc>();
                        bool isDarkMode = false;
                        if (state is ThemeDark) {
                          isDarkMode = true;
                        }
                        return Switch(
                          value: isDarkMode,
                          activeColor: AppsColor.pastelGreen,
                          onChanged: (value) {
                            if (value) {
                              themeBloc.add(SetDarkTheme());
                            } else {
                              themeBloc.add(SetLightTheme());
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildAnalysisCard({
  required IconData icon,
  required String title,
  required String value,
}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        size: 20.sp,
      ),
      SizedBox(width: 8.w),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ],
  );
}

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
