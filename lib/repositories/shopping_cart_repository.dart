import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyveyou/models/cart_model.dart';
import 'package:onlyveyou/models/order_item_model.dart';

import '../utils/shared_preference_util.dart';

class ShoppingCartRepository {
  final FirebaseFirestore _firestore;

  ShoppingCartRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  //1. 장바구니에 상품 추가
  Future<void> addToCart(String productId) async {
    try {
      final userId = await OnlyYouSharedPreference().getCurrentUserId();

      await _firestore.runTransaction((transaction) async {
        // 1. 상품 문서 확인
        final productDoc =
            await _firestore.collection('products').doc(productId).get();
        if (!productDoc.exists) {
          throw Exception('상품을 찾을 수 없습니다.');
        }

        // 2. 사용자 문서 가져오기
        final userDoc = _firestore.collection('users').doc(userId);
        final userSnapshot = await transaction.get(userDoc);

        // 3. 장바구니 아이템 확인 (일반 배송)
        List<Map<String, dynamic>> cartItems = [];
        if (userSnapshot.exists &&
            userSnapshot.data()!.containsKey('cartItems')) {
          cartItems =
              List<Map<String, dynamic>>.from(userSnapshot.get('cartItems'));
        }

        // 4. 픽업 아이템 확인
        List<Map<String, dynamic>> pickupItems = [];
        if (userSnapshot.exists &&
            userSnapshot.data()!.containsKey('pickupItems')) {
          pickupItems =
              List<Map<String, dynamic>>.from(userSnapshot.get('pickupItems'));
        }

        // 5. 중복 체크 (둘 다에서 확인)
        bool isDuplicate =
            cartItems.any((item) => item['productId'] == productId) ||
                pickupItems.any((item) => item['productId'] == productId);

        if (isDuplicate) {
          throw '이 상품은 이미 장바구니에 담겨 있습니다.';
        }

        // 6. 새 아이템 생성
        final cartItem = {
          'productId': productId,
          'productName': productDoc.get('name'),
          'productImageUrl':
              (productDoc.get('productImageList') as List<dynamic>).first,
          'productPrice': int.parse(productDoc.get('price')),
          'quantity': 1,
        };

        // 7. 장바구니에 추가
        cartItems.add(cartItem);

        // 8. Firestore 업데이트
        if (!userSnapshot.exists) {
          transaction.set(userDoc, {'cartItems': cartItems, 'pickupItems': []});
        } else {
          transaction.update(userDoc, {'cartItems': cartItems});
        }
      });
    } catch (e) {
      if (e is Exception && e.toString().contains('이 상품은 이미 장바구니에 담겨 있습니다')) {
        rethrow; // 중복 에러는 그대로 전파
      }
      throw '이 상품은 이미 장바구니에 담겨 있습니다.'; // 기타 에러는 일반화된 메시지로
    }
  }

