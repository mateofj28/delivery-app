import 'business.dart';
import 'cart_item.dart';
import '../../core/utils/price_formatter.dart';

class Order {
  final Business business;
  final List<CartItem> items;
  final String customerName;
  final String address;
  final String? comments;

  const Order({
    required this.business,
    required this.items,
    required this.customerName,
    required this.address,
    this.comments,
  });

  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  String generateWhatsAppMessage() {
    final buffer = StringBuffer();
    buffer.writeln('🛍️ *NUEVO PEDIDO*');
    buffer.writeln('');
    buffer.writeln('🏪 *Negocio:* ${business.name}');
    buffer.writeln('👤 *Cliente:* $customerName');
    buffer.writeln('📍 *Dirección:* $address');
    buffer.writeln('');
    buffer.writeln('📋 *Productos:*');

    for (final item in items) {
      buffer.writeln(
        '• ${item.product.name} x${item.quantity} - ${PriceFormatter.format(item.totalPrice)}',
      );
    }

    buffer.writeln('');
    buffer.writeln('💰 *Total: ${PriceFormatter.format(totalAmount)}*');

    if (comments != null && comments!.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('💬 *Comentarios:* $comments');
    }

    return buffer.toString();
  }
}
