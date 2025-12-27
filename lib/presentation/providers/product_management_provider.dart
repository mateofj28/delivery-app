import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/business.dart';
import '../../domain/repositories/product_repository.dart';
import '../../data/repositories/product_repository_impl.dart';

/// Provider del repositorio de productos
/// Sigue el principio de Inversión de Dependencias (DIP)
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl();
});

/// Estado para la gestión de productos
class ProductManagementState {
  final List<Product> products;
  final bool isLoading;
  final String? error;
  final Product? selectedProduct;
  final String? selectedBusinessId;
  final List<String> categories;

  const ProductManagementState({
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.selectedProduct,
    this.selectedBusinessId,
    this.categories = const [],
  });

  ProductManagementState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? error,
    Product? selectedProduct,
    String? selectedBusinessId,
    List<String>? categories,
  }) {
    return ProductManagementState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      selectedBusinessId: selectedBusinessId ?? this.selectedBusinessId,
      categories: categories ?? this.categories,
    );
  }
}

/// Notifier para la gestión de productos
/// Sigue el principio de Responsabilidad Única (SRP)
class ProductManagementNotifier extends StateNotifier<ProductManagementState> {
  final ProductRepository _repository;

  ProductManagementNotifier(this._repository) : super(const ProductManagementState());

  /// Cargar productos de un negocio específico
  Future<void> loadProductsByBusiness(String businessId) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      selectedBusinessId: businessId,
    );
    
    try {
      final products = await _repository.getProductsByBusiness(businessId);
      final categories = await _repository.getCategoriesByBusiness(businessId);
      
      state = state.copyWith(
        products: products,
        categories: categories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Cargar solo productos disponibles
  Future<void> loadAvailableProductsByBusiness(String businessId) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      selectedBusinessId: businessId,
    );
    
    try {
      final products = await _repository.getAvailableProductsByBusiness(businessId);
      final categories = await _repository.getCategoriesByBusiness(businessId);
      
      state = state.copyWith(
        products: products,
        categories: categories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Cargar productos por categoría
  Future<void> loadProductsByCategory(String businessId, String category) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final products = await _repository.getProductsByCategory(businessId, category);
      state = state.copyWith(
        products: products,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Crear un nuevo producto
  Future<String?> createProduct(String businessId, Product product) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final productId = await _repository.createProduct(businessId, product);
      await loadProductsByBusiness(businessId); // Recargar la lista
      return productId;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Actualizar un producto existente
  Future<bool> updateProduct(String businessId, Product product) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _repository.updateProduct(businessId, product);
      await loadProductsByBusiness(businessId); // Recargar la lista
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Eliminar un producto
  Future<bool> deleteProduct(String businessId, String productId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _repository.deleteProduct(businessId, productId);
      await loadProductsByBusiness(businessId); // Recargar la lista
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Cambiar disponibilidad de un producto
  Future<bool> toggleProductAvailability(String businessId, String productId, bool isAvailable) async {
    try {
      await _repository.toggleProductAvailability(businessId, productId, isAvailable);
      await loadProductsByBusiness(businessId); // Recargar la lista
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Seleccionar un producto
  void selectProduct(Product product) {
    state = state.copyWith(selectedProduct: product);
  }

  /// Limpiar la selección
  void clearSelection() {
    state = state.copyWith(selectedProduct: null);
  }

  /// Limpiar errores
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Limpiar estado
  void clearState() {
    state = const ProductManagementState();
  }
}

/// Provider del notifier de gestión de productos
final productManagementProvider = StateNotifierProvider<ProductManagementNotifier, ProductManagementState>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return ProductManagementNotifier(repository);
});

/// Provider para obtener productos de un negocio en tiempo real
final productsStreamProvider = StreamProvider.family<List<Product>, String>((ref, businessId) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.watchProductsByBusiness(businessId);
});

/// Provider para obtener productos disponibles en tiempo real
final availableProductsStreamProvider = StreamProvider.family<List<Product>, String>((ref, businessId) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.watchAvailableProductsByBusiness(businessId);
});

/// Provider para obtener un producto específico en tiempo real
final productStreamProvider = StreamProvider.family<Product?, ({String businessId, String productId})>((ref, params) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.watchProduct(params.businessId, params.productId);
});

/// Provider para obtener categorías de un negocio
final categoriesProvider = FutureProvider.family<List<String>, String>((ref, businessId) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getCategoriesByBusiness(businessId);
});