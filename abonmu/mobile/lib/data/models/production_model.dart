import 'product_model.dart';
import 'expense_model.dart';

class ProductionCreator {
  final int id;
  final String name;
  const ProductionCreator({required this.id, required this.name});

  factory ProductionCreator.fromJson(Map<String, dynamic> json) =>
      ProductionCreator(
        id: json['id'] as int,
        name: json['name'] as String,
      );
}

class ProductionModel {
  final int id;
  final int productId;
  final String productionDate;
  final int quantity;
  final String type;
  final String category;
  final String? notes;
  final ProductModel? product;
  final List<ExpenseModel>? expenses;
  final ProductionCreator? createdBy;
  final ProductionCreator? updatedBy;
  final String? createdAt;
  final String? updatedAt;

  const ProductionModel({
    required this.id,
    required this.productId,
    required this.productionDate,
    required this.quantity,
    required this.type,
    required this.category,
    this.notes,
    this.product,
    this.expenses,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductionModel.fromJson(Map<String, dynamic> json) => ProductionModel(
        id: json['id'] as int,
        productId: json['product_id'] as int,
        productionDate: json['production_date'] as String,
        quantity: json['quantity'] as int,
        type: json['type'] as String,
        category: json['category'] as String? ?? '',
        notes: json['notes'] as String?,
        product: json['product'] != null
            ? ProductModel.fromJson(json['product'] as Map<String, dynamic>)
            : null,
        expenses: (json['expenses'] as List<dynamic>?)
            ?.map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdBy: json['created_by'] is Map
            ? ProductionCreator.fromJson(json['created_by'] as Map<String, dynamic>)
            : null,
        updatedBy: json['updated_by'] is Map
            ? ProductionCreator.fromJson(json['updated_by'] as Map<String, dynamic>)
            : null,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
      );

  bool get isRutin => type == 'rutin';
}
