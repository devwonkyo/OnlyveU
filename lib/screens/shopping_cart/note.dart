// import 'package:flutter/material.dart'; // Flutter의 화면을 구성하는 기본 UI 패키지
// import 'package:flutter_bloc/flutter_bloc.dart'; // BLoC(비즈니스 로직 컴포넌트) 패턴을 위한 패키지
//
// // 장바구니 기능과 관련된 상태와 이벤트를 관리하는 ShoppingCartBloc 파일을 불러옴
// import '../../blocs/shopping_cart/shopping_cart_bloc.dart';
// import 'widgets/cart_bottombar_widget.dart'; // 장바구니 하단 요약 바 UI 위젯
// import 'widgets/cart_tab_header_widget.dart'; // 장바구니 탭과 헤더 UI 위젯
//
// // ShoppingCartScreen: 장바구니 화면 클래스
// // 이 클래스는 사용자가 장바구니 페이지에 들어왔을 때 보여주는 UI와 기능을 구성합니다.
// class ShoppingCartScreen extends StatefulWidget {
//   @override
//   _ShoppingCartScreenState createState() => _ShoppingCartScreenState();
// }
//
// // _ShoppingCartScreenState: ShoppingCartScreen의 상태를 관리하는 클래스
// // 이 클래스는 StatefulWidget으로, 화면의 상태를 변경하고 유지하는 역할을 합니다.
// class _ShoppingCartScreenState extends State<ShoppingCartScreen>
//     with SingleTickerProviderStateMixin {
//   // SingleTickerProviderStateMixin은 애니메이션 탭 전환을 가능하게 함
//   late TabController _tabController; // TabController는 탭이 어떤 상태인지 알려주는 역할을 합니다.
//
//   // initState: 초기 상태를 설정하는 메서드로, 화면이 생성될 때 한 번 실행됩니다.
//   @override
//   void initState() {
//     super.initState();
//     _tabController =
//         TabController(length: 2, vsync: this); // 두 개의 탭(일반 배송과 픽업)을 설정
//     context.read<CartBloc>().add(LoadCart()); // 장바구니 데이터를 로드하는 이벤트를 보냄
//
//     // 탭이 전환될 때 호출되는 리스너: 탭이 변경되면 모든 항목의 선택을 해제함
//     _tabController.addListener(() {
//       final cartBloc = context.read<CartBloc>(); // 현재 CartBloc 객체를 가져옴
//       cartBloc
//           .add(const SelectAllItems(false)); // 모든 항목을 선택 해제하는 이벤트를 CartBloc에 보냄
//     });
//   }
//
//   // build 메서드: 화면에 보여질 위젯을 구성하는 함수
//   // BlocBuilder<CartBloc, CartState>는 CartBloc의 상태 변화에 따라 UI를 다시 그리는 역할을 합니다.
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<CartBloc, CartState>(
//       // CartBloc의 상태를 감지하여 화면을 업데이트함
//       builder: (context, state) {
//         // 상태를 기반으로 UI를 빌드하는 함수
//         return Scaffold(
//           // Scaffold는 Flutter의 기본 화면 구조를 제공
//           backgroundColor: Colors.white, // 전체 화면 배경 색상을 흰색으로 설정
//           appBar: AppBar(
//             // 화면 상단에 보이는 앱바 설정
//             backgroundColor: Colors.white, // 앱바 배경 색상을 흰색으로 설정
//             elevation: 0, // 앱바의 그림자 효과 제거
//             leading: IconButton(
//               // 앱바 왼쪽의 뒤로 가기 버튼
//               icon: Icon(Icons.arrow_back,
//                   color: Colors.black), // 검은색 뒤로 가기 아이콘 설정
//               onPressed: () => Navigator.pop(context), // 뒤로 가기 클릭 시 이전 화면으로 돌아감
//             ),
//             title: Text(
//               // 앱바에 보이는 화면 제목
//               '장바구니', // 제목 내용
//               style: TextStyle(
//                 color: Colors.black, // 제목 글씨 색상을 검은색으로 설정
//                 fontSize: 18, // 글씨 크기
//                 fontWeight: FontWeight.w500, // 글씨 두께
//               ),
//             ),
//             actions: [
//               // 앱바 오른쪽에 추가 기능 버튼들
//               IconButton(
//                 icon: Icon(Icons.search, color: Colors.black), // 검은색 검색 아이콘
//                 onPressed: () {}, // 검색 기능 (현재 구현되지 않음)
//               ),
//               IconButton(
//                 icon:
//                     Icon(Icons.home_outlined, color: Colors.black), // 검은색 홈 아이콘
//                 onPressed: () {}, // 홈 기능 (현재 구현되지 않음)
//               ),
//             ],
//           ),
//           body: state.isLoading // CartBloc에서 로딩 중인 상태인지 확인
//               ? Center(
//                   child: CircularProgressIndicator()) // 로딩 중이면 중앙에 로딩 인디케이터 표시
//               : CartTabHeaderWidget(
//                   // 로딩이 끝난 상태일 때 CartTabHeaderWidget 사용해 장바구니 목록 표시
//                   regularDeliveryItems:
//                       state.regularDeliveryItems, // 일반 배송 목록 아이템 데이터 전달
//                   pickupItems: state.pickupItems, // 픽업 목록 아이템 데이터 전달
//                   selectedItems: state.selectedItems, // 사용자가 선택한 아이템 목록 전달
//                   itemQuantities: state.itemQuantities, // 각 아이템의 수량 전달
//                   isAllSelected: state.isAllSelected, // 모든 항목이 선택되었는지 여부 전달
//                   onSelectAll: (value) {
//                     // 모든 항목을 선택하거나 해제하는 기능
//                     context.read<CartBloc>().add(
//                         SelectAllItems(value ?? false)); // 모든 항목 선택/해제 이벤트 전달
//                   },
//                   onRemoveItem: (item) {
//                     // 특정 아이템을 장바구니에서 제거하는 기능
//                     context
//                         .read<CartBloc>()
//                         .add(RemoveItem(item)); // CartBloc에 아이템 제거 이벤트 전달
//                   },
//                   updateQuantity: (productId, increment) {
//                     // 아이템 수량을 늘리거나 줄이는 기능
//                     context.read<CartBloc>().add(UpdateItemQuantity(
//                         productId, increment)); // 수량 업데이트 이벤트 전달
//                   },
//                   onUpdateSelection: (productId, value) {
//                     // 특정 아이템의 선택 상태를 변경하는 기능
//                     context.read<CartBloc>().add(UpdateItemSelection(
//                         productId, value ?? false)); // 선택 상태 업데이트 이벤트 전달
//                   },
//                   onDeleteSelected: () {
//                     // 선택된 모든 아이템을 삭제하는 기능
//                     context
//                         .read<CartBloc>()
//                         .add(DeleteSelectedItems()); // 선택된 아이템 삭제 이벤트 전달
//                   },
//                   moveToPickup: () {
//                     // 선택된 아이템을 픽업 목록으로 이동시키는 기능
//                     context
//                         .read<CartBloc>()
//                         .add(MoveToPickup()); // 픽업 목록으로 이동 이벤트 전달
//                   },
//                   moveToRegularDelivery: () {
//                     // 선택된 아이템을 일반 배송 목록으로 이동시키는 기능
//                     context
//                         .read<CartBloc>()
//                         .add(MoveToRegularDelivery()); // 일반 배송 목록으로 이동 이벤트 전달
//                   },
//                   tabController:
//                       _tabController, // 탭 컨트롤러를 CartTabHeaderWidget에 전달하여 탭 제어
//                 ),
//           bottomNavigationBar: state.isLoading // 하단 바 영역: 로딩 중인지 여부 확인
//               ? null // 로딩 중일 때는 하단 바를 표시하지 않음
//               : CartBottomBarWidget(
//                   // 로딩이 끝난 후에는 CartBottomBarWidget을 사용하여 장바구니 요약 정보 표시
//                   currentItems: _tabController.index == 0
//                       ? state
//                           .regularDeliveryItems // 일반 배송 탭이 선택되었을 때는 일반 배송 목록 표시
//                       : state.pickupItems, // 픽업 탭이 선택되었을 때는 픽업 목록 표시
//                   selectedItems: state.selectedItems, // 선택된 아이템 정보 전달
//                   itemQuantities: state.itemQuantities, // 각 아이템의 수량 정보 전달
//                 ),
//         );
//       },
//     );
//   }
//
//   // dispose 메서드: 화면이 사라질 때 호출되어 자원을 정리
//   @override
//   void dispose() {
//     _tabController.dispose(); // 탭 컨트롤러 종료
//     super.dispose();
//   }
// }
