import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Servicio para abrir URLs externas.
/// Abstrae la dependencia de url_launcher para facilitar testing y mantenimiento.
class UrlLauncherService {
  /// Abre una URL en el navegador.
  Future<bool> openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      debugPrint('No se puede abrir la URL: $url');
      return false;
    } catch (e) {
      debugPrint('Error al abrir URL: $e');
      return false;
    }
  }

  /// Abre una URL en una nueva pestaña del navegador.
  Future<bool> openUrlInNewTab(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
      debugPrint('No se puede abrir la URL: $url');
      return false;
    } catch (e) {
      debugPrint('Error al abrir URL: $e');
      return false;
    }
  }

  /// Abre el cliente de email con un destinatario.
  Future<bool> openEmail(String email, {String? subject, String? body}) async {
    try {
      final params = <String, String>{};
      if (subject != null) params['subject'] = subject;
      if (body != null) params['body'] = body;

      final uri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: params.isNotEmpty ? params : null,
      );

      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
      debugPrint('No se puede abrir el email: $email');
      return false;
    } catch (e) {
      debugPrint('Error al abrir email: $e');
      return false;
    }
  }

  /// Abre el teléfono con un número.
  Future<bool> openPhone(String phoneNumber) async {
    try {
      final uri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
      debugPrint('No se puede abrir el teléfono: $phoneNumber');
      return false;
    } catch (e) {
      debugPrint('Error al abrir teléfono: $e');
      return false;
    }
  }

  /// Abre WhatsApp con un número.
  Future<bool> openWhatsApp(String phoneNumber, {String? message}) async {
    try {
      final url = message != null
          ? 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}'
          : 'https://wa.me/$phoneNumber';
      return await openUrl(url);
    } catch (e) {
      debugPrint('Error al abrir WhatsApp: $e');
      return false;
    }
  }

  /// Verifica si una URL puede ser abierta.
  Future<bool> canOpen(String url) async {
    try {
      final uri = Uri.parse(url);
      return await canLaunchUrl(uri);
    } catch (e) {
      return false;
    }
  }
}

/// Provider del servicio de URL launcher.
final urlLauncherServiceProvider = Provider<UrlLauncherService>((ref) {
  return UrlLauncherService();
});
