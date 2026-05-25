import 'package:flutter/foundation.dart';
import '../data/models/customer_model.dart';
import '../data/models/pagination_model.dart';
import '../data/repositories/customer_repository.dart';

class CustomerProvider extends ChangeNotifier {
  final _repo = CustomerRepository();

  List<CustomerModel> customers = [];
  PaginationModel? pagination;
  bool loading = false;
  bool loadingMore = false;
  String? error;
  String? searchQuery;

  Future<void> loadCustomers({bool refresh = false}) async {
    if (refresh) {
      customers = [];
      pagination = null;
    }
    loading = customers.isEmpty;
    error = null;
    notifyListeners();
    try {
      final result = await _repo.getCustomers(
        search: searchQuery,
        page: 1,
      );
      customers = result['data'] as List<CustomerModel>;
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
      final result = await _repo.getCustomers(
        search: searchQuery,
        page: pagination!.currentPage + 1,
      );
      customers.addAll(result['data'] as List<CustomerModel>);
      pagination = result['pagination'] as PaginationModel;
    } catch (_) {}
    loadingMore = false;
    notifyListeners();
  }

  void setSearch(String? query) {
    searchQuery = query?.isEmpty == true ? null : query;
    loadCustomers(refresh: true);
  }

  Future<bool> createCustomer(Map<String, dynamic> data) async {
    try {
      final customer = await _repo.createCustomer(data);
      customers.insert(0, customer);
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCustomer(int id, Map<String, dynamic> data) async {
    try {
      final updated = await _repo.updateCustomer(id, data);
      final idx = customers.indexWhere((c) => c.id == id);
      if (idx != -1) customers[idx] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCustomer(int id) async {
    try {
      await _repo.deleteCustomer(id);
      customers.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }
}

