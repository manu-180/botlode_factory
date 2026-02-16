/// Value object para el icono de un bot sin dependencias de Flutter
/// Almacena el nombre del icono como string para ser mapeado después
class BotIcon {
  final String iconName;

  const BotIcon(this.iconName);

  /// Iconos predefinidos
  static const BotIcon shoppingCart = BotIcon('shopping_cart');
  static const BotIcon build = BotIcon('build');
  static const BotIcon businessCenter = BotIcon('business_center');
  static const BotIcon helpOutline = BotIcon('help_outline');
  static const BotIcon chat = BotIcon('chat');
  static const BotIcon smartToy = BotIcon('smart_toy');
  static const BotIcon psychology = BotIcon('psychology');
  static const BotIcon support = BotIcon('support');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BotIcon && runtimeType == other.runtimeType && iconName == other.iconName;

  @override
  int get hashCode => iconName.hashCode;

  @override
  String toString() => 'BotIcon($iconName)';
}
