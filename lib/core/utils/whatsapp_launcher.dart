import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/order.dart';

class WhatsAppLauncher {
  static Future<bool> sendOrder(Order order) async {
    final message = Uri.encodeComponent(order.generateWhatsAppMessage());
    final whatsappUrl =
        'whatsapp://send?phone=${order.business.whatsappNumber}&text=$message';

    final uri = Uri.parse(whatsappUrl);

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      } else {
        // Fallback a la versión web si la app no está disponible
        final webUrl =
            'https://wa.me/${order.business.whatsappNumber}?text=$message';
        final webUri = Uri.parse(webUrl);
        return await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Último intento con la URL web
      final webUrl =
          'https://wa.me/${order.business.whatsappNumber}?text=$message';
      final webUri = Uri.parse(webUrl);
      return await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }
}
