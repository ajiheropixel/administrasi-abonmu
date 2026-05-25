class EmployeeModel {
  final int id;
  final String name;
  final String? position;
  final String? phone;
  final String? address;
  final double? salary;
  final double? productionRate;
  final double? packingRate;
  final bool isActive;
  final String? createdAt;

  const EmployeeModel({
    required this.id,
    required this.name,
    this.position,
    this.phone,
    this.address,
    this.salary,
    this.productionRate,
    this.packingRate,
    this.isActive = true,
    this.createdAt,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) => EmployeeModel(
        id: json['id'] as int,
        name: json['name'] as String,
        position: json['position'] as String?,
        phone: json['phone'] as String?,
        address: json['address'] as String?,
        salary: json['salary'] != null
            ? double.tryParse(json['salary'].toString())
            : null,
        productionRate: json['production_rate'] != null
            ? double.tryParse(json['production_rate'].toString())
            : null,
        packingRate: json['packing_rate'] != null
            ? double.tryParse(json['packing_rate'].toString())
            : null,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: json['created_at'] as String?,
      );
}

