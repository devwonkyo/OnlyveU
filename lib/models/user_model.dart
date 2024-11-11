import 'package:onlyveyou/models/cart_model.dart';

class UserModel {
  String uid;
  String email;
  String nickname;
  String phone; // 추가된 전화번호
  String gender; // 추가된 성별
  List<String> recentSearches; // 최근 검색어 리스트
  List<String> likedItems; // 좋아요한 아이템 리스트
  List<CartModel> cartItems; // 장바구니 아이템 리스트
  List<CartModel> pickupItems; // 픽업 예약 아이템 리스트
  List<String> viewHistory; // 조회 히스토리
  String profileImageUrl; // 프로필 이미지 URL

  UserModel({
    required this.uid,
    required this.email,
    required this.nickname,
    this.phone = '',
    this.gender = '',
    this.recentSearches = const [],
    this.likedItems = const [],
    this.cartItems = const [],
    this.pickupItems = const [],
    this.viewHistory = const [],
    this.profileImageUrl = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nickname': nickname,
      'phone': phone,
      'gender': gender,
      'recentSearches': recentSearches,
      'likedItems': likedItems,
      'cartItems': cartItems.map((item) => item.toMap()).toList(),
      'pickupItems': pickupItems.map((item) => item.toMap()).toList(),
      'viewHistory': viewHistory,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      nickname: map['nickname'],
      phone: map['phone'] ?? '',
      gender: map['gender'] ?? '',
      recentSearches: List<String>.from(map['recentSearches'] ?? []),
      likedItems: List<String>.from(map['likedItems'] ?? []),
      cartItems: List<CartModel>.from(
        map['cartItems']?.map((item) => CartModel.fromMap(item)) ?? [],
      ),
      pickupItems: List<CartModel>.from(
        map['pickupItems']?.map((item) => CartModel.fromMap(item)) ?? [],
      ),
      viewHistory: List<String>.from(map['viewHistory'] ?? []),
      profileImageUrl: map['profileImageUrl'] ?? '',
    );
  }
}