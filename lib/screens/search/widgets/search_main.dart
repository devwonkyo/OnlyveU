import 'package:flutter/material.dart';

class SearchMain extends StatelessWidget {
  const SearchMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '최근 검색어',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    RecentlySearchButton(name: '보습'),
                    SizedBox(width: 10),
                    RecentlySearchButton(name: '스킨'),
                    SizedBox(width: 10),
                    RecentlySearchButton(name: '아이라이너'),
                    SizedBox(width: 10),
                    RecentlySearchButton(name: '선크림'),
                    SizedBox(width: 10),
                    RecentlySearchButton(name: '쿠션'),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '추천 키워드',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10, // 각 위젯 사이의 간격
                children: [
                  FilledButton(onPressed: () {}, child: const Text('세미매트밀착쿠션')),
                  FilledButton(onPressed: () {}, child: const Text('콜라겐올인원')),
                  FilledButton(onPressed: () {}, child: const Text('히알루산올인원')),
                  FilledButton(onPressed: () {}, child: const Text('탱글젤리블리셔')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '급상승 검색어',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
  }
}

class RecentlySearchButton extends StatelessWidget {
  final String name;

  const RecentlySearchButton({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0)),
        child: Row(
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(width: 5),
            const Icon(
              Icons.close,
              size: 15,
            ),
          ],
        ));
  }
}
