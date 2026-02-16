import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../domain/entities/demo_bot_entity.dart';
import '../../mappers/bot_ui_mapper.dart';

/// Header del chat con avatar y estado del bot (diseño igual que botlode_player)
class ChatHeader extends StatelessWidget {
  final DemoBotEntity bot;
  final Widget avatarWidget;
  final Color backgroundColor;
  final Color borderColor;

  const ChatHeader({
    super.key,
    required this.bot,
    required this.avatarWidget,
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: avatarWidget,
            ),
          ),
          Positioned(
            bottom: 12,
            left: 20,
            child: _StatusIndicator(
              isTyping: bot.isTyping,
              mood: bot.mood,
              botColor: BotUIMapper.toFlutterColor(bot.color),
            ),
          ),
        ],
      ),
    );
  }
}

/// Indicador de estado igual que botlode_player: reactor bar + texto técnico (EN LÍNEA, ENOJADO, FELIZ, etc.)
class _StatusIndicator extends StatelessWidget {
  final bool isTyping;
  final String mood;
  final Color botColor;

  const _StatusIndicator({
    required this.isTyping,
    required this.mood,
    required this.botColor,
  });

  @override
  Widget build(BuildContext context) {
    // Igual que botlode_player: no cambiar a "ESCRIBIENDO..." cuando está procesando, mantener estado según mood
    String text;
    Color color;
    switch (mood.toLowerCase()) {
      case 'angry': text = 'ENOJADO'; color = const Color(0xFFFF2A00); break;
      case 'happy': text = 'FELIZ'; color = const Color(0xFFFF00D6); break;
      case 'sales': text = 'VENDEDOR'; color = const Color(0xFFFFC000); break;
      case 'confused': text = 'CONFUNDIDO'; color = const Color(0xFF7B00FF); break;
      case 'tech': text = 'TÉCNICO'; color = const Color(0xFF00F0FF); break;
      case 'neutral':
      case 'idle':
      default: text = 'EN LÍNEA'; color = const Color(0xFF00FF94); break;
    }

    const Color bgColor = Color(0xFF0A0A0A);
    final Color textColor = Colors.white.withValues(alpha: 0.9);
    final Color borderColor = Colors.white.withValues(alpha: 0.1);

    final Widget reactorBar = Container(
      width: 4,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(color: color, blurRadius: 4, spreadRadius: 1),
          BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 12, spreadRadius: 3),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.only(left: 6, right: 12, top: 6, bottom: 6),
      decoration: ShapeDecoration(
        color: bgColor.withValues(alpha: 0.95),
        shape: BeveledRectangleBorder(
          side: BorderSide(color: borderColor, width: 1),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(0),
            bottomRight: Radius.circular(10),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(4),
          ),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          reactorBar
              .animate(onPlay: (c) => c.repeat())
              .fadeIn(duration: 200.ms, curve: Curves.easeOut)
              .then(delay: 1300.ms)
              .fadeOut(duration: 800.ms, curve: Curves.easeIn)
              .then(delay: 150.ms),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontFamily: 'Courier',
              fontWeight: FontWeight.w800,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
