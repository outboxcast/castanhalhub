import 'package:url_launcher/url_launcher.dart';
import '../services/supabase_service.dart';

class LauncherUtils {
  static final SupabaseService _service = SupabaseService();

  static Future<void> openWhatsApp({
    required String businessId,
    required String phone,
    String message = "Olá! Vi seu anúncio no Castanhal Hub.",
  }) async {
    // 1. Limpa impurezas (parênteses, traços, espaços)
    String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');

    // 2. Garante o código do Brasil (55)
    if (!cleanPhone.startsWith('55')) {
      // 3. Garante o DDD 91 se o número for curto (ex: 988887777)
      if (cleanPhone.length <= 9) {
        cleanPhone = '5591$cleanPhone';
      } else {
        cleanPhone = '55$cleanPhone';
      }
    }

    final Uri url = Uri.parse("https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}");

    // Registrar conversão antes de abrir
    await _service.logClick(businessId, 'whatsapp');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> openInstagram({
    required String businessId,
    required String handle,
  }) async {
    // Remove o '@' se o usuário tiver colocado
    final String cleanHandle = handle.replaceAll('@', '');
    final Uri url = Uri.parse("https://instagram.com/$cleanHandle");

    await _service.logClick(businessId, 'instagram');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
