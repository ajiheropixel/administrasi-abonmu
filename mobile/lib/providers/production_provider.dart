import 'package:flutter/foundation.dart';
import '../data/models/production_model.dart';
import '../data/models/pagination_model.dart';
import '../data/repositories/production_repository.dart';

class ProductionProvider extends ChangeNotifier {
  final _repo = ProductionRepository();

  List<ProductionModel> productions = [];
  PaginationModel? pagination;
  Map<String, dynamic>? statistics;
  bool loading = false;
  bool loadingMore = false;
  String? error;
  String? selectedCategory;
  String? selectedType;
  String? startDate;
  String? endDate;

  Future<void> loadProductions({bool refresh = false}) async {
    if (refresh) {
      productions = [];
      pagination = null;
    }
    loading = productions.isEmpty;
    error = null;
    notifyListeners();
    try {
      final result = await _repo.getProductions(
        category: selectedCategory,
        type: selectedType,
        startDate: startDate,
        endDate: endDate,
        page: 1,
      );
      productions = result['data'] as List<ProductionModel>;
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
      final result = await _repo.getProductions(
        category: selectedCategory,
        type: selectedType,
        startDate: startDate,
        endDate: endDate,
        page: pagination!.currentPage + 1,
      );
      productions.addAll(result['data'] as List<ProductionModel>);
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

  void setFilters({String? category, String? type, String? start, String? end}) {
    selectedCategory = category;
    selectedType = type;
    startDate = start;
    endDate = end;
    loadProductions(refresh: true);
  }

  Future<bool> createProduction(Map<String, dynamic> data) async {
    try {
      final prod = await _repo.createProduction(data);
      productions.insert(0, prod);
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduction(int id, Map<String, dynamic> data) async {
    try {
      final updated = await _repo.updateProduction(id, data);
      final idx = productions.indexWhere((p) => p.id == id);
      if (idx != -1) productions[idx] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduction(int id) async {
    try {
      await _repo.deleteProduction(id);
      productions.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }
}

