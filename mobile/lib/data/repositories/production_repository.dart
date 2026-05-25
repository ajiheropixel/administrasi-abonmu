import '../../core/network/api_client.dart';
import '../models/production_model.dart';
import '../models/pagination_model.dart';

class ProductionRepository {
  Future<Map<String, dynamic>> getProductions({
    String? category,
    String? type,
    int? productId,
    String? startDate,
    String? endDate,
    int page = 1,
    int perPage = 15,
  }) async {
    final response = await ApiClient.get('productions', params: {
      if (category != null) 'category': category,
      if (type != null) 'type': type,
      if (productId != null) 'product_id': productId.toString(),
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      'page': page.toString(),
      'per_page': perPage.toString(),
    });
    return {
      'data': (response['data'] as List<dynamic>)
          .map((e) => ProductionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      'pagination': PaginationModel.fromJson(
          response['pagination'] as Map<String, dynamic>),
    };
  }

  Future<ProductionModel> getProduction(int id) async {
    final response = await ApiClient.get('productions/$id');
    return ProductionModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> getStatistics({
    String? startDate,
    String? endDate,
    String? category,
    String? type,
  }) async {
    final response = await ApiClient.get('productions/statistics', params: {
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (category != null) 'category': category,
      if (type != null) 'type': type,
    });
    return response['data'] as Map<String, dynamic>;
  }

  Future<ProductionModel> createProduction(Map<String, dynamic> data) async {
    final response = await ApiClient.post('productions', body: data);
    return ProductionModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<ProductionModel> updateProduction(
      int id, Map<String, dynamic> data) async {
    final response = await ApiClient.put('productions/$id', body: data);
    return ProductionModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> deleteProduction(int id) async {
    await ApiClient.delete('productions/$id');
  }
}

