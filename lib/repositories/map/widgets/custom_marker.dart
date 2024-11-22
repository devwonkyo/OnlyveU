import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onlyveyou/models/store_with_inventory_model.dart';

// class CustomMarker extends Marker {
//   final StoreWithInventoryModel store;
//
//   /// the old way
//   // CustomMarker({
//   //   required String markerId,
//   //   required this.store,
//   //   required LocationClass position,
//   //   required String text,
//   // }) : super(markerId: markerId, position: position, width: 30, height: 55, captionText: text, );
//
//   /// for SDK 2.17 and up - the new way
//   CustomMarker({required this.store, required super.position, super.width = 30, super.height = 45})
//       : super(markerId: store.storeId, captionText: store.storeName);
//
//   factory CustomMarker.fromMyStores(StoreType store) => CustomMarker(store: store, position: store.location);
//
//   Future<void> createImage(BuildContext context) async {
//     this.icon = await OverlayImage.fromAssetImage(assetName: this.store.markerImage, context: context);
//   }
//
//   void setOnMarkerTab(void Function(Marker marker, Map<String, int> iconSize) callBack){
//     this.onMarkerTab = callBack;
//   }
// }