import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/business.dart';
import '../../domain/repositories/product_repository.dart';

/// Implementación concreta del repositorio de productos con Firestore
/// Sigue el principio de Inversión de Dependencias (DIP)
class ProductRepositoryImpl implements ProductRepository {
  final FirebaseFirestore _firestore;
  static const String _businessCollection = 'businesses';

  ProductRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<String> createProduct(String businessId, Product product) async {
    try {
      final businessRef = _firestore.collection(_businessCollection).doc(businessId);
      final businessDoc = await businessRef.get();
      
      if (!businessDoc.exists) {
        throw Exception('Business not found');
      }
      
      final business = Business.fromJson(businessDoc.data()!);
      final productId = _firestore.collection('temp').doc().id; // Generate unique ID
      
      final newProduct = product.copyWith(
        id: productId,
        updatedAt: DateTime.now(),
      );
      
      final updatedProducts = [...business.products, newProduct];
      final updatedBusiness = business.copyWith(
        products: updatedProducts,
        updatedAt: DateTime.now(),
      );
      
      await businessRef.update(updatedBusiness.toJson());
      return productId;
    } catch (e) {
      throw _handleFirestoreException(e, 'Error creating product');
    }
  }

  @override
  Future<Product?> getProductById(String businessId, String productId) async {
    try {
      final business = await _getBusinessById(businessId);
      if (business == null) return null;
      
      return business.products.firstWhere(
        (product) => product.id == productId,
        orElse: () => throw StateError('Product not found'),
      );
    } on StateError {
      return null;
    } catch (e) {
      throw _handleFirestoreException(e, 'Error getting product');
    }
  }

  @override
  Future<List<Product>> getProductsByBusiness(String businessId) async {
    try {
      final business = await _getBusinessById(businessId);
      return business?.products ?? [];
    } catch (e) {
      throw _handleFirestoreException(e, 'Error getting products by business');
    }
  }

  @override
  Future<List<Product>> getAvailableProductsByBusiness(String businessId) async {
    try {
      final products = await getProductsByBusiness(businessId);
      return products.where((product) => product.isAvailable).toList();
    } catch (e) {
      throw _handleFirestoreException(e, 'Error getting available products');
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(String businessId, String category) async {
    try {
      final products = await getProductsByBusiness(businessId);
      return products.where((product) => product.category == category).toList();
    } catch (e) {
      throw _handleFirestoreException(e, 'Error getting products by category');
    }
  }

  @override
  Future<void> updateProduct(String businessId, Product product) async {
    try {
      final businessRef = _firestore.collection(_businessCollection).doc(businessId);
      final businessDoc = await businessRef.get();
      
      if (!businessDoc.exists) {
        throw Exception('Business not found');
      }
      
      final business = Business.fromJson(businessDoc.data()!);
      final updatedProduct = product.copyWith(updatedAt: DateTime.now());
      
      final updatedProducts = business.products.map((p) {
        return p.id == product.id ? updatedProduct : p;
      }).toList();
      
      final updatedBusiness = business.copyWith(
        products: updatedProducts,
        updatedAt: DateTime.now(),
      );
      
      await businessRef.update(updatedBusiness.toJson());
    } catch (e) {
      throw _handleFirestoreException(e, 'Error updating product');
    }
  }

  @override
  Future<void> deleteProduct(String businessId, String productId) async {
    try {
      final businessRef = _firestore.collection(_businessCollection).doc(businessId);
      final businessDoc = await businessRef.get();
      
      if (!businessDoc.exists) {
        throw Exception('Business not found');
      }
      
      final business = Business.fromJson(businessDoc.data()!);
      final updatedProducts = business.products
          .where((product) => product.id != productId)
          .toList();
      
      final updatedBusiness = business.copyWith(
        products: updatedProducts,
        updatedAt: DateTime.now(),
      );
      
      await businessRef.update(updatedBusiness.toJson());
    } catch (e) {
      throw _handleFirestoreException(e, 'Error deleting product');
    }
  }

  @override
  Future<void> toggleProductAvailability(String businessId, String productId, bool isAvailable) async {
    try {
      final businessRef = _firestore.collection(_businessCollection).doc(businessId);
      final businessDoc = await businessRef.get();
      
      if (!businessDoc.exists) {
        throw Exception('Business not found');
      }
      
      final business = Business.fromJson(businessDoc.data()!);
      final updatedProducts = business.products.map((product) {
        if (product.id == productId) {
          return product.copyWith(
            isAvailable: isAvailable,
            updatedAt: DateTime.now(),
          );
        }
        return product;
      }).toList();
      
      final updatedBusiness = business.copyWith(
        products: updatedProducts,
        updatedAt: DateTime.now(),
      );
      
      await businessRef.update(updatedBusiness.toJson());
    } catch (e) {
      throw _handleFirestoreException(e, 'Error toggling product availability');
    }
  }

  @override
  Future<List<String>> getCategoriesByBusiness(String businessId) async {
    try {
      final products = await getProductsByBusiness(businessId);
      final categories = products
          .where((product) => product.category != null)
          .map((product) => product.category!)
          .toSet()
          .toList();
      
      categories.sort();
      return categories;
    } catch (e) {
      throw _handleFirestoreException(e, 'Error getting categories');
    }
  }

  @override
  Stream<List<Product>> watchProductsByBusiness(String businessId) {
    try {
      return _firestore
          .collection(_businessCollection)
          .doc(businessId)
          .snapshots()
          .map((doc) {
        if (!doc.exists || doc.data() == null) {
          return <Product>[];
        }
        final business = Business.fromJson(doc.data()!);
        return business.products;
      });
    } catch (e) {
      throw _handleFirestoreException(e, 'Error watching products');
    }
  }

  @override
  Stream<List<Product>> watchAvailableProductsByBusiness(String businessId) {
    try {
      return watchProductsByBusiness(businessId)
          .map((products) => products.where((product) => product.isAvailable).toList());
    } catch (e) {
      throw _handleFirestoreException(e, 'Error watching available products');
    }
  }

  @override
  Stream<Product?> watchProduct(String businessId, String productId) {
    try {
      return watchProductsByBusiness(businessId).map((products) {
        try {
          return products.firstWhere((product) => product.id == productId);
        } on StateError {
          return null;
        }
      });
    } catch (e) {
      throw _handleFirestoreException(e, 'Error watching product');
    }
  }

  /// Helper method para obtener un negocio por ID
  Future<Business?> _getBusinessById(String businessId) async {
    final doc = await _firestore.collection(_businessCollection).doc(businessId).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return Business.fromJson(doc.data()!);
  }

  /// Manejo centralizado de excepciones de Firestore
  Exception _handleFirestoreException(dynamic error, String message) {
    if (error is FirebaseException) {
      return Exception('$message: ${error.message}');
    }
    return Exception('$message: $error');
  }
}