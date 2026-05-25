import '../../core/network/api_client.dart';
import '../models/dashboard_model.dart';
import '../models/product_model.dart';

class DashboardRepository {
  Future<Map<String, dynamic>> getStats({int? month, int? year}) async {
    final response = await ApiClient.get('dashboard/stats', params: {
      if (month != null) 'month': month.toString(),
      if (year != null) 'year': year.toString(),
    });
    final data = response['data'] as Map<String, dynamic>;
    return {
      'summary': DashboardSummary.fromJson(
          data['summary'] as Map<String, dynamic>),
      'top_products': (data['top_products'] as List<dynamic>)
          .map((e) => TopProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
      'low_stock_products': (data['low_stock_products'] as List<dynamic>)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      'sales_chart': (data['charts']['sales'] as List<dynamic>)
          .map((e) => ChartPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      'production_chart': (data['charts']['production'] as List<dynamic>)
          .map((e) => ChartPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      'recent_sales': data['recent_sales'] as List<dynamic>,
      'recent_productions': data['recent_productions'] as List<dynamic>,
    };
  }

  Future<List<MonthlyComparison>> getMonthlyComparison({int months = 6}) async {
    final response = await ApiClient.get('dashboard/monthly-comparison',
        params: {'months': months.toString()});
    return (response['data'] as List<dynamic>)
        .map((e) => MonthlyComparison.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

