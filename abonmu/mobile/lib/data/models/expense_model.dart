class ExpenseModel {
  final int id;
  final int? productionId;
  final String expenseDate;
  final String category;
  final double amount;
  final String? description;
  final Map<String, dynamic>? production;
  final String? createdAt;

  const ExpenseModel({
    required this.id,
    this.productionId,
    required this.expenseDate,
    required this.category,
    required this.amount,
    this.description,
    this.production,
    this.createdAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
        id: json['id'] as int,
        productionId: json['production_id'] as int?,
        expenseDate: json['expense_date'] as String,
        category: json['category'] as String,
        amount: double.tryParse(json['amount'].toString()) ?? 0,
        description: json['description'] as String?,
        production: json['production'] as Map<String, dynamic>?,
        createdAt: json['created_at'] as String?,
      );
}



