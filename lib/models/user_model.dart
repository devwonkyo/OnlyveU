class UserModel {
  String uid;
  String email;
  String nickname;
  List<String> recentSearches; // 최근 검색어
  List<String> likedItems; // 좋아요한 리스트
  List<String> cartItems; // 장바구니 아이템
  List<String> pickupItems; // 픽업 예약 아이템
  List<String> viewHistory; // 조회 히스토리
  String profileImageUrl; // 프로필 이미지 URL


  UserModel({
    required this.uid,
    required this.email,
    required this.nickname,
    this.profileImageUrl = '',
    this.recentSearches = const [],
    this.likedItems = const [],
    this.cartItems = const [],
    this.pickupItems = const [],
    this.viewHistory = const [],
  });

  // Firebase와 상호작용을 위한 toMap 및 fromMap 메서드도 추가 가능
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nickname': nickname,
      'profileImageUrl': profileImageUrl,
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
      profileImageUrl: map['profileImageUrl'] ?? '',
      recentSearches: List<String>.from(map['recentSearches'] ?? []),
      likedItems: List<String>.from(map['likedItems'] ?? []),
      cartItems: List<String>.from(map['cartItems'] ?? []),
      pickupItems: List<String>.from(map['pickupItems'] ?? []),
      viewHistory: List<String>.from(map['viewHistory'] ?? []),
    );
  }
}
