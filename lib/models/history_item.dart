class HistoryItem {
  final String id;
  final String title;
  final String imageUrl;
  final int price;
  final int originalPrice;
  final int discountRate;
  final bool isBest;
  final bool isFavorite;
  final double rating;
  final int reviewCount;

  HistoryItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.originalPrice,
    required this.discountRate,
    required this.isBest,
    required this.isFavorite,
    required this.rating,
    required this.reviewCount,
  });

  // copyWith 메서드 추가
  HistoryItem copyWith({
    String? id,
    String? title,
    String? imageUrl,
    int? price,
    int? originalPrice,
    int? discountRate,
    bool? isBest,
    bool? isFavorite,
    double? rating,
    int? reviewCount,
  }) {
    return HistoryItem(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      discountRate: discountRate ?? this.discountRate,
      isBest: isBest ?? this.isBest,
      isFavorite: isFavorite ?? this.isFavorite,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
}
