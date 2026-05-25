import '../../core/network/api_client.dart';
import '../models/employee_model.dart';
import '../models/pagination_model.dart';

class EmployeeRepository {
  Future<Map<String, dynamic>> getEmployees({
    String? search,
    String? position,
    int page = 1,
    int perPage = 15,
  }) async {
    final response = await ApiClient.get('employees', params: {
      if (search != null) 'search': search,
      if (position != null) 'position': position,
      'page': page.toString(),
      'per_page': perPage.toString(),
    });
    return {
      'data': (response['data'] as List<dynamic>)
          .map((e) => EmployeeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      'pagination': PaginationModel.fromJson(
          response['pagination'] as Map<String, dynamic>),
    };
  }

  Future<EmployeeModel> getEmployee(int id) async {
    final response = await ApiClient.get('employees/$id');
    return EmployeeModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<EmployeeModel> createEmployee(Map<String, dynamic> data) async {
    final response = await ApiClient.post('employees', body: data);
    return EmployeeModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<EmployeeModel> updateEmployee(int id, Map<String, dynamic> data) async {
    final response = await ApiClient.put('employees/$id', body: data);
    return EmployeeModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> deleteEmployee(int id) async {
    await ApiClient.delete('employees/$id');
  }
}

