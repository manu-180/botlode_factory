// Archivo: lib/core/providers/bot_mood_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Índice de emoción/modo del bot (0=neutral, 1=angry, 2=happy, 3=sales, 4=confused, 5=tech).
/// Gestionado con Riverpod para cambios instantáneos y sin trabar al clickear rápido.
final botMoodProvider = StateProvider<int>((ref) => 5);
