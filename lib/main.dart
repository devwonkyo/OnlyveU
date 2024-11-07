import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:onlyveyou/blocs/auth/auth_bloc.dart';
import 'package:onlyveyou/blocs/home/home_bloc.dart';
import 'package:onlyveyou/blocs/mypage/nickname_edit/nickname_edit_bloc.dart';
import 'package:onlyveyou/blocs/mypage/order_status/order_status_bloc.dart';
import 'package:onlyveyou/blocs/mypage/password/password_bloc.dart';
import 'package:onlyveyou/blocs/mypage/phone_number/phone_number_bloc.dart';
import 'package:onlyveyou/blocs/mypage/profile_edit/profile_edit_bloc.dart';
import 'package:onlyveyou/blocs/mypage/set_new_password/set_new_password_bloc.dart';
import 'package:onlyveyou/blocs/payment/payment_bloc.dart';
import 'package:onlyveyou/blocs/product/productdetail_bloc.dart';
import 'package:onlyveyou/blocs/theme/theme_bloc.dart';
import 'package:onlyveyou/blocs/theme/theme_event.dart';
import 'package:onlyveyou/blocs/theme/theme_state.dart';
import 'package:onlyveyou/config/theme.dart';
import 'package:onlyveyou/cubit/category/category_cubit.dart';
import 'package:onlyveyou/repositories/auth_repository.dart';
import 'package:onlyveyou/repositories/category_repository.dart';
import 'package:onlyveyou/repositories/history_repository.dart';
import 'package:onlyveyou/repositories/home/home_repository.dart';
import 'package:onlyveyou/repositories/product_repository.dart';
import 'package:onlyveyou/repositories/shopping_cart_repository.dart';
import 'package:onlyveyou/screens/home/home/home_screen.dart';
import 'package:onlyveyou/screens/shopping_cart/shopping_cart_screen.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';

import 'blocs/history/history_bloc.dart';
import 'blocs/shopping_cart/shopping_cart_bloc.dart';
import 'core/router.dart';
import 'firebase_options.dart';

void main() async {
  // Flutter 바인딩 초기화 (반드시 필요)
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      name: "onlyveyou", options: DefaultFirebaseOptions.currentPlatform);

  // print("hash key ${await KakaoSdk.origin}");

  KakaoSdk.init(
    nativeAppKey: '0236522723df3e1aa869fe36e25e6297',
    javaScriptAppKey: 'Ye8ebc7de132c8c4f0b6881be99e20f5e',
  );
  final prefs = OnlyYouSharedPreference();
  await prefs.checkCurrentUser();
  print("hash key ${await KakaoSdk.origin}");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => CartBloc(
                cartRepository: ShoppingCartRepository(),
              )..add(LoadCart()),
              child: ShoppingCartScreen(),
            ),
            BlocProvider<AuthBloc>(
              create: (context) => AuthBloc(
                  authRepository: AuthRepository(),
                  sharedPreference: OnlyYouSharedPreference()),
            ),
            BlocProvider(
              create: (context) => HomeBloc(
                homeRepository: HomeRepository(),
              )..add(LoadHomeData()),
              child: Home(), // HomeScreen 대신 Home을 사용
            ),
            BlocProvider(
              create: (context) => HistoryBloc(
                historyRepository: HistoryRepository(), // ProductRepository 제거
              )..add(LoadHistoryItems()),
            ),
            BlocProvider<ProfileEditBloc>(
              create: (context) => ProfileEditBloc(),
            ),
            BlocProvider<CategoryCubit>(
                create: (context) =>
                    CategoryCubit(categoryRepository: CategoryRepository())
                      ..loadCategories()),
            BlocProvider<PasswordBloc>(
              // PasswordBloc 추가
              create: (context) => PasswordBloc(),
            ),
            BlocProvider<SetNewPasswordBloc>(
              // PasswordBloc 추가
              create: (context) => SetNewPasswordBloc(),
            ),
            BlocProvider<NicknameEditBloc>(
              create: (context) => NicknameEditBloc(),
            ),
            BlocProvider<PhoneNumberBloc>(
              create: (context) => PhoneNumberBloc(),
            ),
            BlocProvider<ThemeBloc>(
              create: (context) => ThemeBloc(),
            ),
            BlocProvider<AuthBloc>(
              create: (context) => AuthBloc(
                authRepository: AuthRepository(),
                sharedPreference: OnlyYouSharedPreference(),
              ),
            ),
            BlocProvider<HomeBloc>(
              create: (context) => HomeBloc(homeRepository: HomeRepository()),
            ),
            BlocProvider(
              create: (context) => HistoryBloc(
                historyRepository: HistoryRepository(), // ProductRepository 제거
              )..add(LoadHistoryItems()),
            ),
            BlocProvider<ProfileEditBloc>(
              create: (context) => ProfileEditBloc(),
            ),
            BlocProvider<CategoryCubit>(
                create: (context) =>
                    CategoryCubit(categoryRepository: CategoryRepository())
                      ..loadCategories()),
            BlocProvider<PasswordBloc>(
              // PasswordBloc 추가
              create: (context) => PasswordBloc(),
            ),
            BlocProvider<SetNewPasswordBloc>(
              // PasswordBloc 추가
              create: (context) => SetNewPasswordBloc(),
            ),
            BlocProvider<NicknameEditBloc>(
              create: (context) => NicknameEditBloc(),
            ),
            BlocProvider<PhoneNumberBloc>(
              create: (context) => PhoneNumberBloc(),
            ),
            BlocProvider<ThemeBloc>(
              create: (context) => ThemeBloc()..add(LoadTheme()),
            ),
            BlocProvider<OrderStatusBloc>(
              create: (context) => OrderStatusBloc(),
            ),
            BlocProvider<ProductDetailBloc>(
              create: (context) => ProductDetailBloc(ProductRepository()),
            ),
            BlocProvider<PaymentBloc>(
              create: (context) => PaymentBloc(),
            ),
          ],
          child: BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                themeMode: state.themeMode,
                theme: lightThemeData(),
                darkTheme: darkThemeData(),
                routerConfig: router,
              );
            },
          ),
        );
      },
    );
  }
}
