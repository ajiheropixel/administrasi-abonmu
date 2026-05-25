import 'package:flutter/foundation.dart';
import '../data/models/employee_model.dart';
import '../data/models/pagination_model.dart';
import '../data/repositories/employee_repository.dart';

class EmployeeProvider extends ChangeNotifier {
  final _repo = EmployeeRepository();

  List<EmployeeModel> employees = [];
  PaginationModel? pagination;
  bool loading = false;
  bool loadingMore = false;
  String? error;
  String? searchQuery;

  Future<void> loadEmployees({bool refresh = false}) async {
    if (refresh) {
      employees = [];
      pagination = null;
    }
    loading = employees.isEmpty;
    error = null;
    notifyListeners();
    try {
      final result = await _repo.getEmployees(search: searchQuery, page: 1);
      employees = result['data'] as List<EmployeeModel>;
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
      final result = await _repo.getEmployees(
        search: searchQuery,
        page: pagination!.currentPage + 1,
      );
      employees.addAll(result['data'] as List<EmployeeModel>);
      pagination = result['pagination'] as PaginationModel;
    } catch (_) {}
    loadingMore = false;
    notifyListeners();
  }

  void setSearch(String? query) {
    searchQuery = query?.isEmpty == true ? null : query;
    loadEmployees(refresh: true);
  }

  Future<bool> createEmployee(Map<String, dynamic> data) async {
    try {
      final emp = await _repo.createEmployee(data);
      employees.insert(0, emp);
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEmployee(int id, Map<String, dynamic> data) async {
    try {
      final updated = await _repo.updateEmployee(id, data);
      final idx = employees.indexWhere((e) => e.id == id);
      if (idx != -1) employees[idx] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEmployee(int id) async {
    try {
      await _repo.deleteEmployee(id);
      employees.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }
}

