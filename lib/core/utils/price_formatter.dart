import 'package:intl/intl.dart';

class PriceFormatter {
  static String format(double price) {
    // Si el precio es un número entero, no mostrar decimales
    if (price == price.toInt()) {
      return '\$${NumberFormat('#,###', 'es_CO').format(price.toInt())}';
    }
    // Si tiene decimales, mostrarlos
    return '\$${NumberFormat('#,###.##', 'es_CO').format(price)}';
  }
}
