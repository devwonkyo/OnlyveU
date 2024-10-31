class HistoryItem {
  final String id;
  final String title;
  final String imageUrl;
  final int price;
  final int? originalPrice;
  final int? discountRate;
  final bool isBest;
  final bool isFavorite;
  final double rating;
  final int reviewCount;

  HistoryItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.originalPrice,
    this.discountRate,
    this.isBest = false,
    this.isFavorite = false,
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'price': price,
      'originalPrice': originalPrice,
      'discountRate': discountRate,
      'isBest': isBest,
      'isFavorite': isFavorite,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }

  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      id: map['id'],
      title: map['title'],
      imageUrl: map['imageUrl'],
      price: map['price'],
      originalPrice: map['originalPrice'],
      discountRate: map['discountRate'],
      isBest: map['isBest'],
      isFavorite: map['isFavorite'],
      rating: map['rating'] ?? 0.0,
      reviewCount: map['reviewCount'] ?? 0,
    );
  }
}
