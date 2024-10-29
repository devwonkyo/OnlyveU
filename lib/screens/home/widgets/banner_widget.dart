// widgets/banner_widget.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:onlyveyou/utils/styles.dart';

import '../../../models/home_model.dart';

class BannerWidget extends StatefulWidget {
  final PageController pageController;
  final List<BannerItem> bannerItems;

  BannerWidget({
    required this.pageController,
    required this.bannerItems,
    Key? key,
  }) : super(key: key);

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
    _bannerTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_currentBanner < widget.bannerItems.length - 1) {
        _currentBanner++;
      } else {
        _currentBanner = 0;
      }

      if (widget.pageController.hasClients) {
        widget.pageController.animateToPage(
          _currentBanner,
          duration: Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
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
              return Container(
                color: widget.bannerItems[index].backgroundColor,
                padding: AppStyles.defaultPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.bannerItems[index].title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.bannerItems[index].subtitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
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
                  margin: EdgeInsets.symmetric(horizontal: 4),
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
