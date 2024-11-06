// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "my first app",
//       home: MyPage(),
//     );
//   }
// }

// class MyPage extends StatelessWidget {
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         centerTitle: true,
//         elevation: 0,
//         toolbarHeight: 80,
//         leading: IconButton(onPressed: () {Navigator.pop(context);},
//           icon: Icon(Icons.arrow_back_ios),),
//         title: const Text("test", style: TextStyle(fontSize: 15),),
//       ),

//     body: Stack(
//         children: [Container(
//           decoration:  BoxDecoration(image: DecorationImage(
//               image: AssetImage('assets/images/bg_cug.png'),
//               fit: BoxFit.cover),),
//         ),
//           Container(
//             margin: EdgeInsets.only(top:(MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top) * 0.13),
//             width: MediaQuery.of(context).size.width ,
//             height: MediaQuery.of(context).size.height,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(10.0),
//                   topRight: Radius.circular(10.0)),
//             ),
//             child: Padding(
//               padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
//                 child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           Expanded(
//                             child:
//                             GestureDetector(
//                               onTap: () {
//                                 showModalBottomSheet(
//                                     context: context,
//                                   builder: (BuildContext context) {
//                                       return Container(
//                                         height: 220,
//                                         decoration: const BoxDecoration(
//                                           color: Colors.white,
//                                           borderRadius: BorderRadius.only(
//                                             topLeft: Radius.circular(10),
//                                             topRight: Radius.circular(10),
//                                             ),
//                                           ),
//                                         child: Column(
//                                           children: [
//                                             Container(
//                                               margin: EdgeInsets.all(10),
//                                               child: Row(
//                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                 children: [
//                                                   Text('프로필 사진 변경',
//                                                     style: TextStyle(fontSize: 13, color: Colors.black54,
//                                                     fontWeight: FontWeight.bold),),
//                                                   SizedBox(width: MediaQuery.of(context).size.width * 0.42),
//                                                   IconButton(icon: Icon(
//                                                     Icons.close, size: 20,
//                                                     color: Colors.black54,),
//                                                     onPressed: () {Navigator.of(context).pop();},
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),

//                                             Container(decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12)),),),
//                                             Container(
//                                               margin: EdgeInsets.all(10),
//                                               width: MediaQuery.of(context).size.width * 0.9,
//                                               decoration: BoxDecoration(border: Border.all(color: Colors.black26),
//                                                 borderRadius: BorderRadius.circular(10),),

//                                               child: TextButton(onPressed: () { print("1111"); },
//                                                 style: TextButton.styleFrom(padding: const EdgeInsets.all(10.0),
//                                                   textStyle: const TextStyle(fontSize: 12),
//                                                   primary: Colors.black54,
//                                                 ),
//                                                 child: const Text('새 프로필 사진', style: TextStyle(fontWeight: FontWeight.bold),),
//                                               ),
//                                             ),
//                                             Container(
//                                               margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
//                                               width: MediaQuery.of(context).size.width * 0.9,
//                                               decoration: BoxDecoration(border: Border.all(color: Colors.black26),
//                                                 borderRadius: BorderRadius.circular(10),),

//                                               child: TextButton(onPressed: () { print("1111"); },
//                                                 style: TextButton.styleFrom(
//                                                   padding: const EdgeInsets.all(10.0),
//                                                   textStyle: const TextStyle(fontSize: 12),
//                                                   primary: Colors.black54,
//                                                 ),
//                                                 child: const Text('기본 프로필 사진', style: TextStyle(fontWeight: FontWeight.bold),),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       );
//                                     },
//                                   backgroundColor: Colors.transparent,//모달의 여백 부분을 투명하게 처리
//                                 );
//                               },

//                               child: Column(
//                                 children: <Widget>[
//                                   SvgPicture.asset(
//                                     "assets/images/ic_profile.svg",
//                                     width: 80,
//                                     height: 80,
//                                   ),
//                                   const SizedBox(height: 10.0),
//                                   Text("김철수",//_user.userData.name,
//                                     style: const TextStyle(color: Colors.black54, fontSize: 18, fontWeight: FontWeight.bold,),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           )
//                         ],
//                       ),
//                       const SizedBox(height: 30.0),
//                       const Divider(
//                         color: Colors.black12,
//                         thickness: 5,
//                       ),
//                       const SizedBox(height: 10.0),
//                       Container(
//                           margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
//                           child: Row(
//                             children: [
//                               Text("멤버증 발급"),
//                               const SizedBox(width: 150.0),
//                               OutlinedButton(
//                                 onPressed: () {
//                                   Get.toNamed('/login');
//                                 },
//                                 child: Text("재발급"),
//                               )
//                             ],
//                           )
//                       ),
//                       const Divider(
//                         color: Colors.black12,
//                         thickness: 5,
//                       ),
//                     ]
//                 )

//             )
//           ),
//         ]
//       )
//     );
//   }
// }
// [출처] [Flutter 실습] showModalBottomSheet 사용해보기|작성자 yh_park02

