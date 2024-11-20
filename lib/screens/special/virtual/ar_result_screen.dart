import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ArResultScreen extends StatelessWidget {
  const ArResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('촬영 결과', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.save_alt),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(8.w),
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: Text('Before'),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(8.w),
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: Text('After'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: Icon(Icons.refresh),
                  label: Text('다시 시도'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => context.push('/ar/save'),
                  icon: Icon(Icons.check),
                  label: Text('저장하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
