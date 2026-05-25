import 'package:flutter/foundation.dart';
import '../data/models/product_model.dart';
import '../data/models/pagination_model.dart';
import '../data/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final _repo = ProductRepository();

  List<ProductModel> products = [];
  List<String> categories = [];
  PaginationModel? pagination;
  bool loading = false;
  bool loadingMore = false;
  String? error;
  String? selectedCategory;
  String? searchQuery;

  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      products = [];
      pagination = null;
    }
    loading = products.isEmpty;
    error = null;
    notifyListeners();
    try {
      final result = await _repo.getProducts(
        category: selectedCategory,
        search: searchQuery,
        page: 1,
      );
      products = result['data'] as List<ProductModel>;
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
      final result = await _repo.getProducts(
        category: selectedCategory,
        search: searchQuery,
        page: pagination!.currentPage + 1,
      );
      products.addAll(result['data'] as List<ProductModel>);
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

  void setCategory(String? category) {
    selectedCategory = category;
    loadProducts(refresh: true);
  }

  void setSearch(String? query) {
    searchQuery = query?.isEmpty == true ? null : query;
    loadProducts(refresh: true);
  }

  Future<bool> createProduct(Map<String, dynamic> data) async {
    try {
      final product = await _repo.createProduct(data);
      products.insert(0, product);
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(int id, Map<String, dynamic> data) async {
    try {
      final updated = await _repo.updateProduct(id, data);
      final idx = products.indexWhere((p) => p.id == id);
      if (idx != -1) products[idx] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      await _repo.deleteProduct(id);
      products.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }
}

