import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/models/home_model.dart';

class BannerWidget extends StatefulWidget {
  final PageController pageController;
  final List<BannerItem> bannerItems;

  const BannerWidget({
    required this.pageController,
    required this.bannerItems,
    super.key,
  });

  @override
  _BannerWidgetState createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  int _currentBanner = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _startBannerTimer();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    super.dispose();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentBanner < widget.bannerItems.length - 1) {
        _currentBanner++;
      } else {
        _currentBanner = 0;
      }

      if (widget.pageController.hasClients) {
        widget.pageController.animateToPage(
          _currentBanner,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _handleBannerTap(int index) {
    switch (index) {
      case 0:
        context.push('/banner1');
        break;
      case 1:
        context.push('/banner2');
        break;
      case 2:
        context.push('/banner3');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.width * 1,
      child: Stack(
        children: [
          PageView.builder(
            controller: widget.pageController,
            onPageChanged: (index) {
              setState(() {
                _currentBanner = index;
              });
            },
            itemCount: widget.bannerItems.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _handleBannerTap(index),
                child: Container(
                  color: Colors.white,
                  child: Image.asset(
                    widget.bannerItems[index].imageAsset,
                    width: double.infinity,
                    fit: index == 1 ? BoxFit.contain : BoxFit.cover,
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Row(
              children: List.generate(
                widget.bannerItems.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentBanner == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// SliverToBoxAdapter(
//   child: BlocBuilder<HomeBloc, HomeState>(
//     buildWhen: (previous, current) =>
//         current is HomeLoaded || current is HomeLoading,
//     builder: (context, state) {
//       if (state is HomeLoading) {
//         return Center(child: CircularProgressIndicator());
//       } else if (state is HomeLoaded) {
//         return BannerWidget(
//           pageController: _pageController,
//           bannerItems: state.bannerItems,
//         );
//       }
//       return SizedBox.shrink();
//     },
//   ),
// ),
