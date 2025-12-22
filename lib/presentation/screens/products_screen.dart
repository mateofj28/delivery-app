import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/price_formatter.dart';
import '../../domain/entities/business.dart';
import '../providers/business_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_floating_button.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedBusiness = ref.watch(selectedBusinessProvider);

    if (selectedBusiness == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No hay negocio seleccionado'),
              ElevatedButton(
                onPressed: () => context.go('/businesses'),
                child: const Text('Seleccionar negocio'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(selectedBusiness.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/businesses'),
        ),
      ),
      body: _ProductsList(business: selectedBusiness),
      floatingActionButton: const CartFloatingButton(),
    );
  }
}

class _ProductsList extends ConsumerWidget {
  final Business business;

  const _ProductsList({required this.business});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: business.products.length,
      itemBuilder: (context, index) {
        final product = business.products[index];
        return _ProductCard(product: product);
      },
    );
  }
}

class _ProductCard extends ConsumerWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartItem =
        cart.where((item) => item.product.id == product.id).firstOrNull;
    final quantity = cartItem?.quantity ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        PriceFormatter.format(product.price),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (quantity > 0) ...[
                  _QuantityButton(
                    icon: Icons.remove,
                    onPressed: () => ref
                        .read(cartProvider.notifier)
                        .removeProduct(product.id),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    quantity.toString(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(width: 16),
                ],
                _QuantityButton(
                  icon: quantity > 0 ? Icons.add : Icons.add_shopping_cart,
                  onPressed: () =>
                      ref.read(cartProvider.notifier).addProduct(product),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QuantityButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Icon(icon, color: AppColors.onAccent, size: 20),
        ),
      ),
    );
  }
}
