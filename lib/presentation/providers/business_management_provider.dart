import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/business.dart';
import '../../domain/repositories/business_repository.dart';
import '../../data/repositories/business_repository_impl.dart';

/// Provider del repositorio de negocios
/// Sigue el principio de Inversión de Dependencias (DIP)
final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  return BusinessRepositoryImpl();
});

/// Estado para la gestión de negocios
class BusinessManagementState {
  final List<Business> businesses;
  final bool isLoading;
  final String? error;
  final Business? selectedBusiness;

  const BusinessManagementState({
    this.businesses = const [],
    this.isLoading = false,
    this.error,
    this.selectedBusiness,
  });

  BusinessManagementState copyWith({
    List<Business>? businesses,
    bool? isLoading,
    String? error,
    Business? selectedBusiness,
  }) {
    return BusinessManagementState(
      businesses: businesses ?? this.businesses,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedBusiness: selectedBusiness ?? this.selectedBusiness,
    );
  }
}

/// Notifier para la gestión de negocios
/// Sigue el principio de Responsabilidad Única (SRP)
class BusinessManagementNotifier extends StateNotifier<BusinessManagementState> {
  final BusinessRepository _repository;

  BusinessManagementNotifier(this._repository) : super(const BusinessManagementState()) {
    loadBusinesses();
  }

  /// Cargar todos los negocios
  Future<void> loadBusinesses() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final businesses = await _repository.getAllBusinesses();
      state = state.copyWith(
        businesses: businesses,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Cargar solo negocios activos
  Future<void> loadActiveBusinesses() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final businesses = await _repository.getActiveBusinesses();
      state = state.copyWith(
        businesses: businesses,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Crear un nuevo negocio
  Future<String?> createBusiness(Business business) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final businessId = await _repository.createBusiness(business);
      await loadBusinesses(); // Recargar la lista
      return businessId;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Actualizar un negocio existente
  Future<bool> updateBusiness(Business business) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _repository.updateBusiness(business);
      await loadBusinesses(); // Recargar la lista
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Eliminar un negocio
  Future<bool> deleteBusiness(String businessId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _repository.deleteBusiness(businessId);
      await loadBusinesses(); // Recargar la lista
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Cambiar el estado activo/inactivo de un negocio
  Future<bool> toggleBusinessStatus(String businessId, bool isActive) async {
    try {
      await _repository.toggleBusinessStatus(businessId, isActive);
      await loadBusinesses(); // Recargar la lista
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Seleccionar un negocio
  void selectBusiness(Business business) {
    state = state.copyWith(selectedBusiness: business);
  }

  /// Limpiar la selección
  void clearSelection() {
    state = state.copyWith(selectedBusiness: null);
  }

  /// Limpiar errores
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider del notifier de gestión de negocios
final businessManagementProvider = StateNotifierProvider<BusinessManagementNotifier, BusinessManagementState>((ref) {
  final repository = ref.watch(businessRepositoryProvider);
  return BusinessManagementNotifier(repository);
});

/// Provider para obtener negocios activos en tiempo real
final activeBusinessesStreamProvider = StreamProvider<List<Business>>((ref) {
  final repository = ref.watch(businessRepositoryProvider);
  return repository.watchActiveBusinesses();
});

/// Provider para obtener todos los negocios en tiempo real
final allBusinessesStreamProvider = StreamProvider<List<Business>>((ref) {
  final repository = ref.watch(businessRepositoryProvider);
  return repository.watchAllBusinesses();
});

/// Provider para obtener un negocio específico en tiempo real
final businessStreamProvider = StreamProvider.family<Business?, String>((ref, businessId) {
  final repository = ref.watch(businessRepositoryProvider);
  return repository.watchBusiness(businessId);
});