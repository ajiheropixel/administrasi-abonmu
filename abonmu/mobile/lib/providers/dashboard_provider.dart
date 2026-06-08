import 'package:flutter/foundation.dart';
import '../data/models/dashboard_model.dart';
import '../data/models/product_model.dart';
import '../data/repositories/dashboard_repository.dart';

class DashboardProvider extends ChangeNotifier {
  final _repo = DashboardRepository();

  DashboardSummary? summary;
  List<TopProduct> topProducts = [];
  List<ProductModel> lowStockProducts = [];
  List<ChartPoint> salesChart = [];
  List<ChartPoint> productionChart = [];
  List<MonthlyComparison> monthlyComparison = [];

  bool loading = false;
  String? error;

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  Future<void> loadStats() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final result = await _repo.getStats(
        month: selectedMonth,
        year: selectedYear,
      );
      summary = result['summary'] as DashboardSummary;
      topProducts = result['top_products'] as List<TopProduct>;
      lowStockProducts = result['low_stock_products'] as List<ProductModel>;
      salesChart = result['sales_chart'] as List<ChartPoint>;
      productionChart = result['production_chart'] as List<ChartPoint>;
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  Future<void> loadMonthlyComparison() async {
    try {
      monthlyComparison = await _repo.getMonthlyComparison();
      notifyListeners();
    } catch (_) {}
  }

  void setMonth(int month, int year) {
    selectedMonth = month;
    selectedYear = year;
    loadStats();
  }
}



