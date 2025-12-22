import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../providers/cart_provider.dart';

class CartFloatingButton extends ConsumerWidget {
  const CartFloatingButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    if (cart.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        onPressed: () => context.go('/cart'),
        icon: const Icon(Icons.shopping_cart),
        label: Text(
          'Ver carrito (${cartNotifier.totalItems})',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
