/// Value object para el color de un bot sin dependencias de Flutter
class BotColor {
  final int value;

  const BotColor(this.value);

  /// Color desde valores ARGB
  const BotColor.fromARGB(int a, int r, int g, int b)
      : value = ((a & 0xff) << 24) |
              ((r & 0xff) << 16) |
              ((g & 0xff) << 8) |
              ((b & 0xff) << 0);

  /// Color desde hex (ejemplo: 0xFFFF5722)
  const BotColor.fromHex(int hex) : value = hex;

  /// Componente alpha (0-255)
  int get alpha => (value >> 24) & 0xff;

  /// Componente rojo (0-255)
  int get red => (value >> 16) & 0xff;

  /// Componente verde (0-255)
  int get green => (value >> 8) & 0xff;

  /// Componente azul (0-255)
  int get blue => value & 0xff;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BotColor && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'BotColor(0x${value.toRadixString(16).padLeft(8, '0').toUpperCase()})';
}
