import '../../core/network/api_client.dart';
import '../models/customer_model.dart';
import '../models/pagination_model.dart';

class CustomerRepository {
  Future<Map<String, dynamic>> getCustomers({
    String? search,
    int page = 1,
    int perPage = 15,
  }) async {
    final response = await ApiClient.get('customers', params: {
      if (search != null) 'search': search,
      'page': page.toString(),
      'per_page': perPage.toString(),
    });
    return {
      'data': (response['data'] as List<dynamic>)
          .map((e) => CustomerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      'pagination': PaginationModel.fromJson(
          response['pagination'] as Map<String, dynamic>),
    };
  }

  Future<CustomerModel> getCustomer(int id) async {
    final response = await ApiClient.get('customers/$id');
    return CustomerModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<CustomerModel> createCustomer(Map<String, dynamic> data) async {
    final response = await ApiClient.post('customers', body: data);
    return CustomerModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<CustomerModel> updateCustomer(int id, Map<String, dynamic> data) async {
    final response = await ApiClient.put('customers/$id', body: data);
    return CustomerModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> deleteCustomer(int id) async {
    await ApiClient.delete('customers/$id');
  }
}

