import 'package:daum_postcode_search/daum_postcode_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class SearchingPage extends StatefulWidget {
  const SearchingPage({super.key});

  @override
  _SearchingPageState createState() => _SearchingPageState();
}

class _SearchingPageState extends State<SearchingPage> {
  bool _isError = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    DaumPostcodeSearch daumPostcodeSearch = DaumPostcodeSearch(
      onConsoleMessage: (controller, message) => print(message.message),
      onReceivedError: (controller, request, error) {
        setState(() {
          _isError = true;
          errorMessage = error.description;
        });
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("주소 검색"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                daumPostcodeSearch,
                if (_isError)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(errorMessage ?? "알 수 없는 오류가 발생했습니다."),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isError = false;
                            });
                            daumPostcodeSearch.controller?.reload();
                          },
                          child: const Text("Refresh"),
                        ),
                      ],
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
