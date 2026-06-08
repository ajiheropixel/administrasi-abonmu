class CustomerModel {
  final int id;
  final String name;
  final String? phone;
  final String? address;
  final String? createdAt;

  const CustomerModel({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.createdAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
        id: json['id'] as int,
        name: json['name'] as String,
        phone: json['phone'] as String?,
        address: json['address'] as String?,
        createdAt: json['created_at'] as String?,
      );
}



