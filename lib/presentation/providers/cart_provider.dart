import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/business.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addProduct(Product product) {
    final existingIndex = state.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      final updatedItem = state[existingIndex].copyWith(
        quantity: state[existingIndex].quantity + 1,
      );
      state = [
        ...state.sublist(0, existingIndex),
        updatedItem,
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      state = [...state, CartItem(product: product, quantity: 1)];
    }
  }

  void removeProduct(String productId) {
    final existingIndex = state.indexWhere(
      (item) => item.product.id == productId,
    );

    if (existingIndex >= 0) {
      final currentItem = state[existingIndex];
      if (currentItem.quantity > 1) {
        final updatedItem = currentItem.copyWith(
          quantity: currentItem.quantity - 1,
        );
        state = [
          ...state.sublist(0, existingIndex),
          updatedItem,
          ...state.sublist(existingIndex + 1),
        ];
      } else {
        state = [
          ...state.sublist(0, existingIndex),
          ...state.sublist(existingIndex + 1),
        ];
      }
    }
  }

  void clearCart() {
    state = [];
  }

  double get totalAmount {
    return state.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get totalItems {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});
