import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:onlyveyou/blocs/auth/auth_bloc.dart';
import 'package:onlyveyou/blocs/home/home_bloc.dart';
import 'package:onlyveyou/blocs/mypage/nickname_edit/nickname_edit_bloc.dart';
import 'package:onlyveyou/blocs/mypage/password/password_bloc.dart';
import 'package:onlyveyou/blocs/mypage/phone_number/phone_number_bloc.dart';
import 'package:onlyveyou/blocs/mypage/profile_edit/profile_edit_bloc.dart';
import 'package:onlyveyou/blocs/mypage/set_new_password/set_new_password_bloc.dart';
import 'package:onlyveyou/blocs/theme/theme_bloc.dart';
import 'package:onlyveyou/blocs/theme/theme_state.dart';
import 'package:onlyveyou/cubit/category/category_cubit.dart';
import 'package:onlyveyou/repositories/category_repository.dart';
import 'package:onlyveyou/repositories/history_repository.dart';
import 'package:onlyveyou/repositories/product_repository.dart';
import 'package:onlyveyou/repositories/search_repositories/suggestion_repository_impl.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';

import 'blocs/history/history_bloc.dart';
import 'blocs/search/search/search_bloc.dart';
import 'core/router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    print("Firebase initialization error: $e");
  }

  // Kakao SDK 초기화
  KakaoSdk.init(
    nativeAppKey: '0236522723df3e1aa869fe36e25e6297',
    javaScriptAppKey: 'Ye8ebc7de132c8c4f0b6881be99e20f5e',
  );

  // SharedPreferences 체크
  final prefs = OnlyYouSharedPreference();
  await prefs.checkCurrentUser();

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
            BlocProvider<AuthBloc>(
              create: (context) => AuthBloc(),
            ),
            BlocProvider<HomeBloc>(
              create: (context) => HomeBloc(),
            ),
            BlocProvider<HistoryBloc>(
              create: (context) => HistoryBloc(
                repository: HistoryRepository(),
              ),
            ),
            BlocProvider<ProfileEditBloc>(
              create: (context) => ProfileEditBloc(),
            ),
            BlocProvider<CategoryCubit>(
              create: (context) =>
                  CategoryCubit(categoryRepository: CategoryRepository())
                    ..loadCategories(),
            ),
            BlocProvider<PasswordBloc>(
              create: (context) => PasswordBloc(),
            ),
            BlocProvider<SetNewPasswordBloc>(
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
            BlocProvider<SearchBloc>(
              create: (context) => SearchBloc(
                suggestionRepository: SuggestionRepositoryImpl(),
                productRepository: ProductRepository(),
              ),
            ),
          ],
          child: BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                themeMode: state.themeMode,
                theme: ThemeData(
                  scaffoldBackgroundColor: Colors.white,
                  fontFamily: 'Pretendard',
                ),
                darkTheme: ThemeData.dark(),
                routerConfig: router,
              );
            },
          ),
        );
      },
    );
  }
}
