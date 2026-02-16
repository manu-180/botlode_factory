import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../core/config/app_colors.dart';
import '../../../../../shared/utils/color_utils.dart';
import '../../../domain/entities/demo_chat_message.dart';

/// Burbuja de mensaje del chat
class ChatMessageBubble extends StatelessWidget {
  final DemoChatMessage message;
  final Color botColor;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.botColor,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? botColor : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
          ),
          border: Border.all(
            color: isUser ? botColor : AppColors.borderGlass,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (isUser ? botColor : AppColors.borderGlass).withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isUser 
                    ? ColorUtils.getContrastingTextColor(botColor)
                    : AppColors.textPrimary,
                height: 1.5,
              ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1, end: 0);
  }
}
