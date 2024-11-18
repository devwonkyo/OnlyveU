// lib/config/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/payment/payment_bloc.dart';
import 'package:onlyveyou/blocs/payment/payment_event.dart';
import 'package:onlyveyou/models/available_review_model.dart';
import 'package:onlyveyou/models/category_selection.dart';
import 'package:onlyveyou/models/order_model.dart';
import 'package:onlyveyou/models/review_model.dart';
import 'package:onlyveyou/repositories/order/order_repository.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/screens/auth/findid_screen.dart';
import 'package:onlyveyou/screens/auth/login_screen.dart';
import 'package:onlyveyou/screens/auth/signup_screen.dart';
import 'package:onlyveyou/screens/category/category_product_list_screen.dart';
import 'package:onlyveyou/screens/category/category_screen.dart';
import 'package:onlyveyou/screens/history/histoy_screen.dart';
import 'package:onlyveyou/screens/home/home/home_screen.dart';
import 'package:onlyveyou/screens/home/home/more_popular_screen.dart';
import 'package:onlyveyou/screens/home/home/more_recommended_screen.dart';
import 'package:onlyveyou/screens/home/home/widgets/banner1.dart';
import 'package:onlyveyou/screens/home/home/widgets/banner2.dart';
import 'package:onlyveyou/screens/home/home/widgets/banner3.dart';
import 'package:onlyveyou/screens/home/ranking/ranking_tap_screen.dart';
import 'package:onlyveyou/screens/mypage/admin_page_screen.dart';
import 'package:onlyveyou/screens/mypage/edit/email_edit_screen.dart';
import 'package:onlyveyou/screens/mypage/edit/nickname_edit_screen.dart';
import 'package:onlyveyou/screens/mypage/edit/password/set_new_password_screen.dart';
import 'package:onlyveyou/screens/mypage/edit/password/verify_current_password_screen.dart';
import 'package:onlyveyou/screens/mypage/edit/phone_number_edit_screen.dart';
import 'package:onlyveyou/screens/mypage/edit/profile_edit_screen.dart';
import 'package:onlyveyou/screens/mypage/my_page_screen.dart';
import 'package:onlyveyou/screens/mypage/order_status_screen.dart';
import 'package:onlyveyou/screens/mypage/review/modify_review_screen.dart';
import 'package:onlyveyou/screens/mypage/review/review_list_screen.dart';
import 'package:onlyveyou/screens/mypage/review/write_rating_screen.dart';
import 'package:onlyveyou/screens/mypage/review/write_review_screen.dart';
import 'package:onlyveyou/screens/payment/new_delivery_address_screen.dart';
import 'package:onlyveyou/screens/payment/payment_screen.dart';
import 'package:onlyveyou/screens/product/product_detail_screen.dart';
import 'package:onlyveyou/screens/shopping_cart/shopping_cart_screen.dart';
import 'package:onlyveyou/screens/shutter/shutter_post.dart';
import 'package:onlyveyou/screens/shutter/shutter_screen.dart';
import 'package:onlyveyou/screens/store/store_list_screen.dart';
import 'package:onlyveyou/screens/special/virtual/vitual_screen.dart';

import '../screens/search/search_page.dart';
import '../screens/special/ai_onepick/ai_onepick_screen.dart';
import '../screens/special/debate/debate_screen.dart';
import '../screens/special/mbti/mbti_screen.dart';
import '../screens/special/weather/weather_screen.dart';
import '../widgets/bottom_navbar.dart';

