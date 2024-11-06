// // todaysale_card_widget.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:onlyveyou/utils/styles.dart';
//
// class TodaySaleCardWidget extends StatelessWidget {
//   final int index;
//
//   const TodaySaleCardWidget({
//     Key? key,
//     required this.index,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
//       decoration: BoxDecoration(
//         border: Border(
//           bottom: BorderSide(
//             color: Colors.grey[200]!,
//             width: 1,
//           ),
//         ),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // 1. 상품 이미지 부분
//           ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: Image.network(
//               'https://via.placeholder.com/100',
//               width: 120.w,
//               height: 120.w,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) =>
//                   Icon(Icons.image, size: 120.w),
//             ),
//           ),
//           SizedBox(width: 16.w),
//
//           // 2. 상품 정보 부분
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   '특가 상품 ${index + 1}',
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: 4.h),
//                 Text(
//                   '99,900원',
//                   style: TextStyle(
//                     color: Colors.grey,
//                     decoration: TextDecoration.lineThrough,
//                     fontSize: 12.sp,
//                   ),
//                 ),
//                 SizedBox(height: 4.h),
//                 Row(
//                   children: [
//                     Text(
//                       '50%',
//                       style: TextStyle(
//                         color: Colors.red,
//                         fontSize: 14.sp,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(width: 8.w),
//                     Text(
//                       '49,900원',
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 4.h),
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
//                   decoration: BoxDecoration(
//                     color: AppStyles.mainColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Text(
//                     "BEST",
//                     style: TextStyle(
//                       color: AppStyles.mainColor,
//                       fontSize: 10.sp,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 4.h),
//                 Row(
//                   children: [
//                     Icon(Icons.star, size: 13.sp, color: AppStyles.mainColor),
//                     SizedBox(width: 4.w),
//                     Text(
//                       '4.7',
//                       style: TextStyle(
//                         fontSize: 11.sp,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     SizedBox(width: 4.w),
//                     Text(
//                       '(26,152)',
//                       style: TextStyle(
//                         fontSize: 11.sp,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//
//           // 3. 좋아요와 장바구니 아이콘을 오른쪽 상단에 배치
//           Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               SizedBox(height: 20.h),
//               Icon(
//                 Icons.favorite_border,
//                 size: 24.sp,
//                 color: Colors.grey,
//               ),
//               SizedBox(height: 25.h),
//               Icon(
//                 Icons.shopping_bag_outlined,
//                 size: 24.sp,
//                 color: Colors.grey,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
