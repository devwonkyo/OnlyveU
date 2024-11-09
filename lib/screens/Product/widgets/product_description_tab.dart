// 탭 컨텐츠 위젯들
import 'package:flutter/material.dart';
import 'package:onlyveyou/models/product_model.dart';

class ProductDescriptionTab extends StatelessWidget {
  final ProductModel product;

  const ProductDescriptionTab({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: product.descriptionImageList.map((url) {
          return Image.network(
            url,
            width: double.infinity,
            fit: BoxFit.cover,
          );
        }).toList(),
      ),
    );
  }
}