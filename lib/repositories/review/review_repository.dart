import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:onlyveyou/models/order_model.dart';
import 'package:onlyveyou/models/review_model.dart';

class ReviewRepository{
  final FirebaseFirestore _firestore;

  ReviewRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<ReviewModel>> findProductReview(String productId) async {
    try {
      // reviews 컬렉션에서 productId가 일치하는 문서들을 가져옴
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          // .orderBy('createdAt', descending: true) // 최신순 정렬
          .get();

      // 문서들을 ReviewModel 리스트로 변환
      final reviews = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return ReviewModel.fromMap({
          ...data,
          'reviewId': doc.id,  // doc.id를 추가
        });
      }).toList();

      return reviews;
    } catch (e) {
      print('리뷰 데이터 가져오기 실패: $e');
      return []; // 에러 발생 시 빈 리스트 반환
    }
  }

  Future<void> addLikeReview(String reviewId, String userId) async {
    try {
      // 파이어베이스에서 해당 reviewId의 문서 가져오기
      final reviewRef = FirebaseFirestore.instance
          .collection('reviews')
          .doc(reviewId);

      // 현재 문서의 likedUserIds 확인
      final doc = await reviewRef.get();
      List<String> likedUserIds = List<String>.from(doc.data()?['likedUserIds'] ?? []);

      // userId가 있으면 제거, 없으면 추가
      if (likedUserIds.contains(userId)) {
        await reviewRef.update({
          'likedUserIds': FieldValue.arrayRemove([userId])
        });
      } else {
        await reviewRef.update({
          'likedUserIds': FieldValue.arrayUnion([userId])
        });
      }
    } catch(e) {
      print('리뷰 데이터 가져오기 실패: $e');
    }
  }

  Future<void> addReview(ReviewModel reviewModel,List<File?> images, String orderId, String orderItemId) async {
    try {
      // 1. 사용자 이름 가져오기
      final userDoc = await _firestore
          .collection('users')
          .doc(reviewModel.userId)
          .get();
      final userName = userDoc.data()?['nickname'] as String;
      final userProfileImageUrl = userDoc.data()?['profileImageUrl'] as String;

      // 2. 리뷰 문서 생성하고 ID 받기
      final reviewRef = _firestore.collection('reviews').doc();
      final reviewId = reviewRef.id;

      // 3. 이미지 업로드 및 URL 수집
      List<String> imageUrls = [];
      final validImages = images.where((image) => image != null).cast<File>().toList();

      if (validImages.isNotEmpty) {
        for (var image in validImages) {
          try {
            // 파일명 생성: reviewId_timestamp_index.jpg
            final fileName = '${reviewId}_${DateTime.now().millisecondsSinceEpoch}_${validImages.indexOf(image)}.jpg';
            final storageRef = FirebaseStorage.instance
                .ref()
                .child('reviews')
                .child(reviewId)
                .child(fileName);

            // 이미지 업로드
            final uploadTask = await storageRef.putFile(
              image,
              SettableMetadata(
                contentType: 'image/jpeg',
                customMetadata: {
                  'reviewId': reviewId,
                  'userId': reviewModel.userId,
                },
              ),
            );

            // 업로드된 이미지의 URL 받기
            final downloadUrl = await uploadTask.ref.getDownloadURL();
            imageUrls.add(downloadUrl);
          } catch (e) {
            print('이미지 업로드 실패: $e');
            // 개별 이미지 업로드 실패 시 계속 진행
            continue;
          }
        }
      }

      // 3. 최종 리뷰 모델 생성
      final finalReview = reviewModel.copyWith(
        reviewId: reviewId,
        imageUrls: imageUrls,
        userName: userName,
        userProfileImageUrl: userProfileImageUrl
      );

      // 4. 리뷰 저장
      await reviewRef.set(finalReview.toMap());

      //오더 정보에 리뷰추가
      updateOrderItemReviewId(orderId: orderId, orderItemId: orderItemId, reviewId: reviewId);

      //제품 정보에 리뷰추가
      updateProductReviewListWithArrayUnion(productId: reviewModel.productId, reviewId:  reviewId);
    } catch (e) {
      throw Exception('리뷰 생성 실패: $e');
    }
  }

  //오더 아이템에 추가
  Future<void> updateOrderItemReviewId({
    required String orderId,
    required String orderItemId,
    required String reviewId,
  }) async {
    try {
      // 파이어베이스 인스턴스 가져오기
      final firestore = FirebaseFirestore.instance;

      // 1. 먼저 해당 주문 문서를 가져옵니다
      final orderDoc = await firestore.collection('orders').doc(orderId).get();

      if (!orderDoc.exists) {
        throw Exception('Order not found');
      }

      // 2. 주문 데이터를 OrderModel로 변환
      final orderData = orderDoc.data()!;
      final order = OrderModel.fromMap(orderData);

      // 3. items 배열에서 해당 orderItemId를 가진 아이템의 인덱스를 찾습니다
      final itemIndex = order.items.indexWhere(
              (item) => item.orderItemId == orderItemId
      );

      if (itemIndex == -1) {
        throw Exception('Order item not found');
      }

      // 4. Firestore 업데이트를 위한 새로운 items 배열 생성
      final updatedItems = List<Map<String, dynamic>>.from(
          orderData['items'] as List<dynamic>
      );

      // 5. 해당 인덱스의 아이템에 reviewId 추가
      updatedItems[itemIndex]['reviewId'] = reviewId;

      // 6. Firestore 문서 업데이트
      await firestore.collection('orders').doc(orderId).update({
        'items': updatedItems,
      });
    } catch (e) {
      print('주문 아이템 리뷰 ID 업데이트 실패: $e');
      rethrow;
    }
  }

  // product에 리뷰추가
  Future<void> updateProductReviewListWithArrayUnion({
    required String productId,
    required String reviewId,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;

      // arrayUnion을 사용하여 직접 업데이트
      await firestore.collection('products').doc(productId).update({
        'reviewList': FieldValue.arrayUnion([reviewId])
      });

      print('리뷰 리스트 업데이트 완료: $productId');
    } on FirebaseException catch (e) {
      print('Firebase 업데이트 실패: ${e.message}');
      throw e;
    } catch (e) {
      print('리뷰 리스트 업데이트 실패: $e');
      throw e;
    }
  }


  Future<List<ReviewModel>> findMyReview(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('userId', isEqualTo: userId)
          .get();

      // 문서들을 ReviewModel 리스트로 변환
      final reviews = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return ReviewModel.fromMap({
          ...data,
          'reviewId': doc.id,  // doc.id를 추가
        });
      }).toList();

      return reviews;
    } catch (e) {
      print('리뷰 데이터 가져오기 실패: $e');
      return [];
    }
  }


  Future<void> updateReview(ReviewModel reviewModel, List<String?> images) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final storage = FirebaseStorage.instance;

      List<String> newImageUrls = [];

      // 이미지 리스트가 null이 아니고 비어있지 않은 경우에만 처리
      if (images.isNotEmpty) {
        for (String? imagePath in images) {
          // null 체크
          if (imagePath == null) {
            print('Null 이미지 경로 발견. 건너뜁니다.');
            continue;
          }

          // URL인 경우 바로 추가
          if (imagePath.startsWith('http')) {
            newImageUrls.add(imagePath);
            continue;
          }

          // 로컬 파일 경로가 비어있지 않은 경우에만 업로드
          if (imagePath.isNotEmpty) {
            try {
              final ref = storage
                  .ref()
                  .child('reviews')
                  .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

              final file = File(imagePath);
              // 파일 존재 여부 확인
              if (!await file.exists()) {
                print('파일이 존재하지 않습니다: $imagePath');
                continue;
              }

              final uploadTask = await ref.putFile(
                file,
                SettableMetadata(
                  contentType: 'image/jpeg',
                  customMetadata: {
                    'reviewId': reviewModel.reviewId ?? '',
                    'uploadedAt': DateTime.now().toIso8601String(),
                  },
                ),
              );

              final downloadUrl = await uploadTask.ref.getDownloadURL();
              newImageUrls.add(downloadUrl);
            } catch (e) {
              print('개별 이미지 업로드 실패: $e');
              continue;
            }
          }
        }
      }

      // 업데이트할 데이터 맵 생성
      Map<String, dynamic> updateData = {
        'rating': reviewModel.rating,
        'content': reviewModel.content,
      };

      // 새로운 이미지 URL이 있는 경우에만 imageUrls 업데이트
      if (newImageUrls.isNotEmpty) {
        updateData['imageUrls'] = newImageUrls;
      }

      // reviewId null 체크
      if (reviewModel.reviewId == null) {
        throw Exception('Review ID is null');
      }

      // Firestore 업데이트
      await firestore.collection('reviews').doc(reviewModel.reviewId).update(updateData);

      print('리뷰 업데이트 완료: ${reviewModel.reviewId}');
      print('업데이트된 이미지 URLs: $newImageUrls');

    } on FirebaseException catch (e) {
      print('Firebase 오류: ${e.message}');
      throw Exception('Firebase 오류: ${e.message}');
    } catch (e) {
      print('업로드 에러: $e');
      throw Exception('업로드 에러: $e');
    }
  }




}