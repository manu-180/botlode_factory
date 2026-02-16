import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Configuración del footer de la aplicación.
class FooterConfig {
  FooterConfig._();

  /// Estadísticas del footer.
  static const List<FooterStat> stats = [
    FooterStat(
      label: 'Bots Desplegados',
      value: 'Ilimitado',
      icon: FontAwesomeIcons.infinity,
    ),
    FooterStat(
      label: 'Modos',
      value: '6 estados',
      icon: Icons.psychology,
    ),
    FooterStat(
      label: 'Historial',
      value: 'Completo',
      icon: Icons.storage,
    ),
  ];

  /// Secciones de enlaces del footer.
  static const List<FooterLinkSection> linkSections = [
    FooterLinkSection(
      title: 'Producto',
      links: [
        FooterLink(label: 'Bot', route: '/bot'),
        FooterLink(label: 'Fábrica', route: '/factory'),
        FooterLink(label: 'Demo', route: '/demo'),
        FooterLink(label: 'Precios', route: '/pricing'),
      ],
    ),
    FooterLinkSection(
      title: 'Recursos',
      links: [
        FooterLink(label: 'Tutorial', route: '/tutorial'),
        FooterLink(label: 'Documentación', route: '/docs'),
        FooterLink(label: 'Blog', route: '/blog'),
        FooterLink(label: 'Changelog', route: '/changelog'),
      ],
    ),
    FooterLinkSection(
      title: 'Empresa',
      links: [
        FooterLink(label: 'Sobre Nosotros', route: '/about'),
        FooterLink(label: 'Contacto', route: '/contact'),
        FooterLink(label: 'Privacidad', route: '/privacy'),
        FooterLink(label: 'Términos', route: '/terms'),
      ],
    ),
  ];

  /// Texto de copyright.
  static String get copyrightText {
    final year = DateTime.now().year;
    return '© $year BotLode. Todos los derechos reservados.';
  }

  /// Slogan del footer.
  static const String slogan = 'Automatiza tu negocio con bots inteligentes';
}

/// Modelo para una estadística del footer.
class FooterStat {
  final String label;
  final String value;
  final IconData icon;

  const FooterStat({
    required this.label,
    required this.value,
    required this.icon,
  });
}

/// Modelo para una sección de enlaces del footer.
class FooterLinkSection {
  final String title;
  final List<FooterLink> links;

  const FooterLinkSection({
    required this.title,
    required this.links,
  });
}

/// Modelo para un enlace del footer.
class FooterLink {
  final String label;
  final String route;
  final String? externalUrl;

  const FooterLink({
    required this.label,
    this.route = '',
    this.externalUrl,
  });

  bool get isExternal => externalUrl != null && externalUrl!.isNotEmpty;
}
