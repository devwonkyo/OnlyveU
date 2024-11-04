class StoreModel {
  /// 매장ID
  final String storeId;

  /// 매장명
  final String storeName;

  /// 매장 주소
  final String address;

  /// 매장 연락처
  final String phone;

  /// 매장 운영 시간
  final String businessHours;

  /// 매장 운영 여부
  final bool isActive;

  /// 매장 이미지
  final String imageUrl;

  /// StoreModel 클래스 생성자
  StoreModel({
    required this.storeId,
    required this.storeName,
    required this.address,
    required this.phone,
    required this.businessHours,
    required this.imageUrl,
    this.isActive = true,
  });

  /// StoreModel 객체를 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'storeId': storeId,
      'storeName': storeName,
      'address': address,
      'phone': phone,
      'businessHours': businessHours,
      'imageUrl': imageUrl,
      'isActive': isActive,
    };
  }

  /// Map에서 StoreModel 객체를 생성
  factory StoreModel.fromMap(Map<String, dynamic> map) {
    return StoreModel(
      storeId: map['storeId'] as String,
      storeName: map['storeName'] as String,
      address: map['address'] as String,
      phone: map['phone'] as String,
      businessHours: map['businessHours'] as String,
      imageUrl: map['imageUrl'] as String,
      isActive: map['isActive'] as bool? ?? true,
    );
  }
}