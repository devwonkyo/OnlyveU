import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/inventory/inventory_bloc.dart';
import 'package:onlyveyou/config/color.dart';
import 'package:onlyveyou/core/router.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/models/store_model.dart';
import 'package:onlyveyou/models/store_with_inventory_model.dart';
import 'package:onlyveyou/utils/format_price.dart';
import 'package:onlyveyou/widgets/cartItmes_appbar.dart';

class StoreListScreen extends StatefulWidget {
  final ProductModel productModel;

  const StoreListScreen({
    super.key,
    required this.productModel,
  });

  @override
  State<StoreListScreen> createState() => _StoreListScreenState();
}

class _StoreListScreenState extends State<StoreListScreen> {
  late TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    context.read<InventoryBloc>().add(
      GetStoreListWithProductIdEvent(widget.productModel.productId),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchStores(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<StoreWithInventoryModel> _getFilteredStores(List<StoreWithInventoryModel> stores) {
    if (_searchQuery.isEmpty) {
      return stores;
    }
    return stores.where((store) =>
    store.storeName.toLowerCase().contains(_searchQuery) ||
        store.address.toLowerCase().contains(_searchQuery)
    ).toList();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CartItemsAppBar(
        appTitle: '구매가능 온니브 유 매장',
      ),
      body: Column(
        children: [
          _buildProductCard(),
          _buildSearchBar(),
          _buildInfoText(),
          Expanded(
            child: BlocBuilder<InventoryBloc, InventoryState>(
              builder: (context, state) {
                if (state is InventoryLoadStoreLoading) {
                  return _buildLoadingState();
                } else if (state is InventoryLoadStoreError) {
                  return _buildErrorState(state);
                } else if (state is InventoryLoadedStore) {
                  final filteredStores = _getFilteredStores(state.storeList);
                  if (filteredStores.isEmpty && _searchQuery.isNotEmpty) {
                    return _buildNoSearchResultsState();
                  }
                  return filteredStores.isEmpty
                      ? _buildEmptyState()
                      : _buildStoreList(filteredStores);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildNoSearchResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 48.sp,
            color: Colors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            '검색 결과가 없습니다.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '다른 검색어를 입력해보세요.',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16.h),
          Text(
            '매장 정보를 불러오는 중입니다...',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(InventoryLoadStoreError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48.sp,
            color: Colors.red,
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              state.message,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              context.read<InventoryBloc>().add(
                GetStoreListWithProductIdEvent(widget.productModel.productId),
              );
            },
            child: Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    return GestureDetector(
      onTap: () {
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                image: DecorationImage(
                  image: NetworkImage(widget.productModel.productImageList[0]),
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
                    widget.productModel.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Text(
                        "${widget.productModel.discountPercent}%",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "${formatDiscountedPriceToString(
                          widget.productModel.price,
                          widget.productModel.discountPercent.toDouble(),
                        )}원",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '매장 이름, 주소 검색',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14.sp,
                  ),
                ),
                onChanged: _searchStores,
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  _searchController.clear();
                  _searchStores('');
                },
              )
            else
              Icon(Icons.search, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoText() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Text(
        '매장의 상황에 따라 실제 재고 수량과 차이가 있을 수 있어요',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12.sp,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_outlined,
            size: 48.sp,
            color: Colors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            '검색 결과가 없습니다.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreList(List<StoreWithInventoryModel> stores) {
    return ListView.builder(
      itemCount: stores.length,
      itemBuilder: (context, index) {
        final store = stores[index];
        return _buildStoreItem(
          storeModel: store
        );
      },
    );
  }

  Widget _buildStoreItem({
    required StoreWithInventoryModel storeModel
  }) {
    String stockText;
    Color stockColor;

    if (int.parse(storeModel.quantity.toString()) >= 10) {
      stockText = "재고 10개 이상";
      stockColor = AppsColor.pastelGreen;  // 연두색
    } else if (int.parse(storeModel.quantity.toString()) >= 5) {
      stockText = "재고 5개 이상";
      stockColor = Colors.orange;  // 주황색
    } else if (int.parse(storeModel.quantity.toString()) > 0) {
      stockText = "재고 ${storeModel.quantity}개";
      stockColor = Colors.red;  // 빨간색
    } else {
      stockText = "재고 없음";
      stockColor = Colors.grey;  // 회색
    }

    return GestureDetector(
      onTap: (){
        context.push("/store_map",extra: storeModel);
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.network(
                storeModel.imageUrl,
                width: 80.w,
                height: 80.w,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storeModel.storeName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    storeModel.address,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    stockText,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: stockColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        storeModel.isActive ? "영업 중 " : "영업 종료",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        " - ",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        "${storeModel.businessHours}",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: ElevatedButton.icon(
        onPressed: () {
          context.go('/home');
        },
        icon: Icon(Icons.store, color: Colors.black, size: 20.sp),
        label: Text(
          '온니브유 홈',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14.sp,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}