  // 장바구니 데이터 로드
  Future<Map<String, List<CartModel>>> loadCartItems() async {
    try {
      final userId = await OnlyYouSharedPreference().getCurrentUserId();
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return {'regular': [], 'pickup': []};
      }

      // cartItems가 있으면 가져오고, 없으면 빈 배열 반환
      List<Map<String, dynamic>> regularCartItems = [];
      if (userDoc.data()!.containsKey('cartItems')) {
        regularCartItems =
            List<Map<String, dynamic>>.from(userDoc.get('cartItems'));
      }

      // pickupItems가 있으면 가져오고, 없으면 빈 배열 반환
      List<Map<String, dynamic>> pickupItems = [];
      if (userDoc.data()!.containsKey('pickupItems')) {
        pickupItems =
            List<Map<String, dynamic>>.from(userDoc.get('pickupItems'));
      }

      return {
        'regular':
            regularCartItems.map((item) => CartModel.fromMap(item)).toList(),
        'pickup': pickupItems.map((item) => CartModel.fromMap(item)).toList(),
      };
    } catch (e) {
      throw Exception('장바구니 상품을 불러오는데 실패했습니다.');
    }
  }

  // 배송 방식 변경 (일반 -> 픽업)
  Future<void> moveToPickup(List<String> productIds) async {
    try {
      final userId = await OnlyYouSharedPreference().getCurrentUserId();
      final userDoc = _firestore.collection('users').doc(userId);

      // 먼저 document 존재 여부 확인 및 pickupItems 필드 초기화
      final docSnapshot = await userDoc.get();
      if (!docSnapshot.exists) {
        print('User document does not exist');
        throw Exception('사용자 정보를 찾을 수 없습니다.');
      }

      // pickupItems 필드가 없으면 빈 배열로 초기화
      if (!docSnapshot.data()!.containsKey('pickupItems')) {
        print('Initializing pickupItems field');
        await userDoc.update({'pickupItems': []});
      }

      // 이제 transaction 실행
      await _firestore.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userDoc);

        // 현재 cartItems와 pickupItems 가져오기
        List<Map<String, dynamic>> cartItems = List<Map<String, dynamic>>.from(
            userSnapshot.get('cartItems') ?? []);
        List<Map<String, dynamic>> pickupItems =
            List<Map<String, dynamic>>.from(
                userSnapshot.get('pickupItems') ?? []);

        print('Current cartItems count: ${cartItems.length}');
        print('Current pickupItems count: ${pickupItems.length}');

        // 선택된 상품들을 찾아서 이동
        final itemsToMove = cartItems
            .where((item) => productIds.contains(item['productId']))
            .toList();

        print('Items to move count: ${itemsToMove.length}');

        // cartItems에서 선택된 상품들 제거
        cartItems.removeWhere((item) => productIds.contains(item['productId']));

        // pickupItems에 이동할 상품들 추가
        pickupItems.addAll(itemsToMove);

        // Firestore 업데이트
        transaction.update(userDoc, {
          'cartItems': cartItems,
          'pickupItems': pickupItems,
        });

        print('Successfully moved items to pickup');
      });
    } catch (e) {
      print('Error moving items to pickup: $e');
      print('Error stack trace: ${StackTrace.current}');
      throw Exception('배송 방식 변경에 실패했습니다.');
    }
  }

  // 배송 방식 변경 (픽업 -> 일반)
  Future<void> moveToRegularDelivery(List<String> productIds) async {
    try {
      final userId = await OnlyYouSharedPreference().getCurrentUserId();

      await _firestore.runTransaction((transaction) async {
        final userDoc = _firestore.collection('users').doc(userId);
        final userSnapshot = await transaction.get(userDoc);

        // 현재 cartItems와 pickupItems 가져오기
        List<Map<String, dynamic>> cartItems = List<Map<String, dynamic>>.from(
            userSnapshot.get('cartItems') ?? []);

        List<Map<String, dynamic>> pickupItems =
            List<Map<String, dynamic>>.from(
                userSnapshot.get('pickupItems') ?? []);

        // 선택된 상품들을 찾아서 이동
        final itemsToMove = pickupItems
            .where((item) => productIds.contains(item['productId']))
            .toList();

        // pickupItems에서 선택된 상품들 제거
        pickupItems
            .removeWhere((item) => productIds.contains(item['productId']));

        // cartItems에 이동할 상품들 추가
        cartItems.addAll(itemsToMove);

        // Firestore 업데이트
        transaction.update(userDoc, {
          'cartItems': cartItems,
          'pickupItems': pickupItems,
        });
      });
    } catch (e) {
      print('Error moving items to regular delivery: $e');
      throw Exception('배송 방식 변경에 실패했습니다.');
    }
  }

  // 상품 삭제
  Future<void> removeProduct(String productId, bool isPickup) async {
    try {
      final userId = await OnlyYouSharedPreference().getCurrentUserId();
      final userDoc = _firestore.collection('users').doc(userId);
      final field = isPickup ? 'pickupItems' : 'cartItems';

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        List<Map<String, dynamic>> items =
            List<Map<String, dynamic>>.from(snapshot.get(field) ?? []);
        items.removeWhere((item) => item['productId'] == productId);
        transaction.update(userDoc, {field: items});
      });
    } catch (e) {
      print('Error removing product: $e');
      throw Exception('상품 삭제에 실패했습니다.');
    }
  }

  // 선택된 상품들 삭제
  Future<void> removeSelectedProducts(
      List<String> productIds, bool isPickup) async {
    try {
      final userId = await OnlyYouSharedPreference().getCurrentUserId();
      final userDoc = _firestore.collection('users').doc(userId);
      final field = isPickup ? 'pickupItems' : 'cartItems';

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        List<Map<String, dynamic>> items =
            List<Map<String, dynamic>>.from(snapshot.get(field) ?? []);
        items.removeWhere((item) => productIds.contains(item['productId']));
        transaction.update(userDoc, {field: items});
      });
    } catch (e) {
      print('Error removing selected products: $e');
      throw Exception('선택된 상품 삭제에 실패했습니다.');
    }
  }

  // 상품 수량 업데이트
  Future<void> updateProductQuantity(
      String productId, int quantity, bool isPickup) async {
    try {
      final userId = await OnlyYouSharedPreference().getCurrentUserId();
      final userDoc = _firestore.collection('users').doc(userId);
      final field = isPickup ? 'pickupItems' : 'cartItems';

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        List<Map<String, dynamic>> items =
            List<Map<String, dynamic>>.from(snapshot.get(field) ?? []);

        final itemIndex =
            items.indexWhere((item) => item['productId'] == productId);
        if (itemIndex >= 0) {
          items[itemIndex]['quantity'] = quantity;
          transaction.update(userDoc, {field: items});
        }
      });
    } catch (e) {
      print('Error updating product quantity: $e');
      throw Exception('상품 수량 업데이트에 실패했습니다.');
    }
  }

  //1. 데이터 넘겨줄때 카트 모델에서 오더모델로 타입 전환
  Future<List<OrderItemModel>> getSelectedOrderItems(
      bool isRegularDelivery) async {
    try {
      print(
          'Fetching ${isRegularDelivery ? "Regular Delivery" : "Pickup"} items');
      final userId = await OnlyYouSharedPreference().getCurrentUserId();
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        return [];
      }
      final field = isRegularDelivery ? 'cartItems' : 'pickupItems';
      final items = List<Map<String, dynamic>>.from(userDoc.get(field) ?? []);
      print('Found ${items.length} items to convert');

      return items
          .map((item) => OrderItemModel(
                productId: item['productId'],
                productName: item['productName'],
                productImageUrl: item['productImageUrl'],
                productPrice: item['productPrice'],
                quantity: item['quantity'] ?? 1,
              ))
          .toList();
    } catch (e) {
      print('Error in getSelectedOrderItems: $e');
      throw Exception('주문 상품 변환에 실패했습니다.');
    }
  }
}
///////////////
// Future<List<OrderItemModel>> getSelectedOrderItems(bool isRegularDelivery) async {
//   try {
//     // isRegularDelivery: true면 일반배송, false면 픽업배송을 의미하는 boolean 매개변수
//     // 현재 어떤 배송 타입의 아이템을 가져오는지 디버깅용 로그 출력
//     print('Fetching ${isRegularDelivery ? "Regular Delivery" : "Pickup"} items');
//
//     // 1. SharedPreferences에서 현재 로그인한 사용자의 고유 ID를 비동기로 가져옴
//     final userId = await OnlyYouSharedPreference().getCurrentUserId();
//
//     // 2. Firestore 데이터베이스에서 users 컬렉션의 해당 userId 문서를 가져옴
//     // get(): Firestore에서 문서를 한 번만 읽어오는 비동기 메서드
//     final userDoc = await _firestore.collection('users').doc(userId).get();
//     if (!userDoc.exists) {
//       // 해당 사용자의 문서가 존재하지 않으면 빈 리스트를 반환
//       return [];
//     }

