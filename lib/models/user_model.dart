class UserModel {
  String uid;
  String email;
  String nickname;
  String phone;   // 추가
  String gender;  // 추가
  List<String> recentSearches; // 최근 검색어
  List<String> likedItems; // 좋아요한 리스트
  List<String> cartItems; // 장바구니 아이템
  List<String> pickupItems; // 픽업 예약 아이템
  List<String> viewHistory; // 조회 히스토리

  UserModel({
    required this.uid,
    required this.email,
    required this.nickname,
    this.phone = '',    // 기본값 추가
    this.gender = '',   // 기본값 추가
    this.recentSearches = const [],
    this.likedItems = const [],
    this.cartItems = const [],
    this.pickupItems = const [],
    this.viewHistory = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nickname': nickname,
      'phone': phone,     // 추가
      'gender': gender,   // 추가
      'recentSearches': recentSearches,
      'likedItems': likedItems,
      'cartItems': cartItems,
      'pickupItems': pickupItems,
      'viewHistory': viewHistory,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      nickname: map['nickname'] ?? '',
      phone: map['phone'] ?? '',     // 추가
      gender: map['gender'] ?? '',    // 추가
      recentSearches: List<String>.from(map['recentSearches'] ?? []),
      likedItems: List<String>.from(map['likedItems'] ?? []),
      cartItems: List<String>.from(map['cartItems'] ?? []),
      pickupItems: List<String>.from(map['pickupItems'] ?? []),
      viewHistory: List<String>.from(map['viewHistory'] ?? []),
    );
  }
}