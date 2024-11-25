class Category {
  final String id;
  final String name;
  final String? icon;
  final List<Subcategory> subcategories;

  Category({
    required this.id,
    required this.name,
    this.icon,
    required this.subcategories,
  });

  factory Category.fromFirestore(Map<String, dynamic> data) {
    return Category(
      id: data['id'],
      name: data['name'],
      icon: data['icon'],
      subcategories: (data['subcategories'] as List)
          .map((e) => Subcategory.fromMap(e))
          .toList(),
    );
  }
}

class Subcategory {
  final String id;
  final String name;

  Subcategory({
    required this.id,
    required this.name,
  });

  factory Subcategory.fromMap(Map<String, dynamic> data) {
    return Subcategory(
      id: data['id'],
      name: data['name'],
    );
  }
}