final GoRouter router = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithBottomNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/ai-onepick',
          pageBuilder: (context, state) => _buildPageWithTransition(
            state,
            AIOnepickScreen(),
          ),
        ),
        GoRoute(
          path: '/weather',
          pageBuilder: (context, state) => _buildPageWithTransition(
            state,
            const WeatherScreen(),
          ),
        ),
        GoRoute(
          path: '/virtual',
          pageBuilder: (context, state) => _buildPageWithTransition(
            state,
            const VirtualScreen(),
          ),
        ),
        GoRoute(
          path: '/mbti',
          pageBuilder: (context, state) => _buildPageWithTransition(
            state,
            const MbtiScreen(),
          ),
        ),
        GoRoute(
          path: '/debate',
          pageBuilder: (context, state) => _buildPageWithTransition(
            state,
            const DebateScreen(),
          ),
        ),
        GoRoute(
          path: '/banner1',
          pageBuilder: (context, state) => _buildPageWithTransition(
            state,
            const Banner1Screen(),
          ),
        ),
        GoRoute(
          path: '/banner2',
          pageBuilder: (context, state) => _buildPageWithTransition(
            state,
            const Banner2Screen(),
          ),
        ),
        GoRoute(
          path: '/banner3',
          pageBuilder: (context, state) => _buildPageWithTransition(
            state,
            const Banner3Screen(),
          ),
        ),
        GoRoute(
          path: '/admin',
          pageBuilder: (context, state) => _buildPageWithTransition(
            state,
            const AdminPageScreen(),
          ),
        ),
        GoRoute(
          path: '/category',
          pageBuilder: (context, state) => _buildPageWithTransition(
              state, const CategoryScreen()), // builder 변경
        ),
        GoRoute(
          path: '/ranking',
          builder: (context, state) => const RankingTabScreen(),
        ),
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) =>
              _buildPageWithTransition(state, const Home()),
        ),
        GoRoute(
          path: '/shutter',
          pageBuilder: (context, state) =>
              _buildPageWithTransition(state, const ShutterScreen()),
        ),
        GoRoute(
          path: '/history',
          pageBuilder: (context, state) =>
              _buildPageWithTransition(state, HistoryScreen()),
        ),
        GoRoute(
          path: '/my',
          pageBuilder: (context, state) =>
              _buildPageWithTransition(state, const MyPageScreen()),
        ),
        GoRoute(
          path: '/order-status',
          pageBuilder: (context, state) =>
              _buildPageWithTransition(state, const OrderStatusScreen()),
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/profile_edit',
      pageBuilder: (context, state) => _buildPageWithTransition(
        state,
        const ProfileEditScreen(),
      ),
    ),
    GoRoute(
      path: '/nickname_edit',
      pageBuilder: (context, state) => _buildPageWithTransition(
        state,
        const NicknameEditScreen(),
      ),
    ),
    GoRoute(
      path: '/email_edit',
      pageBuilder: (context, state) => _buildPageWithTransition(
        state,
        const EmailEditScreen(),
      ),
    ),
    GoRoute(
      path: '/verify_password',
      pageBuilder: (context, state) => _buildPageWithTransition(
        state,
        const VerifyCurrentPasswordScreen(),
      ),
    ),
    GoRoute(
      path: '/set_new_password',
      pageBuilder: (context, state) => _buildPageWithTransition(
        state,
        const SetNewPasswordScreen(),
      ),
    ),
    GoRoute(
      path: '/phone_number_edit',
      pageBuilder: (context, state) =>
          _buildPageWithTransition(state, const PhoneNumberEditScreen()),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => SignupScreen(),
    ),
    GoRoute(
      path: '/find-id',
      builder: (context, state) => FindIdScreen(),
    ),
    GoRoute(
      path: '/more-recommended',
      pageBuilder: (context, state) => _buildPageWithTransition(
        state,
        MoreRecommendedScreen(),
      ),
    ),
    GoRoute(
      path: '/cart',
      pageBuilder: (context, state) => _buildPageWithTransition(
        state,
        ShoppingCartScreen(),
      ),
    ),
    GoRoute(
      path: '/more-popular',
      pageBuilder: (context, state) => _buildPageWithTransition(
        state,
        MorePopularScreen(),
      ),
    ),
    GoRoute(
        path: '/categroy/productlist',
        builder: (context, state) {
          final categroySelection = state.extra as CategorySelection;
          return CategoryProductListScreen(
            categorySelection: categroySelection,
          );
        }),
    GoRoute(
      path: '/shutterpost',
      builder: (context, state) => PostScreen(),
    ),
    GoRoute(
      path: '/product-detail',
      builder: (context, state) {
        final productId = state.extra as String;
        return ProductDetailScreen(
          productId: productId,
        );
      },
    ),
   GoRoute(
  path: '/payment',
  pageBuilder: (context, state) {
    // state.extra를 통해 전달된 OrderModel을 가져옴
    final order = state.extra as OrderModel;

    return _buildPageWithTransition(
      state,
      BlocProvider(
        create: (context) => PaymentBloc(
          orderRepository: context.read<OrderRepository>(), // OrderRepository를 주입
        )..add(InitializePayment(order)), // PaymentBloc에 초기화 이벤트 전달
        child: PaymentScreen(order: order),
      ),
    );
  },
),

    GoRoute(
      path: '/new_delivery_address',
      pageBuilder: (context, state) => _buildPageWithTransition(
        state,
        const NewDeliveryAddressScreen(),
      ),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchPage(),
    ),
    GoRoute(
      path: '/write_review',
      pageBuilder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        final availableOrderModel = data['availableOrderModel'] as AvailableOrderModel;
        final rating = data['rating'] as double;

        return _buildPageUpWithTransition(
          state, WriteReviewScreen(
            availableOrderModel: availableOrderModel,
            rating: rating,
          ),
        );
      },
    ),
    GoRoute(
      path: '/write_rating',
      builder: (context, state) {
        final availableOrderModel = state.extra as AvailableOrderModel;
        return WriteRatingScreen(availableOrderModel: availableOrderModel);
      },
    ),
    GoRoute(
      path: '/review_list',
      builder: (context, state) {
        return ReviewListScreen();
      },
    ),
    GoRoute(
      path: '/modify_review',
      builder: (context, state) {
        final reviewModel = state.extra as ReviewModel;
        return ModifyReviewScreen(reviewModel: reviewModel);
      },
    ),
    GoRoute(
      path: '/store_list',
      builder: (context, state) {
        final productModel = state.extra as ProductModel;
        return StoreListScreen(productModel: productModel);
      },
    ),
  ],
);

CustomTransitionPage<void> _buildPageWithTransition(
    GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

CustomTransitionPage<void> _buildPageUpWithTransition(
    GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}
