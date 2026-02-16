import 'package:flutter/material.dart';

/// Campo de entrada del chat
class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isTyping;
  final Color themeColor;
  final Color inputFill;
  final Color inputBorder;
  final Color inputBorderFocused;
  final VoidCallback onSend;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isTyping,
    required this.themeColor,
    required this.inputFill,
    required this.inputBorder,
    required this.inputBorderFocused,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: !isTyping,
              maxLines: 3,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: isTyping ? null : (_) => onSend(),
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: isTyping ? 'Esperando respuesta...' : 'Escribe tu mensaje...',
                filled: true,
                fillColor: inputFill,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: inputBorder, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: inputBorder, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: inputBorderFocused, width: 1.5),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: inputBorder.withValues(alpha: 0.5)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Botón enviar
          Material(
            color: isTyping ? Colors.grey.shade800 : themeColor,
            borderRadius: BorderRadius.circular(50),
            child: InkWell(
              onTap: isTyping ? null : onSend,
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: Icon(
                  Icons.send_rounded,
                  size: 22,
                  color: isTyping ? Colors.grey.shade600 : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