//     // 3. isRegularDelivery 값에 따라 가져올 필드명을 결정
//     // field: Firestore 문서 내의 특정 필드(속성)를 지정하는 문자열
//     final field = isRegularDelivery ? 'cartItems' : 'pickupItems';
//
//     // 4. Firestore 문서에서 해당 필드의 데이터를 List<Map<String, dynamic>> 형태로 변환
//     // List.from(): 기존 컬렉션으로부터 새로운 List를 생성
//     // userDoc.get(field): 문서에서 특정 필드의 값을 가져옴
//     // ?? []: null일 경우 빈 리스트를 기본값으로 사용
//     final items = List<Map<String, dynamic>>.from(userDoc.get(field) ?? []);
//     print('Found ${items.length} items to convert'); // 변환할 아이템 수 로그 출력
//
//     // 5. CartModel 데이터를 OrderItemModel 객체로 변환
//     // map(): 리스트의 각 요소를 변환하여 새로운 리스트 생성
//     // toList(): Iterable을 List로 변환
//     return items
//         .map((item) => OrderItemModel(
//       // Map의 각 키-값 쌍을 OrderItemModel의 필드로 매핑
//       productId: item['productId'],        // 상품 고유 ID
//       productName: item['productName'],    // 상품명
//       productImageUrl: item['productImageUrl'], // 상품 이미지 URL
//       productPrice: item['productPrice'],  // 상품 가격
//       quantity: item['quantity'] ?? 1,     // 수량(없으면 기본값 1)
//     ))
//         .toList();
//   } catch (e) {
//     // 예외 처리: 변환 과정에서 발생하는 모든 에러를 잡아서 처리
//     print('Error in getSelectedOrderItems: $e'); // 에러 내용 로그 출력
//     throw Exception('주문 상품 변환에 실패했습니다.'); // 사용자에게 보여줄 에러 메시지
//   }
// }
