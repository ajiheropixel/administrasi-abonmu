class PaginationModel {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const PaginationModel({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) =>
      PaginationModel(
        currentPage: json['current_page'] as int,
        lastPage: json['last_page'] as int,
        perPage: json['per_page'] as int,
        total: json['total'] as int,
      );

  bool get hasNextPage => currentPage < lastPage;
}



