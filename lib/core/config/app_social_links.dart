import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Configuración de enlaces a redes sociales.
class AppSocialLinks {
  AppSocialLinks._();

  /// Enlaces principales de redes sociales.
  static const List<SocialLink> mainLinks = [
    SocialLink(
      name: 'Twitter',
      url: 'https://twitter.com/botlode',
      icon: FontAwesomeIcons.xTwitter,
    ),
    SocialLink(
      name: 'Discord',
      url: 'https://discord.gg/botlode',
      icon: FontAwesomeIcons.discord,
    ),
    SocialLink(
      name: 'GitHub',
      url: 'https://github.com/botlode',
      icon: FontAwesomeIcons.github,
    ),
  ];

  /// Enlaces del footer.
  static const List<SocialLink> footerLinks = [
    SocialLink(
      name: 'Twitter',
      url: 'https://twitter.com/botlode',
      icon: FontAwesomeIcons.xTwitter,
    ),
    SocialLink(
      name: 'Discord',
      url: 'https://discord.gg/botlode',
      icon: FontAwesomeIcons.discord,
    ),
    SocialLink(
      name: 'LinkedIn',
      url: 'https://linkedin.com/company/botlode',
      icon: FontAwesomeIcons.linkedin,
    ),
  ];

  /// Email de contacto.
  static const String contactEmail = 'hola@botlode.com';
  
  /// URL del sitio web.
  static const String websiteUrl = 'https://botlode.com';
}

/// Modelo para un enlace de red social.
class SocialLink {
  final String name;
  final String url;
  final IconData icon;

  const SocialLink({
    required this.name,
    required this.url,
    required this.icon,
  });
}
