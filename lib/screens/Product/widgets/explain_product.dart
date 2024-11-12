import 'package:flutter/material.dart';

class ExpansionTileWidget extends StatelessWidget {
  final List<Map<String, String>> items = [
    {
      'title': '배송안내',
      'content': 'assets/image/product/info1.jpeg',
    },
    {
      'title': '교환/반품 불가안내',
      'content': 'assets/image/product/info2.jpeg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var item in items)
          Card(
            margin: EdgeInsets.symmetric(horizontal: 16.0,vertical: 8.0),
            child: ExpansionTile(
              title: Text(
                item['title']!,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
                side: BorderSide.none,
              ),
              children: [
                Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Image.asset(
                    item['content']!,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
