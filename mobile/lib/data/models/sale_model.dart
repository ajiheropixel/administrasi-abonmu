import 'customer_model.dart';
import 'product_model.dart';

class SaleItemModel {
  final int id;
  final int productId;
  final int quantity;
  final double price;
  final double subtotal;
  final ProductModel? product;

  const SaleItemModel({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.subtotal,
    this.product,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) => SaleItemModel(
        id: json['id'] as int,
        productId: json['product_id'] as int,
        quantity: json['quantity'] as int,
        price: double.tryParse(json['price'].toString()) ?? 0,
        subtotal: double.tryParse(json['subtotal'].toString()) ?? 0,
        product: json['product'] != null
            ? ProductModel.fromJson(json['product'] as Map<String, dynamic>)
            : null,
      );
}

class SaleModel {
  final int id;
  final String invoiceNumber;
  final int? customerId;
  final String saleDate;
  final String type;
  final double totalAmount;
  final String? notes;
  final CustomerModel? customer;
  final List<SaleItemModel> items;
  final String? createdAt;

  const SaleModel({
    required this.id,
    required this.invoiceNumber,
    this.customerId,
    required this.saleDate,
    required this.type,
    required this.totalAmount,
    this.notes,
    this.customer,
    this.items = const [],
    this.createdAt,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) => SaleModel(
        id: json['id'] as int,
        invoiceNumber: json['invoice_number'] as String? ?? '',
        customerId: json['customer_id'] as int?,
        saleDate: json['sale_date'] as String,
        type: json['type'] as String,
        totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0,
        notes: json['notes'] as String?,
        customer: json['customer'] != null
            ? CustomerModel.fromJson(json['customer'] as Map<String, dynamic>)
            : null,
        items: (json['items'] as List<dynamic>?)
                ?.map((e) => SaleItemModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        createdAt: json['created_at'] as String?,
      );

  bool get isEcer => type == 'ecer';
}

