import 'package:flutter/material.dart';

import '../../domain/value_objects/bot_color.dart';
import '../../domain/value_objects/bot_icon.dart';

/// Mapper para convertir tipos del dominio a tipos de Flutter UI
class BotUIMapper {
  BotUIMapper._();

  /// Convierte BotColor del dominio a Color de Flutter
  static Color toFlutterColor(BotColor botColor) {
    return Color(botColor.value);
  }

  /// Convierte Color de Flutter a BotColor del dominio
  static BotColor fromFlutterColor(Color color) {
    return BotColor(color.value);
  }

  /// Convierte BotIcon del dominio a IconData de Flutter
  static IconData toFlutterIcon(BotIcon botIcon) {
    switch (botIcon.iconName) {
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'build':
        return Icons.build;
      case 'business_center':
        return Icons.business_center;
      case 'help_outline':
        return Icons.help_outline;
      case 'chat':
        return Icons.chat;
      case 'smart_toy':
        return Icons.smart_toy;
      case 'psychology':
        return Icons.psychology;
      case 'support':
        return Icons.support;
      default:
        return Icons.chat; // Icono por defecto
    }
  }

  /// Convierte IconData de Flutter a BotIcon del dominio
  static BotIcon fromFlutterIcon(IconData icon) {
    // Mapeo básico - puede expandirse según necesidades
    if (icon == Icons.shopping_cart) return BotIcon.shoppingCart;
    if (icon == Icons.build) return BotIcon.build;
    if (icon == Icons.business_center) return BotIcon.businessCenter;
    if (icon == Icons.help_outline) return BotIcon.helpOutline;
    if (icon == Icons.chat) return BotIcon.chat;
    if (icon == Icons.smart_toy) return BotIcon.smartToy;
    if (icon == Icons.psychology) return BotIcon.psychology;
    if (icon == Icons.support) return BotIcon.support;
    
    return BotIcon.chat; // Por defecto
  }
}
