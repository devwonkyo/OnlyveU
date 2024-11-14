import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/home/ai_recommend_bloc.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';

class AIRecommendScreen extends StatefulWidget {
  const AIRecommendScreen({Key? key}) : super(key: key);

  @override
  State<AIRecommendScreen> createState() => _AIRecommendScreenState();
}

class _AIRecommendScreenState extends State<AIRecommendScreen> {
  late String _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    context.read<AIRecommendBloc>().add(LoadAIRecommendations());
  }

  Future<void> _loadUserId() async {
    _userId = await OnlyYouSharedPreference().getCurrentUserId();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AIRecommendBloc, AIRecommendState>(
      listener: (context, state) {
        if (state is AIRecommendError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('AI 맞춤 추천'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<AIRecommendBloc>().add(LoadAIRecommendations());
                },
              ),
            ],
          ),
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(AIRecommendState state) {
    if (state is AIRecommendLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is AIRecommendError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.message),
            ElevatedButton(
              onPressed: () {
                context.read<AIRecommendBloc>().add(LoadAIRecommendations());
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (state is AIRecommendLoaded) {
      if (state.products.isEmpty) {
        return Center(
          child: Text(state.message ?? '추천 상품이 없습니다'),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          context.read<AIRecommendBloc>().add(LoadAIRecommendations());
        },
        child: ListView.builder(
          itemCount: state.products.length,
          itemBuilder: (context, index) {
            final product = state.products[index];
            return _buildProductCard(
                product, state.recommendReasons[product.productId]);
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildProductCard(ProductModel product, String? recommendReason) {
    final discountedPrice = _calculateDiscountedPrice(
      product.price,
      product.discountPercent,
    );

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: InkWell(
        onTap: () => context.push('/product-detail', extra: product.productId),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductImage(product),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '${product.discountPercent}% 할인',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14.sp,
                          ),
                        ),
                        Text(
                          '$discountedPrice원',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (recommendReason != null) ...[
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 16.sp, color: Colors.blue),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          recommendReason,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      product.favoriteList.contains(_userId)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      context.read<AIRecommendBloc>().add(
                            ToggleProductFavorite(product, _userId),
                          );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () {
                      context.read<AIRecommendBloc>().add(
                            AddToCart(product, _userId),
                          );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(ProductModel product) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        product.productImageList.first,
        width: 100.w,
        height: 100.w,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 100.w,
          height: 100.w,
          color: Colors.grey.shade200,
          child: Icon(
            Icons
                .image_not_supported, // image_not_available 대신 image_not_supported 사용
            color: Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  String _calculateDiscountedPrice(String originalPrice, int discountPercent) {
    final price = int.parse(originalPrice.replaceAll(',', ''));
    final discountedPrice = price - (price * discountPercent / 100).round();
    return discountedPrice.toString();
  }
}
