import 'package:flutter/foundation.dart';
import '../data/models/expense_model.dart';
import '../data/models/pagination_model.dart';
import '../data/repositories/expense_repository.dart';

class ExpenseProvider extends ChangeNotifier {
  final _repo = ExpenseRepository();

  List<ExpenseModel> expenses = [];
  List<String> categories = [];
  PaginationModel? pagination;
  Map<String, dynamic>? statistics;
  bool loading = false;
  bool loadingMore = false;
  String? error;
  String? selectedCategory;
  String? startDate;
  String? endDate;

  Future<void> loadExpenses({bool refresh = false}) async {
    if (refresh) {
      expenses = [];
      pagination = null;
    }
    loading = expenses.isEmpty;
    error = null;
    notifyListeners();
    try {
      final result = await _repo.getExpenses(
        category: selectedCategory,
        startDate: startDate,
        endDate: endDate,
        page: 1,
      );
      expenses = result['data'] as List<ExpenseModel>;
      pagination = result['pagination'] as PaginationModel;
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (pagination == null || !pagination!.hasNextPage || loadingMore) return;
    loadingMore = true;
    notifyListeners();
    try {
      final result = await _repo.getExpenses(
        category: selectedCategory,
        startDate: startDate,
        endDate: endDate,
        page: pagination!.currentPage + 1,
      );
      expenses.addAll(result['data'] as List<ExpenseModel>);
      pagination = result['pagination'] as PaginationModel;
    } catch (_) {}
    loadingMore = false;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    try {
      categories = await _repo.getCategories();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadStatistics() async {
    try {
      statistics = await _repo.getStatistics(
        startDate: startDate,
        endDate: endDate,
      );
      notifyListeners();
    } catch (_) {}
  }

  void setFilters({String? category, String? start, String? end}) {
    selectedCategory = category;
    startDate = start;
    endDate = end;
    loadExpenses(refresh: true);
  }

  Future<bool> createExpense(Map<String, dynamic> data) async {
    try {
      final expense = await _repo.createExpense(data);
      expenses.insert(0, expense);
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateExpense(int id, Map<String, dynamic> data) async {
    try {
      final updated = await _repo.updateExpense(id, data);
      final idx = expenses.indexWhere((e) => e.id == id);
      if (idx != -1) expenses[idx] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteExpense(int id) async {
    try {
      await _repo.deleteExpense(id);
      expenses.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }
}



