import '../../core/network/api_client.dart';
import '../models/product_model.dart';
import '../models/pagination_model.dart';

class ProductRepository {
  Future<Map<String, dynamic>> getProducts({
    String? category,
    String? search,
    int page = 1,
    int perPage = 15,
  }) async {
    final response = await ApiClient.get('products', params: {
      if (category != null) 'category': category,
      if (search != null) 'search': search,
      'page': page.toString(),
      'per_page': perPage.toString(),
    });
    return {
      'data': (response['data'] as List<dynamic>)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      'pagination': PaginationModel.fromJson(
          response['pagination'] as Map<String, dynamic>),
    };
  }

  Future<ProductModel> getProduct(int id) async {
    final response = await ApiClient.get('products/$id');
    return ProductModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<List<String>> getCategories() async {
    final response = await ApiClient.get('products/categories');
    return (response['data'] as List<dynamic>).cast<String>();
  }

  Future<ProductModel> createProduct(
    Map<String, dynamic> data, {
    String? imagePath,
  }) async {
    final fields = {
      'name': data['name'].toString(),
      'category': data['category'].toString(),
      'description': data['description']?.toString() ?? '',
      'price': data['price'].toString(),
      'unit': data['unit'].toString(),
    };
    final response = await ApiClient.multipart(
      'POST',
      'products',
      fields: fields,
      filePath: imagePath,
    );
    return ProductModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<ProductModel> updateProduct(
    int id,
    Map<String, dynamic> data, {
    String? imagePath,
  }) async {
    final fields = {
      'name': data['name'].toString(),
      'category': data['category'].toString(),
      'description': data['description']?.toString() ?? '',
      'price': data['price'].toString(),
      'unit': data['unit'].toString(),
      '_method': 'PUT', // Laravel method spoofing untuk multipart
    };
    final response = await ApiClient.multipart(
      'POST',
      'products/$id',
      fields: fields,
      filePath: imagePath,
    );
    return ProductModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> deleteProduct(int id) async {
    await ApiClient.delete('products/$id');
  }
}
