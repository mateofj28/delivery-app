import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/business_repository_impl.dart';
import '../../domain/entities/business.dart';
import '../../domain/repositories/business_repository.dart';

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  return BusinessRepositoryImpl();
});

final businessListProvider = FutureProvider<List<Business>>((ref) async {
  final repository = ref.read(businessRepositoryProvider);
  return repository.getBusinesses();
});

final selectedBusinessProvider = StateProvider<Business?>((ref) => null);

// Provider para gestión de negocios en admin
class BusinessManagementNotifier extends StateNotifier<List<Business>> {
  BusinessManagementNotifier() : super([]);

  void loadBusinesses(List<Business> businesses) {
    state = businesses;
  }

  void addBusiness(Business business) {
    state = [...state, business];
  }

  void updateBusiness(Business updatedBusiness) {
    state = state.map((business) {
      return business.id == updatedBusiness.id ? updatedBusiness : business;
    }).toList();
  }

  void deleteBusiness(String businessId) {
    state = state.where((business) => business.id != businessId).toList();
  }

  void addProductToBusiness(String businessId, Product product) {
    state = state.map((business) {
      if (business.id == businessId) {
        return business.copyWith(
          products: [...business.products, product],
        );
      }
      return business;
    }).toList();
  }

  void updateProductInBusiness(String businessId, Product updatedProduct) {
    state = state.map((business) {
      if (business.id == businessId) {
        final updatedProducts = business.products.map((product) {
          return product.id == updatedProduct.id ? updatedProduct : product;
        }).toList();
        return business.copyWith(products: updatedProducts);
      }
      return business;
    }).toList();
  }

  void deleteProductFromBusiness(String businessId, String productId) {
    state = state.map((business) {
      if (business.id == businessId) {
        final updatedProducts = business.products
            .where((product) => product.id != productId)
            .toList();
        return business.copyWith(products: updatedProducts);
      }
      return business;
    }).toList();
  }
}

final businessManagementProvider =
    StateNotifierProvider<BusinessManagementNotifier, List<Business>>((ref) {
  return BusinessManagementNotifier();
});
