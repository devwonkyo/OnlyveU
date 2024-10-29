import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:onlyveyou/utils/screen_util.dart';

import 'core/router.dart';
import 'firebase_options.dart';

main() async {
  // Flutter 바인딩 초기화 (반드시 필요)
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      builder: (context, child) {
        // 스크린 유틸 초기화
        ScreenUtil().init(context);
        return MediaQuery(
          // 시스템 폰트 스케일 무시
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      theme: ThemeData(
        fontFamily: "Pretendard",
      ),
      routerConfig: router,
    );
  }
}
