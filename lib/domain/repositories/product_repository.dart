import '../entities/business.dart';

/// Repository interface para operaciones de productos
/// Sigue el principio de Segregación de Interfaces (ISP)
abstract class ProductRepository {
  // CRUD de Productos
  Future<String> createProduct(String businessId, Product product);
  Future<Product?> getProductById(String businessId, String productId);
  Future<List<Product>> getProductsByBusiness(String businessId);
  Future<List<Product>> getAvailableProductsByBusiness(String businessId);
  Future<List<Product>> getProductsByCategory(String businessId, String category);
  Future<void> updateProduct(String businessId, Product product);
  Future<void> deleteProduct(String businessId, String productId);
  Future<void> toggleProductAvailability(String businessId, String productId, bool isAvailable);
  
  // Operaciones de categorías
  Future<List<String>> getCategoriesByBusiness(String businessId);
  
  // Stream para actualizaciones en tiempo real
  Stream<List<Product>> watchProductsByBusiness(String businessId);
  Stream<List<Product>> watchAvailableProductsByBusiness(String businessId);
  Stream<Product?> watchProduct(String businessId, String productId);
}