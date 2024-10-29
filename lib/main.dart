import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; //^
import 'package:onlyveyou/blocs/home/home_bloc.dart'; //^
import 'package:onlyveyou/utils/screen_util.dart';

import 'core/router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Bloc 관찰자 설정 (디버깅용)
  Bloc.observer = AppBlocObserver();

  runApp(const MyApp());
}

// Bloc 관찰자 클래스 (선택사항이지만 디버깅에 유용)
class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint('${bloc.runtimeType} $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('${bloc.runtimeType} $error $stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(
          create: (context) => HomeBloc(),
        ),
        // 여기에 다른 Bloc들을 추가할 수 있습니다
        // BlocProvider<AuthBloc>(
        //   create: (context) => AuthBloc(),
        // ),
        // BlocProvider<CartBloc>(
        //   create: (context) => CartBloc(),
        // ),
      ],
      child: MaterialApp.router(
        builder: (context, child) {
          ScreenUtil().init(context);
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          );
        },
        theme: ThemeData(
          fontFamily: "Pretendard",
        ),
        routerConfig: router,
      ),
    );
  }
}
