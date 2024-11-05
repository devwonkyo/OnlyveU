import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/blocs/product/productdetail_bloc.dart';
import 'package:onlyveyou/models/product_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late ScrollController _scrollController;
  bool _isAppBarVisible = true;
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _pageController = PageController();
    _scrollController.addListener(_scrollListener);
    context.read<ProductDetailBloc>().add(
      LoadProductDetail(widget.productId),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isAppBarVisible) setState(() => _isAppBarVisible = false);
    }
    if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_isAppBarVisible) setState(() => _isAppBarVisible = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // 앱바
              _buildAppBar(),
              // 상품 정보
              SliverToBoxAdapter(
                child: BlocBuilder<ProductDetailBloc, ProductDetailState>(
                  builder: (context, state) {
                    if (state is ProductDetailLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is ProductDetailError) {
                      return Center(child: Text(state.message));
                    }
                    if (state is ProductDetailLoaded) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImageSection(state.product),
                          _buildBrandSection(state.product),
                          _buildTitleSection(state.product),
                          _buildPriceSection(state.product),
                          _buildRatingSection(state.product),
                          _buildImageSection(state.product),
                          _buildImageSection(state.product),
                          _buildImageSection(state.product),
                          const SizedBox(height: 100), // 하단 버튼 공간
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
          // 하단 고정 버튼
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: false,
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.home, color: Colors.black),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.shopping_cart, color: Colors.black),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildImageSection(ProductModel product) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: PageView.builder(
            controller: _pageController,
            itemCount: product.productImageList.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.network(
                product.productImageList[index],
                fit: BoxFit.cover,
              );
            },
          ),
        ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              product.productImageList.length,
                  (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo(ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 브랜드 섹션
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                product.brandName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),

        // 제품명 섹션
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            product.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),

        // 가격 섹션
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${product.discountPercent}%',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    '${product.price}원',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${product.price}원',
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 평점 섹션
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.amber),
              Text(
                product.rating.toString(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 8),
              Text(
                '리뷰 ${product.reviewList.length}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('장바구니'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('바로구매'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}