import 'package:flutter/foundation.dart';
import '../data/models/sale_model.dart';
import '../data/models/pagination_model.dart';
import '../data/repositories/sale_repository.dart';

class SaleProvider extends ChangeNotifier {
  final _repo = SaleRepository();

  List<SaleModel> sales = [];
  PaginationModel? pagination;
  Map<String, dynamic>? statistics;
  bool loading = false;
  bool loadingMore = false;
  String? error;
  String? selectedType;
  String? startDate;
  String? endDate;
  String? searchQuery;

  Future<void> loadSales({bool refresh = false}) async {
    if (refresh) {
      sales = [];
      pagination = null;
    }
    loading = sales.isEmpty;
    error = null;
    notifyListeners();
    try {
      final result = await _repo.getSales(
        type: selectedType,
        startDate: startDate,
        endDate: endDate,
        search: searchQuery,
        page: 1,
      );
      sales = result['data'] as List<SaleModel>;
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
      final result = await _repo.getSales(
        type: selectedType,
        startDate: startDate,
        endDate: endDate,
        search: searchQuery,
        page: pagination!.currentPage + 1,
      );
      sales.addAll(result['data'] as List<SaleModel>);
      pagination = result['pagination'] as PaginationModel;
    } catch (_) {}
    loadingMore = false;
    notifyListeners();
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

  void setFilters({String? type, String? start, String? end, String? search}) {
    selectedType = type;
    startDate = start;
    endDate = end;
    searchQuery = search?.isEmpty == true ? null : search;
    loadSales(refresh: true);
  }

  Future<bool> createSale(Map<String, dynamic> data) async {
    try {
      final sale = await _repo.createSale(data);
      sales.insert(0, sale);
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSale(int id) async {
    try {
      await _repo.deleteSale(id);
      sales.removeWhere((s) => s.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }
}

