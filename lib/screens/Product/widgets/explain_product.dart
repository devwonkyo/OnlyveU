import 'package:flutter/material.dart';

class ExpansionTileExample extends StatelessWidget {
  final List<Map<String, String>> items = [
    {
      'title': '첫 번째 항목',
      'content': '첫 번째 항목의 상세 내용입니다. 여기에 원하는 내용을 넣으세요.',
    },
    {
      'title': '두 번째 항목',
      'content': '두 번째 항목의 상세 내용입니다. 여기에 원하는 내용을 넣으세요.',
    },
    {
      'title': '세 번째 항목',
      'content': '세 번째 항목의 상세 내용입니다. 여기에 원하는 내용을 넣으세요.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.all(8.0),
              child: ExpansionTile(
                title: Text(
                  items[index]['title']!,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      items[index]['content']!,
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
