import 'package:flutter/material.dart';

import '../../../domain/entities/demo_bot_entity.dart';
import '../../mappers/bot_ui_mapper.dart';
import 'chat_message_bubble.dart';

/// Lista de mensajes del chat
class ChatMessagesList extends StatelessWidget {
  final DemoBotEntity bot;
  final ScrollController scrollController;
  final Color backgroundColor;

  const ChatMessagesList({
    super.key,
    required this.bot,
    required this.scrollController,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: bot.messages.isEmpty
          ? _buildEmptyState(context)
          : _buildMessagesList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: Colors.grey.shade700,
            ),
            const SizedBox(height: 16),
            Text(
              'Inicia la conversación',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Envía un mensaje para comenzar',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade700,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemCount: bot.messages.length + (bot.isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        // Mostrar indicador "escribiendo" al inicio si está escribiendo
        if (index == 0 && bot.isTyping) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _ThinkingIndicator(
              botColor: BotUIMapper.toFlutterColor(bot.color),
            ),
          );
        }

        // Ajustar índice si hay indicador "escribiendo"
        final messageIndex = bot.isTyping ? index - 1 : index;
        final reversedIndex = bot.messages.length - 1 - messageIndex;
        final message = bot.messages[reversedIndex];

        return ChatMessageBubble(
          message: message,
          botColor: BotUIMapper.toFlutterColor(bot.color),
        );
      },
    );
  }
}

/// Indicador de "escribiendo..."
class _ThinkingIndicator extends StatelessWidget {
  final Color botColor;

  const _ThinkingIndicator({required this.botColor});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: botColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: botColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: botColor,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Pensando...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: botColor,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
