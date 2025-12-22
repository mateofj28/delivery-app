import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/price_formatter.dart';
import '../../core/utils/whatsapp_launcher.dart';
import '../../domain/entities/order.dart';
import '../providers/cart_provider.dart';

class ConfirmationScreen extends ConsumerWidget {
  final Order order;

  const ConfirmationScreen({super.key, required this.order});

  Future<void> _sendToWhatsApp(BuildContext context, WidgetRef ref) async {
    final success = await WhatsAppLauncher.sendOrder(order);

    if (success) {
      // Limpiar el carrito
      ref.read(cartProvider.notifier).clearCart();

      if (context.mounted) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Abriendo WhatsApp...'),
            backgroundColor: Colors.green,
          ),
        );

        // Volver al inicio después de un breve delay
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) {
            context.go('/');
          }
        });
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Error al abrir WhatsApp. Verifica que esté instalado.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Confirmar pedido'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/order-form'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ícono de confirmación
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: Colors.green,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: Text(
                      '¡Todo listo!',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Center(
                    child: Text(
                      'Revisa tu pedido antes de enviarlo',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Detalles del pedido
                  _OrderDetails(order: order),
                ],
              ),
            ),
          ),

          // Botón de enviar
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => _sendToWhatsApp(context, ref),
                      icon: const Icon(Icons.send),
                      label: const Text(
                        'Enviar por WhatsApp',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/order-form'),
                    child: const Text('Editar información'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderDetails extends StatelessWidget {
  final Order order;

  const _OrderDetails({required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailSection(
          title: 'Negocio',
          icon: Icons.store,
          content: order.business.name,
        ),
        const SizedBox(height: 16),
        _DetailSection(
          title: 'Cliente',
          icon: Icons.person,
          content: order.customerName,
        ),
        const SizedBox(height: 16),
        _DetailSection(
          title: 'Dirección',
          icon: Icons.location_on,
          content: order.address,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shopping_bag, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Productos',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.product.name} x${item.quantity}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        PriceFormatter.format(item.totalPrice),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    PriceFormatter.format(order.totalAmount),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (order.comments != null && order.comments!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _DetailSection(
            title: 'Comentarios',
            icon: Icons.comment,
            content: order.comments!,
          ),
        ],
      ],
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String content;

  const _DetailSection({
    required this.title,
    required this.icon,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
