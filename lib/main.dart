import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/blocs/auth/auth_bloc.dart';
import 'package:onlyveyou/blocs/home/home_bloc.dart';
import 'package:onlyveyou/blocs/mypage/profile_edit/profile_edit_bloc.dart';
import 'package:onlyveyou/cubit/category/category_cubit.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';

import 'blocs/history/history_bloc.dart';
import 'core/router.dart';
import 'firebase_options.dart';

main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  KakaoSdk.init(
    nativeAppKey: '0236522723df3e1aa869fe36e25e6297',
    javaScriptAppKey: 'Ye8ebc7de132c8c4f0b6881be99e20f5e',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 812),
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
                  // FirebaseFirestore.instance, // Firebase를 사용하는 경우
                  ),
            ),
            BlocProvider<ProfileEditBloc>(
              create: (context) => ProfileEditBloc(),
            ),
            BlocProvider<CategoryCubit>(
              create: (context) => CategoryCubit()..loadCategories(),
            ),
          ],
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                scaffoldBackgroundColor: Colors.white,
                fontFamily: 'Pretendard'),
            routerConfig: router,
          ),
        );
      },
    );
  }
}
