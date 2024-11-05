import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/mypage/nickname_edit/nickname_edit_bloc.dart';
import 'package:onlyveyou/blocs/mypage/nickname_edit/nickname_edit_event.dart';
import 'package:onlyveyou/blocs/mypage/nickname_edit/nickname_edit_state.dart';
import 'package:onlyveyou/blocs/theme/theme_bloc.dart';
import 'package:onlyveyou/blocs/theme/theme_event.dart';
import 'package:onlyveyou/blocs/theme/theme_state.dart';
import 'package:onlyveyou/config/color.dart';
import 'package:onlyveyou/widgets/my_page_widget/build_icon_with_label.dart';
import 'package:onlyveyou/widgets/my_page_widget/custom_section.dart';
import 'package:onlyveyou/widgets/my_page_widget/order_status.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<NicknameEditBloc>().add(LoadCurrentNickname());

    return Scaffold(
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
                onPressed: () {},
                icon: const Icon(
                  Icons.settings_outlined,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_outlined,
                ),
              ),
              IconButton(
                onPressed: () {},
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
                                return Text(
                                  state.nickname, // 사용자 이름으로 대체
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              } else {
                                return const Text('닉네임을 불러올 수 없다');
                              }
                            },
                          ),
                          TextButton(
                            onPressed: () {
                              // 버튼 클릭 시 동작
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppsColor.pastelGreen,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Row(
                              children: [
                                Text(
                                  'Baby Olive',
                                  style: TextStyle(fontSize: 18),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 18,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                context.push('/profile_edit');
                              },
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.person_pin,
                                    color: Color.fromARGB(255, 205, 202, 202),
                                    size: 30,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '프로필',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: AppsColor.darkGray,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      BuildIconWithLabel(
                        Icons.loyalty,
                        'CJ ONE',
                        '1,582P',
                        () {
                          print("아이콘 클릭");
                        },
                      ),
                      BuildIconWithLabel(
                        Icons.confirmation_number,
                        '쿠폰',
                        '0',
                        () {
                          print("아이콘 클릭");
                        },
                      ),
                      BuildIconWithLabel(
                        Icons.credit_card,
                        '기프트\n카드',
                        '',
                        () {
                          print("아이콘 클릭");
                        },
                      ),
                      BuildIconWithLabel(
                        Icons.qr_code_scanner,
                        '멤버십\n바코드',
                        '',
                        () {
                          print("F아이콘 클릭");
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                        // 버튼 클릭 시 동작
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
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: '0개',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
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
                          // 버튼 클릭 시 동작
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          foregroundColor: Colors.black,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: TextButton(
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OrderStatus('0', '주문접수'),
                      const Icon(Icons.arrow_forward_ios,
                          size: 14, color: Colors.grey),
                      OrderStatus('0', '결제완료'),
                      const Icon(Icons.arrow_forward_ios,
                          size: 14, color: Colors.grey),
                      OrderStatus('0', '배송준비중'),
                      const Icon(Icons.arrow_forward_ios,
                          size: 14, color: Colors.grey),
                      OrderStatus('0', '배송중'),
                      const Icon(Icons.arrow_forward_ios,
                          size: 14, color: Colors.grey),
                      OrderStatus('0', '배송완료'),
                    ],
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
                CustomSection(
                  title: '쇼핑 활동',
                  items: [
                    buildListItem(Icons.receipt_long, '취소/반품/교환 내역'),
                    buildListItem(Icons.account_balance_wallet, '선물함'),
                    buildListItem(Icons.payment, '배송지 관리'),
                    buildListItem(Icons.savings, '재입고 알림'),
                    buildListItem(Icons.receipt_long, '올영매장'),
                    buildListItem(Icons.account_balance_wallet, '티켓 예약 내역'),
                  ],
                ),
                CustomSection(
                  title: '마이 월렛',
                  items: [
                    buildListItem(Icons.receipt_long, '스마트 영수증'),
                    buildListItem(Icons.account_balance_wallet, '환불계좌 관리'),
                    buildListItem(Icons.payment, '빠른결제', subtitle: '토스(0216)'),
                    buildListItem(Icons.savings, '예치금'),
                  ],
                ),
                CustomSection(
                  title: '이벤트·리서치',
                  items: [
                    buildListItem(Icons.event, '이벤트 참여 현황'),
                    buildListItem(Icons.mic, '올리브 보이스'),
                  ],
                ),
                CustomSection(
                  title: '문의',
                  items: [
                    buildListItem(Icons.headset_mic, '고객센터/공지사항'),
                    buildListItem(Icons.help_outline, '상품 문의'),
                    buildListItem(Icons.chat_bubble_outline, '1:1 문의'),
                  ],
                ),
                buildListItem(Icons.logout, '로그아웃'),
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
    );
  }
}
