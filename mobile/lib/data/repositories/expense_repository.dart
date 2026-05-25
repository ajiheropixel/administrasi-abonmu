import '../../core/network/api_client.dart';
import '../models/expense_model.dart';
import '../models/pagination_model.dart';

class ExpenseRepository {
  Future<Map<String, dynamic>> getExpenses({
    String? category,
    int? productionId,
    String? startDate,
    String? endDate,
    int page = 1,
    int perPage = 15,
  }) async {
    final response = await ApiClient.get('expenses', params: {
      if (category != null) 'category': category,
      if (productionId != null) 'production_id': productionId.toString(),
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      'page': page.toString(),
      'per_page': perPage.toString(),
    });
    return {
      'data': (response['data'] as List<dynamic>)
          .map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      'pagination': PaginationModel.fromJson(
          response['pagination'] as Map<String, dynamic>),
    };
  }

  Future<ExpenseModel> getExpense(int id) async {
    final response = await ApiClient.get('expenses/$id');
    return ExpenseModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<List<String>> getCategories() async {
    final response = await ApiClient.get('expenses/categories');
    return (response['data'] as List<dynamic>).cast<String>();
  }

  Future<Map<String, dynamic>> getStatistics({
    String? startDate,
    String? endDate,
    String? category,
  }) async {
    final response = await ApiClient.get('expenses/statistics', params: {
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (category != null) 'category': category,
    });
    return response['data'] as Map<String, dynamic>;
  }

  Future<ExpenseModel> createExpense(Map<String, dynamic> data) async {
    final response = await ApiClient.post('expenses', body: data);
    return ExpenseModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<ExpenseModel> updateExpense(int id, Map<String, dynamic> data) async {
    final response = await ApiClient.put('expenses/$id', body: data);
    return ExpenseModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> deleteExpense(int id) async {
    await ApiClient.delete('expenses/$id');
  }
}

