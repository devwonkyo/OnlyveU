import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/special_bloc/weather/location_bloc.dart';

/// 위치 정보를 표시하고 조작할 수 있는 StatefulWidget
class LocationWidget extends StatefulWidget {
  const LocationWidget({Key? key}) : super(key: key);

  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  @override
  void initState() {
    super.initState();
    // 초기화 단계에서 위치 정보를 요청하고 업데이트 시작
    context.read<LocationBloc>()
      ..add(GetCurrentLocation()) // 현재 위치 정보 요청
      ..add(StartLocationUpdates()); // 위치 업데이트 시작
  }

  @override
  Widget build(BuildContext context) {
    // BlocBuilder를 사용해 LocationBloc 상태 변화를 감지 및 UI 갱신
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        return Container(
          // 컨테이너의 마진 및 패딩 설정
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          padding: EdgeInsets.all(16.w),
          // 컨테이너 스타일 정의 (배경색, 테두리, 그림자 등)
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05), // 그림자 색상
                blurRadius: 10, // 그림자 블러 정도
                offset: const Offset(0, 2), // 그림자 위치
              ),
            ],
          ),
          child: Row(
            children: [
              // 위치 아이콘
              Icon(Icons.location_on,
                  color: const Color(0xFFFF7E5F), size: 24.sp),
              SizedBox(width: 8.w), // 아이콘과 텍스트 사이 간격
              Expanded(
                // 현재 위치 텍스트 섹션
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // '현재 위치' 레이블
                    Text(
                      '현재 위치',
                      style: TextStyle(
                        color: const Color(0xFF7F8C8D), // 텍스트 색상
                        fontSize: 12.sp, // 텍스트 크기
                      ),
                    ),
                    // 상태에 따른 위치 정보 텍스트
                    Text(
                      _getLocationText(state),
                      style: TextStyle(
                        color: const Color(0xFF2D3436), // 텍스트 색상
                        fontSize: 16.sp, // 텍스트 크기
                        fontWeight: FontWeight.bold, // 텍스트 두께
                      ),
                    ),
                  ],
                ),
              ),
              // 위치 변경 버튼
              GestureDetector(
                onTap: () => context.push('/map'), // '위치 변경' 버튼 클릭 시 라우팅
                child: Container(
                  // 버튼의 패딩과 스타일 정의
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFA41B),
                        Color(0xFFFF7E5F)
                      ], // 버튼 그라데이션
                    ),
                    borderRadius: BorderRadius.circular(20), // 버튼 모서리 둥글게
                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color(0xFFFF7E5F).withOpacity(0.3), // 그림자 색상
                        blurRadius: 8, // 그림자 블러 정도
                        offset: const Offset(0, 2), // 그림자 위치
                      ),
                    ],
                  ),
                  child: Text(
                    '위치 변경', // 버튼 텍스트
                    style: TextStyle(
                      color: Colors.white, // 텍스트 색상
                      fontSize: 12.sp, // 텍스트 크기
                      fontWeight: FontWeight.bold, // 텍스트 두께
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 상태에 따른 위치 정보 텍스트를 반환
  String _getLocationText(LocationState state) {
    if (state is LocationInitial) {
      return '위치 정보 초기화 중...'; // 초기화 상태
    } else if (state is LocationLoading) {
      return '위치 확인 중...'; // 로딩 상태
    } else if (state is LocationSuccess) {
      return state.address; // 성공적으로 위치를 가져온 상태
    } else if (state is LocationError) {
      return '위치 정보를 가져올 수 없습니다'; // 에러 상태
    }
    return '위치 확인 중...'; // 기본 값
  }
}
