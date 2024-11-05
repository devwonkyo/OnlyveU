class InventoryModel {
  //상품상세화면에서 보여주니깐 맵 형식? 끌어오기?//
  /// 제품ID
  final String productId;

  /// 전체 재고 수량
  final int stock;

  /// 매장별 재고 현황 Map
  /// key: 매장 ID <- 여기에 storeId, store Id value , stock int들어가기, store name , store name value 까지 추가해서
  /// value: 해당 매장의 재고 수량  //
  /// 리스트 안에 객체가 들어간다고 정의도 되지만, 인벤토리를 하나만 하는게 낫다-리스트는 확장성이 떨어진다.
  /// 한화면만 보는게 아니라 강남점을 클릭하면 거기 있는걸 이것저것 조회할 때가 있다
  /// 강남점에 스토어 아이디 해서 다 가져오는게 낫다.
  ///[{“storeId” :”123124”, “storeName”:”강남점”, “stock”:20}, {“storeId:”5454”, “storeName”:”종로점”, “stock”:30}]
  ///
  /// 지점별 분리는 없을때는 차라리 ...
  /// 리스트 할려면 아예 한번에 다 하도록
  /// 혹은 리스트 안하고 하는 방식도 좋다
  /// 첫번째 : 인벤토리랑 1:1매칭, 두번째 : ?
  /// 강남점->강남 본점 으로 이름바뀌면 인벤토리 다 바꾸기 힘드니 ->확장성 있는데서는 바꾸기가 힘들다.
  /// 키값에 스토어 벨류가 있으면 안된다 [“강남점”:30, “종로점”:20] 이런식으로 하면
  /// 보여줄 수가 없다 포문 돌릴때 키값이 계속 바뀌니깐
  /// 너무 고민 보다는 지르기..매장이 5개면?
  ///
  final Map<String, int> storeStock; //<-리스트로 한화면에 보여주도록
  //A -> 30
  //B -> 20
  //storeStock['A']

  InventoryModel({
    required this.productId,
    required this.stock,
    required this.storeStock,
  });

  /// InventoryModel 객체를 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'stock': stock,
      'storeStock': storeStock,
    };
  }

  /// Map에서 InventoryModel 객체를 생성
  factory InventoryModel.fromMap(Map<String, dynamic> map) {
    return InventoryModel(
      productId: map['productId'] as String,
      stock: map['stock'] as int,
      storeStock: Map<String, int>.from(map['storeStock'] as Map),
    );
  }
}
