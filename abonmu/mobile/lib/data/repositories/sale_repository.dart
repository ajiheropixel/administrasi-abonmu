import '../../core/network/api_client.dart';
import '../models/sale_model.dart';
import '../models/pagination_model.dart';

class SaleRepository {
  Future<Map<String, dynamic>> getSales({
    int? customerId,
    String? type,
    String? startDate,
    String? endDate,
    String? search,
    int page = 1,
    int perPage = 15,
  }) async {
    final response = await ApiClient.get('sales', params: {
      if (customerId != null) 'customer_id': customerId.toString(),
      if (type != null) 'type': type,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (search != null) 'search': search,
      'page': page.toString(),
      'per_page': perPage.toString(),
    });
    return {
      'data': (response['data'] as List<dynamic>)
          .map((e) => SaleModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      'pagination': PaginationModel.fromJson(
          response['pagination'] as Map<String, dynamic>),
    };
  }

  Future<SaleModel> getSale(int id) async {
    final response = await ApiClient.get('sales/$id');
    return SaleModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<SaleModel> getInvoice(int id) async {
    final response = await ApiClient.get('sales/$id/invoice');
    return SaleModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> getStatistics({
    String? startDate,
    String? endDate,
    String? type,
  }) async {
    final response = await ApiClient.get('sales/statistics', params: {
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (type != null) 'type': type,
    });
    return response['data'] as Map<String, dynamic>;
  }

  Future<SaleModel> createSale(Map<String, dynamic> data) async {
    final response = await ApiClient.post('sales', body: data);
    return SaleModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> deleteSale(int id) async {
    await ApiClient.delete('sales/$id');
  }
}



