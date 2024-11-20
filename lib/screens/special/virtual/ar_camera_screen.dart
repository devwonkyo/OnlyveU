import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/screens/special/virtual/widgets/ar_category_bar.dart';
import 'package:onlyveyou/screens/special/virtual/widgets/ar_color_selector.dart';
import 'package:onlyveyou/screens/special/virtual/widgets/ar_filter_modal.dart';
import 'package:onlyveyou/screens/special/virtual/widgets/ar_filter_preview.dart';
import 'package:onlyveyou/screens/special/virtual/widgets/ar_guide_overlay.dart';

class ArCameraScreen extends StatefulWidget {
  const ArCameraScreen({Key? key}) : super(key: key);

  @override
  State<ArCameraScreen> createState() => _ArCameraScreenState();
}

class _ArCameraScreenState extends State<ArCameraScreen> {
  bool _showGuide = true;
  int _currentCategoryIndex = 0;
  int _currentFilterIndex = 0;
  int _currentColorIndex = 0;

  // 카테고리 목록
  final List<String> categories = ['립 메이크업', '블러셔', '마스카라'];

  // 각 카테고리별 필터 이미지
  final Map<int, List<String>> categoryFilters = {
    0: [
      'assets/image/ar/lib1.png',
      'assets/image/ar/lib2.jpg',
      'assets/image/ar/lib3.jpg',
    ],
    1: [
      'assets/image/ar/face1.jpg',
      'assets/image/ar/face2.jpg',
      'assets/image/ar/face3.jpg',
    ],
    2: [
      'assets/image/ar/eye1.jpg',
      'assets/image/ar/eye2.jpg',
      'assets/image/ar/eye3.jpg',
    ],
  };

  // 립스틱 컬러 리스트
  final List<Color> lipstickColors = [
    Colors.red,
    Colors.pink,
    Colors.deepOrange,
    Colors.brown,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 임시 카메라 프리뷰 UI
            Container(
              color: Colors.grey[900],
              child: Center(
                child: Icon(
                  Icons.camera_alt,
                  size: 48.sp,
                  color: Colors.white54,
                ),
              ),
            ),

            // 상단 바
            Column(
              children: [
                // 타이틀 바
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  color: Colors.black.withOpacity(0.3),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      Expanded(
                        child: Text(
                          'AR 가상 피팅',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: 48.w),
                    ],
                  ),
                ),

                // 카테고리 바
                ArCategoryBar(
                  categories: categories,
                  selectedIndex: _currentCategoryIndex,
                  onCategorySelected: (index) {
                    setState(() {
                      _currentCategoryIndex = index;
                      _currentFilterIndex = 0;
                    });
                  },
                ),
              ],
            ),

            // 하단 컨트롤
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                color: Colors.black.withOpacity(0.3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 현재 필터 정보
                    _buildFilterInfo(),
                    SizedBox(height: 16.h),

                    // 필터 미리보기
                    ArFilterPreview(
                      filters: categoryFilters[_currentCategoryIndex]!,
                      selectedIndex: _currentFilterIndex,
                      onFilterSelected: (index) {
                        setState(() {
                          _currentFilterIndex = index;
                        });
                      },
                    ),
                    SizedBox(height: 16.h),

                    // 컬러 선택
                    ArColorSelector(
                      colors: lipstickColors,
                      selectedIndex: _currentColorIndex,
                      onColorSelected: (index) {
                        setState(() {
                          _currentColorIndex = index;
                        });
                      },
                    ),
                    SizedBox(height: 16.h),

                    // 카메라 버튼
                    _buildCameraButton(context),
                  ],
                ),
              ),
            ),

            // 가이드 오버레이
            if (_showGuide)
              ArGuideOverlay(
                onSkip: () => setState(() => _showGuide = false),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              image: DecorationImage(
                image: AssetImage(
                  categoryFilters[_currentCategoryIndex]![_currentFilterIndex],
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '메이크업 필터',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${categories[_currentCategoryIndex]} 필터 ${_currentFilterIndex + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => _showFilterModal(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/ar/result'),
      child: Container(
        width: 70.w,
        height: 70.w,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 3.w,
          ),
        ),
        child: Center(
          child: Container(
            width: 60.w,
            height: 60.w,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => ArFilterModal(
        categoryName: categories[_currentCategoryIndex],
        filters: categoryFilters[_currentCategoryIndex]!,
        onFilterSelected: (index) {
          setState(() {
            _currentFilterIndex = index;
          });
        },
      ),
    );
  }
}
