import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/price_formatter.dart';
import '../../domain/entities/business.dart';
import '../providers/business_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_management_provider.dart';
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
              const Icon(
                Icons.store_outlined,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              const Text('No hay negocio seleccionado'),
              const SizedBox(height: 16),
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
    // Usar el stream provider para obtener productos disponibles en tiempo real
    final productsAsync = ref.watch(
      availableProductsStreamProvider(business.id),
    );

    return productsAsync.when(
      data: (products) {
        if (products.isEmpty) {
          return _EmptyProductsState();
        }

        // Agrupar productos por categoría
        final productsByCategory = <String, List<Product>>{};
        final uncategorizedProducts = <Product>[];

        for (final product in products) {
          if (product.category != null && product.category!.isNotEmpty) {
            productsByCategory.putIfAbsent(product.category!, () => []);
            productsByCategory[product.category!]!.add(product);
          } else {
            uncategorizedProducts.add(product);
          }
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.refresh(availableProductsStreamProvider(business.id));
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Información del negocio
              if (business.description != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    business.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Productos por categoría
              ...productsByCategory.entries.map((entry) {
                return _CategorySection(
                  categoryName: entry.key,
                  products: entry.value,
                );
              }),

              // Productos sin categoría
              if (uncategorizedProducts.isNotEmpty) ...[
                if (productsByCategory.isNotEmpty)
                  _CategorySection(
                    categoryName: 'Otros productos',
                    products: uncategorizedProducts,
                  )
                else
                  ...uncategorizedProducts.map(
                    (product) => _ProductCard(product: product),
                  ),
              ],
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _ErrorState(
        error: error.toString(),
        onRetry: () =>
            ref.refresh(availableProductsStreamProvider(business.id)),
      ),
    );
  }
}

class _EmptyProductsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.restaurant_menu_outlined,
                size: 60,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No hay productos disponibles',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Este negocio aún no tiene productos en su menú.\nVuelve más tarde para ver las opciones disponibles.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 280),
              child: ElevatedButton.icon(
                onPressed: () => context.go('/businesses'),
                icon: const Icon(Icons.arrow_back_outlined),
                label: const Text('Ver otros negocios'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.home_outlined, size: 20),
              label: const Text('Ir al inicio'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Error al cargar productos',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Ocurrió un problema al cargar los productos.\nVerifica tu conexión a internet.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (error.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  error,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red.shade700,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 280),
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => context.go('/businesses'),
              icon: const Icon(Icons.arrow_back_outlined, size: 20),
              label: const Text('Ver otros negocios'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String categoryName;
  final List<Product> products;

  const _CategorySection({required this.categoryName, required this.products});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            categoryName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        ...products.map((product) => _ProductCard(product: product)),
      ],
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (product.category != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                product.category!,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ],
                        ],
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
                if (product.imageUrl != null) ...[
                  const SizedBox(width: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.imageUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.restaurant_menu,
                            color: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ),
                ],
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
