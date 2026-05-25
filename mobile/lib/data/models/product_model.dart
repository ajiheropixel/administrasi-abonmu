class ProductModel {
  final int id;
  final String name;
  final String category;
  final String? description;
  final double price;
  final int stock;
  final String unit;
  final String? createdAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    required this.price,
    required this.stock,
    required this.unit,
    this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'] as int,
        name: json['name'] as String,
        category: json['category'] as String? ?? '',
        description: json['description'] as String?,
        price: double.tryParse(json['price'].toString()) ?? 0,
        stock: json['stock'] as int? ?? 0,
        unit: json['unit'] as String? ?? 'pcs',
        createdAt: json['created_at'] as String?,
      );

  bool get isLowStock => stock < 50;
  bool get isCriticalStock => stock < 20;
}

