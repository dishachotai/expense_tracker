class CategoryModel {
  final int? id;
  final String categoryName;
  final String icon; // Icon name as string 
  final int? userId; // Null for default categories, non-null for custom categories

  CategoryModel({
    this.id,
    required this.categoryName,
    required this.icon,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'category_name': categoryName,
      'icon': icon,
      'user_id': userId,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      categoryName: map['category_name'] as String,
      icon: map['icon'] as String,
      userId: map['user_id'] as int?,
    );
  }
}
