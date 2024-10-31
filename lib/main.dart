import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/blocs/auth/auth_bloc.dart';
import 'package:onlyveyou/blocs/home/home_bloc.dart';
import 'package:onlyveyou/blocs/mypage/password/password_bloc.dart';
import 'package:onlyveyou/blocs/mypage/profile_edit/profile_edit_bloc.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:onlyveyou/blocs/mypage/set_new_password/set_new_password_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/blocs/search/filtered_tags/filtered_tags_cubit.dart';
import 'package:onlyveyou/blocs/search/tag_list/tag_list_cubit.dart';
import 'package:onlyveyou/blocs/search/tag_search/tag_search_cubit.dart';
import 'package:onlyveyou/cubit/category/category_cubit.dart';
import 'package:onlyveyou/repositories/category_repository.dart';


import 'blocs/history/history_bloc.dart';
import 'blocs/search/filtered_tags/filtered_tags_cubit.dart';
import 'blocs/search/tag_list/tag_list_cubit.dart';
import 'core/router.dart';
import 'firebase_options.dart';

void main() async {
  // Flutter 바인딩 초기화 (반드시 필요)
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  KakaoSdk.init(
    nativeAppKey: '0236522723df3e1aa869fe36e25e6297',
    javaScriptAppKey: 'Ye8ebc7de132c8c4f0b6881be99e20f5e',
  );

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
                  // FirebaseFirestore.instance, // Firebase를 사용하는 경우
                  ),
            ),
            BlocProvider<ProfileEditBloc>(
              create: (context) => ProfileEditBloc(),
            ),
            BlocProvider<CategoryCubit>(
              create: (context) => CategoryCubit(categoryRepository: CategoryRepository())..loadCategories()
            ),
            BlocProvider<TagSearchCubit>(
              create: (context) => TagSearchCubit(),
            ),
            BlocProvider<TagListCubit>(
              create: (context) => TagListCubit(),
            ),
            BlocProvider<FilteredTagsCubit>(
              create: (context) => FilteredTagsCubit(
                initialTags: context.read<TagListCubit>().state.tags,
                tagSearchCubit: context.read<TagSearchCubit>(),
              ),
            ),
            BlocProvider<PasswordBloc>(
              // PasswordBloc 추가
              create: (context) => PasswordBloc(),
            ),
            BlocProvider<SetNewPasswordBloc>(
              // PasswordBloc 추가
              create: (context) => SetNewPasswordBloc(),
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
