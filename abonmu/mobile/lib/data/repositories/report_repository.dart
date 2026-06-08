import '../../core/network/api_client.dart';

class ReportRepository {
  Future<Map<String, dynamic>> getIntegratedReport({
    String? startDate,
    String? endDate,
    String? category,
    String? type,
    int? productId,
  }) async {
    final response = await ApiClient.get('reports/integrated', params: {
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (category != null) 'category': category,
      if (type != null) 'type': type,
      if (productId != null) 'product_id': productId.toString(),
    });
    return response['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getProductionReport({
    String? startDate,
    String? endDate,
    String? category,
    String? type,
    int? productId,
  }) async {
    final response = await ApiClient.get('reports/production', params: {
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (category != null) 'category': category,
      if (type != null) 'type': type,
      if (productId != null) 'product_id': productId.toString(),
    });
    return response['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSalesReport({
    String? startDate,
    String? endDate,
  }) async {
    final response = await ApiClient.get('reports/sales', params: {
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
    });
    return response['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getExpenseReport({
    String? startDate,
    String? endDate,
  }) async {
    final response = await ApiClient.get('reports/expenses', params: {
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
    });
    return response['data'] as Map<String, dynamic>;
  }
}



