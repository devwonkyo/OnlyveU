class DeliveryInfoModel {
  //기본 주소
  final String address;
  //상세 주소
  final String detailAddress;
  //받는 이
  final String recipientName;
  //받는 이 전화 번호
  final String recipientPhone;
  //배송 요청 사항 (선택)
  final String? deliveryRequest;

  DeliveryInfoModel({
    required this.address,
    required this.detailAddress,
    required this.recipientName,
    required this.recipientPhone,
    this.deliveryRequest,
  });

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'detailAddress': detailAddress,
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'deliveryRequest': deliveryRequest,
    };
  }

  factory DeliveryInfoModel.fromMap(Map<String, dynamic> map) {
    return DeliveryInfoModel(
      address: map['address'],
      detailAddress: map['detailAddress'],
      recipientName: map['recipientName'],
      recipientPhone: map['recipientPhone'],
      deliveryRequest: map['deliveryRequest'],
    );
  }
}