// lib/data/dummy_history_items.dart
import 'package:onlyveyou/models/history_item.dart';

final List<HistoryItem> dummyHistoryItems = [
  HistoryItem(
    id: '1',
    title: '달바 화이트 트러플 세럼',
    imageUrl: 'assets/image/skin2.webp',
    price: 35000,
    originalPrice: 45000,
    discountRate: 22,
    isBest: true,
    isFavorite: true,
  ),
  HistoryItem(
    id: '2',
    title: '듀이트리 마데카소사이드 크림',
    imageUrl: 'assets/image/skin3.webp',
    price: 28000,
    originalPrice: 32000,
    discountRate: 12,
    isBest: true,
    isFavorite: false,
  ),
  HistoryItem(
    id: '3',
    title: '아누아 어성초 77 토너',
    imageUrl: 'assets/image/skin4.webp',
    price: 25000,
    originalPrice: 32000,
    discountRate: 21,
    isBest: false,
    isFavorite: true,
  ),
  HistoryItem(
    id: '4',
    title: '메디힐 콜라겐 마스크팩',
    imageUrl: 'assets/image/banner3.png',
    price: 16000,
    originalPrice: 20000,
    discountRate: 20,
    isBest: false,
    isFavorite: false,
  ),
];
