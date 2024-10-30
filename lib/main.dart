import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onlyveyou/cubit/category/category_cubit.dart';


import 'core/router.dart';
import 'firebase_options.dart';

main() async {
  // Flutter 바인딩 초기화 (반드시 필요)
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // addCategories();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<CategoryCubit>(
              create: (context) => CategoryCubit()..loadCategories(),
            ),
          ],
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              scaffoldBackgroundColor: Colors.white,
              fontFamily: 'Pretendard'
            ),
            routerConfig: router,
          ),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

Future<void> addCategories() async {
  final CollectionReference categories = FirebaseFirestore.instance.collection('categories');

  List<Map<String, dynamic>> categoryData = [
    {
      "id": "1",
      "name": "스킨케어",
      "icon": "skin",
      "subcategories": [
        {
          "id": "1_1",
          "name": "스킨/토너",
        },
        {
          "id": "1_2",
          "name": "에센스/세럼/앰플",
        },
        {
          "id": "1_3",
          "name": "크림",
        },
        {
          "id": "1_4",
          "name": "로션",
        },
        {
          "id": "1_5",
          "name": "미스트/오일",
        },
        {
          "id": "1_6",
          "name": "스킨케어세트",
        },
      ]
    },
    {
      "id": "2",
      "name": "마스크팩",
      "icon": "mask",
      "subcategories": [
        {
          "id": "2_1",
          "name": "시트팩",
        },
        {
          "id": "2_2",
          "name": "패드",
        },
        {
          "id": "2_3",
          "name": "페이셜팩",
        },
        {
          "id": "2_4",
          "name": "코팩",
        },
        {
          "id": "2_5",
          "name": "패치",
        },
      ]
    },
    {
      "id": "3",
      "name": "클렌징",
      "icon": "cleanging",
      "subcategories": [
        {
          "id": "3_1",
          "name": "클렌징폼/젤",
        },
        {
          "id": "3_2",
          "name": "오일/밤",
        },
        {
          "id": "3_3",
          "name": "워터/밀크",
        },
        {
          "id": "3_4",
          "name": "티슈/패드",
        },
        {
          "id": "3_5",
          "name": "립&아이리무버",
        },
      ]
    },
    {
      "id": "4",
      "name": "선케어",
      "icon": "suncare",
      "subcategories": [
        {
          "id": "4_1",
          "name": "선크림",
        },
        {
          "id": "4_2",
          "name": "선스틱",
        },
        {
          "id": "4_3",
          "name": "선쿠션",
        },
        {
          "id": "4_4",
          "name": "선스프레이/선패치",
        },
        {
          "id": "4_5",
          "name": "태닝/애프터선",
        },
      ]
    },
    {
      "id": "5",
      "name": "메이크업/네일",
      "icon": "makeup",
      "subcategories": [
        {
          "id": "5_1",
          "name": "립메이크업",
        },
        {
          "id": "5_2",
          "name": "베이스메이크업",
        },
        {
          "id": "5_3",
          "name": "아이메이크업",
        },
        {
          "id": "5_4",
          "name": "일반네일",
        },
        {
          "id": "5_5",
          "name": "젤네일",
        },
        {
          "id": "5_6",
          "name": "네일팁/스티커",
        },
        {
          "id": "5_7",
          "name": "네일케어",
        },
      ]
    },
    {
      "id": "6",
      "name": "뷰티소품",
      "icon": "beauty",
      "subcategories": [
        {
          "id": "6_1",
          "name": "메이크업소품",
        },
        {
          "id": "6_2",
          "name": "스킨케어소품",
        },
        {
          "id": "6_3",
          "name": "아이소품",
        },
        {
          "id": "6_4",
          "name": "헤어/바디소품",
        },
        {
          "id": "6_5",
          "name": "괄사/네일소품",
        },
        {
          "id": "6_6",
          "name": "뷰티디바이스",
        },
        {
          "id": "6_7",
          "name": "뷰티잡화",
        },
      ]
    },
    {
      "id": "7",
      "name": "맨즈케어",
      "icon": "man",
      "subcategories": [
        {
          "id": "7_1",
          "name": "스킨케어",
        },
        {
          "id": "7_2",
          "name": "메이크업",
        },
        {
          "id": "7_3",
          "name": "쉐이빙",
        },
        {
          "id": "7_4",
          "name": "헤어케어",
        },
        {
          "id": "7_5",
          "name": "바디케어",
        },
        {
          "id": "7_6",
          "name": "프래그런스/라이프",
        },
      ]
    },
    {
      "id": "8",
      "name": "헤어케어",
      "icon": "hair",
      "subcategories": [
        {
          "id": "8_1",
          "name": "샴푸/린스",
        },
        {
          "id": "8_2",
          "name": "트리트먼트/팩",
        },
        {
          "id": "8_3",
          "name": "헤어에센스",
        },
        {
          "id": "8_4",
          "name": "염색약/펌",
        },
        {
          "id": "8_5",
          "name": "헤어기기/브러시",
        },
        {
          "id": "8_6",
          "name": "스타일링",
        },
      ]
    },
    {
      "id": "9",
      "name": "바디케어",
      "icon": "body",
      "subcategories": [
        {
          "id": "9_1",
          "name": "로션/오일",
        },
        {
          "id": "9_2",
          "name": "샤워/입욕",
        },
        {
          "id": "9_3",
          "name": "립케어",
        },
        {
          "id": "9_4",
          "name": "핸드케어",
        },
        {
          "id": "9_5",
          "name": "바디미스트",
        },
        {
          "id": "9_6",
          "name": "제모/왁싱",
        },
        {
          "id": "9_7",
          "name": "데오드란트",
        },
        {
          "id": "9_8",
          "name": "베이비",
        },
      ]
    },
  ];

  for (var category in categoryData) {
    await categories.add(category);
  }
}
