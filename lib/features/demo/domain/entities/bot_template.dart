import '../value_objects/bot_color.dart';
import '../value_objects/bot_icon.dart';

/// Entidad de dominio pura para un template de bot.
/// La lista de templates predefinidos se encuentra en la capa de datos.
/// Sin dependencias de Flutter para mantener el dominio puro.
class BotTemplate {
  final String name;
  final String description;
  final String prompt;
  final BotColor color;
  final BotIcon icon;

  const BotTemplate({
    required this.name,
    required this.description,
    required this.prompt,
    required this.color,
    required this.icon,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BotTemplate &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}
