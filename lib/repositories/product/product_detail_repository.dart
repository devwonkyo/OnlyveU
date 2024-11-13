import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/cart_model.dart';
import 'package:onlyveyou/models/product_model.dart';
import 'package:onlyveyou/models/result_model.dart';
import 'package:onlyveyou/models/user_model.dart';
import 'package:onlyveyou/utils/format_price.dart';
import 'package:onlyveyou/utils/shared_preference_util.dart';

class ProductDetailRepository{
  final FirebaseFirestore _firestore;

  ProductDetailRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // 단일 상품 조회
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final DocumentSnapshot doc =
      await _firestore.collection('products').doc(productId).get();

      if (doc.exists) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching product: $e');
      throw Exception('상품을 불러오는데 실패했습니다.');
    }
  }

  //카테고리별 필터로 상품 가져오기
  Future<List<ProductModel>> getProductsByFilter({
    required String filter,
    required bool isMainCategory,
  }) async {
    final querySnapshot = await _firestore
        .collection('products')
        .where(
      isMainCategory ? 'categoryId' : 'subcategoryId',
      isEqualTo: filter,
    )
        .get();

    return querySnapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data()))
        .toList();
  }


  // 장바구니에 상품 추가
  Future<Result> addToCart(ProductModel productModel) async {
    try {
      // 사용자 ID 가져오기
      final userId = await OnlyYouSharedPreference().getCurrentUserId();

      // Firestore에서 사용자 문서 가져오기
      final userDoc = _firestore.collection('users').doc(userId);
      final userSnapshot = await userDoc.get();

      if (!userSnapshot.exists) {
        return Result.failure("사용자를 찾을 수 없습니다.");
      }

      // UserModel로 변환
      final UserModel user = UserModel.fromMap(userSnapshot.data()!);

      // 중복 체크
      if (user.cartItems.any((item) => item.productId == productModel.productId)) {
        return Result.failure("이미 장바구니에 존재하는 상품입니다.");
      }

      // 새 아이템 생성
      final cartModel = CartModel(
        productId: productModel.productId,
        productName: productModel.name,
        productImageUrl: productModel.productImageList[0],
        productPrice: formatDiscountedPriceToInt(productModel.price, productModel.discountPercent.toDouble()),
      );

      // 장바구니에 추가
      user.cartItems.add(cartModel);

      // Firestore 업데이트 (트랜잭션 없이 단순 업데이트)
      await userDoc.update({
        'cartItems': user.cartItems.map((item) => item.toMap()).toList(),
      });

      return Result.success("상품이 장바구니에 추가되었습니다.");
    } catch (e) {
      return Result.failure("오류가 발생했습니다: ${e.toString()}");
    }
  }

  Future<void> toggleProductLike(String userId, String productId) async {
    try {
      // 1. User document 업데이트
      final userDoc = _firestore.collection('users').doc(userId);
      final userSnapshot = await userDoc.get();

      if (!userSnapshot.exists) {
        throw Exception('User not found');
      }

      final UserModel userModel = UserModel.fromMap(userSnapshot.data()!);
      List<String> likedItems = List<String>.from(userModel.likedItems);

      // 좋아요 토글
      if (likedItems.contains(productId)) {
        likedItems.remove(productId);
      } else {
        likedItems.add(productId);
      }

      // User document 업데이트
      await userDoc.update({'likedItems': likedItems});

      // 2. Product document 업데이트
      final productDoc = _firestore.collection('products').doc(productId);
      final productSnapshot = await productDoc.get();

      if (!productSnapshot.exists) {
        throw Exception('Product not found');
      }

      ProductModel productModel = ProductModel.fromMap(productSnapshot.data()!);
      List<String> favoriteList = List<String>.from(productModel.favoriteList);

      // 좋아요 토글
      if (favoriteList.contains(userId)) {
        favoriteList.remove(userId);
      } else {
        favoriteList.add(userId);
      }

      // Product document 업데이트
      await productDoc.update({'favoriteList': favoriteList});

    } catch (e) {
      throw Exception('Failed to toggle like: $e');
    }
  }
}


