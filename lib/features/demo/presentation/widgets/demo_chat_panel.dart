import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_constants.dart';
import '../../../../shared/utils/color_utils.dart';
import '../../../../shared/widgets/rive_bot_avatar.dart';
import '../../domain/entities/demo_bot_entity.dart';
import '../../domain/entities/demo_chat_message.dart';
import '../mappers/bot_ui_mapper.dart';
import '../providers/demo_provider.dart';

/// Panel de chat de un bot de demo (Diseño 100% BotLode Player)
class DemoChatPanel extends ConsumerStatefulWidget {
  final DemoBotEntity bot;

  const DemoChatPanel({
    super.key,
    required this.bot,
  });

  @override
  ConsumerState<DemoChatPanel> createState() => _DemoChatPanelState();
}

class _DemoChatPanelState extends ConsumerState<DemoChatPanel> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  /// Igual que botlode_player: ocultar Rive al hacer click en él para dar más espacio al chat.
  /// Tap en el área del chat lo muestra de nuevo.
  bool _hideRiveForSpace = false;
  bool _isInputFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!mounted) return;
      setState(() {
        _isInputFocused = _focusNode.hasFocus;
        // Al hacer click en el input (foco), ocultar el RIV para dar más espacio al chat
        if (_focusNode.hasFocus) _hideRiveForSpace = true;
      });
    });
    // Al abrir el chat: asegurar que el RIV se vea por defecto (sin foco en el input)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() => _hideRiveForSpace = false);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Mismo mapeo que botlode_player para el input Mood del Rive (0=neutral, 1=angry, 2=happy, 3=sales, 4=confused, 5=tech)
  int _moodStringToIndex(String mood) {
    switch (mood.toLowerCase()) {
      case 'angry': return 1;
      case 'happy': return 2;
      case 'sales': return 3;
      case 'confused': return 4;
      case 'tech': return 5;
      case 'neutral':
      case 'idle':
      default: return 0;
    }
  }

  /// Color del mood (igual que botlode_player StatusIndicator): avatar y status cambian juntos
  static Color _moodToColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'angry': return const Color(0xFFFF2A00);
      case 'happy': return const Color(0xFFFF00D6);
      case 'sales': return const Color(0xFFFFC000);
      case 'confused': return const Color(0xFF7B00FF);
      case 'tech': return const Color(0xFF00F0FF);
      case 'neutral':
      case 'idle':
      default: return const Color(0xFF00FF94); // EN LÍNEA
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Igual que botlode_player: quitar foco al enviar para que vuelva el Rive (animación carga)
    FocusManager.instance.primaryFocus?.unfocus();

    ref.read(demoProvider.notifier).sendMessage(widget.bot.id, message);
    _messageController.clear();

    // Scroll al inicio (reverse list) - protegido contra widget desmontado
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      
      try {
        if (_scrollController.hasClients && _scrollController.positions.isNotEmpty) {
          _scrollController.jumpTo(0.0);
        }
      } catch (e) {
        // Ignorar errores de scroll si el controller ya fue disposed
      }
    });
    
    // Re-enfocar input cuando termine de escribir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !widget.bot.isTyping) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppConstants.tablet;
    
    // Escuchar cambios específicos del bot con select para evitar reconstrucciones innecesarias
    final currentBot = ref.watch(demoProvider.select((s) {
      try {
        return s.bots.firstWhere(
          (b) => b.id == widget.bot.id,
          orElse: () => widget.bot,
        );
      } catch (e) {
        return widget.bot;
      }
    }));

    // Igual que botlode_player: contraer header al click en robot o input enfocado (móvil).
    // Cuando isTyping, SIEMPRE mostrar Rive para ver animación de carga.
    const double kHeaderFull = 200.0;
    const double kHeaderCompact = 48.0;
    final isCompact = !currentBot.isTyping &&
        (_hideRiveForSpace || (isMobile && _isInputFocused));
    final double headerHeight = isCompact ? kHeaderCompact : kHeaderFull;

    // COLORES - Modo oscuro por defecto
    const Color solidBgColor = Color(0xFF181818);
    final Color borderColor = Color(0xFF3A3A3A);
    final Color inputFill = Color(0xFF1F1F1F);
    final Color inputBorder = Color(0xFF2D2D2D);
    final Color inputBorderFocused = Colors.grey.shade600;

    return Container(
      width: double.infinity,
      height: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: solidBgColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            // HEADER - Igual que botlode_player: compacto (48px) o completo (200px) con Rive
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              height: headerHeight,
              width: double.infinity,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: solidBgColor,
                border: Border(bottom: BorderSide(color: borderColor, width: 1)),
              ),
              child: isCompact
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _StatusIndicator(
                            isTyping: currentBot.isTyping,
                            mood: currentBot.mood,
                            botColor: BotUIMapper.toFlutterColor(currentBot.color),
                          ),
                        ],
                      ),
                    )
                  : Stack(
                      children: [
                        // Avatar - click para ocultar (más espacio al chat)
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => setState(() => _hideRiveForSpace = true),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: RiveBotAvatar(
                                size: 200,
                                glowColor: _moodToColor(currentBot.mood),
                                enableMouseTracking: true,
                                isThinking: currentBot.isTyping,
                                moodIndex: _moodStringToIndex(currentBot.mood),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 20,
                          child: _StatusIndicator(
                            isTyping: currentBot.isTyping,
                            mood: currentBot.mood,
                            botColor: BotUIMapper.toFlutterColor(currentBot.color),
                          ),
                        ),
                      ],
                    ),
            ),
            // BODY (CHAT) - Tap en el área muestra el Rive si estaba oculto (igual botlode_player)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (_hideRiveForSpace) {
                    setState(() => _hideRiveForSpace = false);
                  }
                },
                child: Container(
                  color: solidBgColor,
                  child: _ChatMessages(
                    bot: currentBot,
                    scrollController: _scrollController,
                  ),
                ),
              ),
            ),
            
            // INPUT AREA - Diseño profesional de botlode_player
            Container(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + (isMobile ? 0 : 0)),
              decoration: BoxDecoration(
                color: solidBgColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: _ProfessionalInputField(
                controller: _messageController,
                focusNode: _focusNode,
                isTyping: currentBot.isTyping,
                themeColor: BotUIMapper.toFlutterColor(currentBot.color),
                inputFill: inputFill,
                inputBorder: inputBorder,
                inputBorderFocused: inputBorderFocused,
                onSend: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// _DemoBotAvatar eliminado - ahora usa RiveBotAvatar compartido (DRY + arquitectura limpia)

/// Indicador de estado tech con barra animada - Diseño BotLode Player
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
    // Igual que botlode_player: no cambiar a "ESCRIBIENDO..." cuando está procesando,
    // mantener estado según mood ("EN LÍNEA" para neutral)
    String text;
    Color color;

    switch (mood.toLowerCase()) {
      case 'angry':
        text = "ENOJADO";
        color = const Color(0xFFFF2A00);
        break;
      case 'happy':
        text = "FELIZ";
        color = const Color(0xFFFF00D6);
        break;
      case 'sales':
        text = "VENDEDOR";
        color = const Color(0xFFFFC000);
        break;
      case 'confused':
        text = "CONFUNDIDO";
        color = const Color(0xFF7B00FF);
        break;
      case 'tech':
        text = "TÉCNICO";
        color = const Color(0xFF00F0FF);
        break;
      case 'neutral':
      case 'idle':
      default:
        text = "EN LÍNEA";
        color = const Color(0xFF00FF94);
        break;
    }

    // Diseño modo oscuro (como en BotLode Player)
    const Color bgColor = Color(0xFF0A0A0A);
    final Color textColor = Colors.white.withValues(alpha: 0.9);
    final Color borderColor = Colors.white.withValues(alpha: 0.1);

    // Barra reactor (la barra vertical animada)
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
            topLeft: Radius.circular(0), // Sin radio
            bottomRight: Radius.circular(10), // Corte característico pronunciado
            topRight: Radius.circular(4), // Radio pequeño
            bottomLeft: Radius.circular(4), // Radio pequeño
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
          // Barra animada con pulso (fadeIn → hold → fadeOut → repeat)
          reactorBar
              .animate(onPlay: (c) => c.repeat())
              .fadeIn(duration: 200.ms, curve: Curves.easeOut)
              .then(delay: 1300.ms)
              .fadeOut(duration: 800.ms, curve: Curves.easeIn)
              .then(delay: 150.ms),
          
          const SizedBox(width: 10),
          
          // Texto técnico estilo Courier
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

/// Lista de mensajes (REVERSA como botlode_player)
class _ChatMessages extends StatelessWidget {
  final DemoBotEntity bot;
  final ScrollController scrollController;

  const _ChatMessages({
    required this.bot,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final reversedMessages = bot.messages.reversed.toList();
    
    return ListView.builder(
      controller: scrollController,
      reverse: true, // ⬅️ CRÍTICO: Lista reversa como botlode_player
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      physics: const BouncingScrollPhysics(),
      itemCount: reversedMessages.length + (bot.isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        // Indicador de escritura al principio (índice 0)
        if (bot.isTyping && index == 0) {
          return Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 20), 
            child: Row(
              children: [
                SizedBox(
                  width: 12, 
                  height: 12, 
                  child: CircularProgressIndicator(
                    strokeWidth: 2, 
                    color: Colors.white38,
                  ),
                ), 
                const SizedBox(width: 8), 
                _ThinkingIndicator(botColor: BotUIMapper.toFlutterColor(bot.color)),
              ],
            ),
          );
        }
        
        // Ajustar índice si hay indicador de escritura
        final messageIndex = bot.isTyping ? index - 1 : index;
        final message = reversedMessages[messageIndex];
        
        return _ChatBubble(
          message: message,
          botColor: BotUIMapper.toFlutterColor(bot.color),
        );
      },
    );
  }
}

/// Burbuja de mensaje con diseño EXACTO de botlode_player
class _ChatBubble extends StatelessWidget {
  final DemoChatMessage message;
  final Color botColor;

  const _ChatBubble({
    required this.message,
    required this.botColor,
  });

  // Usa la utilidad compartida para obtener el color de contraste
  Color _getContrastingTextColor(Color background) {
    return ColorUtils.getContrastingTextColor(background);
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    
    // DEFINICIÓN DE COLORES (MODO OSCURO)
    Color bgColor;
    Color textColor;
    BoxBorder? border;

    if (isUser) {
      // USUARIO
      bgColor = botColor;
      textColor = _getContrastingTextColor(botColor); 
      border = null;
    } else {
      // BOT (modo oscuro)
      bgColor = Colors.white.withValues(alpha: 0.10);
      textColor = Colors.white;
      border = Border.all(color: Colors.white.withValues(alpha: 0.08));
    }
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: bgColor,
          // ⬅️ ESQUINAS ASIMÉTRICAS (diseño exacto de botlode_player)
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),  // ⬅️ Perpendicular en bot
            bottomRight: Radius.circular(isUser ? 4 : 18), // ⬅️ Perpendicular en user
          ),
          border: border,
          boxShadow: isUser 
             ? [BoxShadow(color: botColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
             : null,
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: textColor,
            height: 1.4,
            fontSize: 14,
            fontWeight: isUser ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// Indicador de pensamiento con shimmer (estilo botlode_player)
class _ThinkingIndicator extends StatefulWidget {
  final Color botColor;
  
  const _ThinkingIndicator({required this.botColor});

  @override
  State<_ThinkingIndicator> createState() => _ThinkingIndicatorState();
}

class _ThinkingIndicatorState extends State<_ThinkingIndicator> 
    with SingleTickerProviderStateMixin {
  String _currentMessage = "Procesando...";
  DateTime? _startTime;
  late AnimationController _shimmerController;
  
  final List<String> _messages = [
    "Procesando...",
    "Escribiendo...",
    "Analizando...",
    "Casi listo...",
  ];
  
  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _updateMessage();
    
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }
  
  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }
  
  void _updateMessage() {
    if (_startTime == null) return;
    
    final elapsed = DateTime.now().difference(_startTime!);
    final seconds = elapsed.inSeconds;
    
    int messageIndex = 0;
    if (seconds >= 9) {
      messageIndex = 3;
    } else if (seconds >= 6) {
      messageIndex = 2;
    } else if (seconds >= 2) {
      messageIndex = 1;
    } else {
      messageIndex = 0;
    }
    
    if (mounted && _currentMessage != _messages[messageIndex]) {
      setState(() {
        _currentMessage = _messages[messageIndex];
      });
    }
    
    if (mounted && seconds < 12) {
      Future.delayed(const Duration(seconds: 1), _updateMessage);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (switcherChild, animation) {
            return FadeTransition(
              opacity: animation,
              child: switcherChild,
            );
          },
          child: ShaderMask(
            key: ValueKey(_currentMessage),
            shaderCallback: (bounds) {
              final shimmerPosition = _shimmerController.value * 3.0 - 1.0;
              
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: const [
                  Colors.white38,
                  Colors.white38,
                  Colors.white,
                  Colors.white,
                  Colors.white38,
                  Colors.white38,
                ],
                stops: [
                  0.0,
                  (shimmerPosition - 0.3).clamp(0.0, 1.0),
                  (shimmerPosition - 0.1).clamp(0.0, 1.0),
                  (shimmerPosition + 0.1).clamp(0.0, 1.0),
                  (shimmerPosition + 0.3).clamp(0.0, 1.0),
                  1.0,
                ],
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: Text(
              _currentMessage,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Input profesional (diseño exacto de botlode_player)
class _ProfessionalInputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isTyping;
  final Color themeColor;
  final Color inputFill;
  final Color inputBorder;
  final Color inputBorderFocused;
  final VoidCallback onSend;

  const _ProfessionalInputField({
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
  State<_ProfessionalInputField> createState() => _ProfessionalInputFieldState();
}

class _ProfessionalInputFieldState extends State<_ProfessionalInputField> {
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    
    widget.focusNode.addListener(() {
      if (mounted) {
        setState(() => _isFocused = widget.focusNode.hasFocus);
      }
    });
    
    widget.controller.addListener(() {
      if (mounted) {
        setState(() => _hasText = widget.controller.text.trim().isNotEmpty);
      }
    });
    
    // No enfocar al iniciar: que el RIV se vea por defecto al abrir el chat.
    // El usuario al hacer click en el input ocultará el RIV.
  }

  @override
  void didUpdateWidget(_ProfessionalInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Cuando termina de escribir, enfocar automáticamente
    if (oldWidget.isTyping && !widget.isTyping) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && widget.focusNode.canRequestFocus) {
          widget.focusNode.requestFocus();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isInputEnabled = !widget.isTyping;
    final borderColor = _isFocused ? widget.inputBorderFocused : widget.inputBorder;
    final inputOpacity = isInputEnabled ? 1.0 : 0.6;
    
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: inputOpacity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Container(
          decoration: BoxDecoration(
            color: widget.inputFill,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: borderColor,
              width: 1.0,
            ),
            boxShadow: _isFocused ? [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.05),
                blurRadius: 12,
                spreadRadius: 0,
              ),
            ] : null,
          ),
          child: Row(
          children: [
            const SizedBox(width: 20),
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                enabled: isInputEnabled,
                readOnly: widget.isTyping,
                onSubmitted: (_) => isInputEnabled && _hasText ? widget.onSend() : null,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.2,
                ),
                cursorColor: Colors.white70,
                decoration: InputDecoration(
                  hintText: widget.isTyping 
                      ? "El bot está respondiendo..." 
                      : "Escribe un mensaje...",
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Botón de enviar
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.all(6),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: (isInputEnabled && _hasText)
                    ? LinearGradient(
                        colors: [
                          widget.themeColor,
                          widget.themeColor.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: (isInputEnabled && _hasText) ? null : Colors.grey.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                boxShadow: (isInputEnabled && _hasText) ? [
                  BoxShadow(
                    color: widget.themeColor.withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: (isInputEnabled && _hasText) ? widget.onSend : null,
                  child: Center(
                    child: Icon(
                      Icons.send_rounded,
                      color: (isInputEnabled && _hasText) ? Colors.white : Colors.grey.shade600,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          ),
        ),
      ),
    );
  }
}
