import 'package:intl/intl.dart';

class PriceFormatter {
  static final _formatter = NumberFormat('#,###', 'es_CO');

  static String format(double price) {
    return '\$${_formatter.format(price.toInt())}';
  }
}
