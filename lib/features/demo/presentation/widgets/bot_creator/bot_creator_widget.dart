import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/config/app_colors.dart';
import '../../../../../shared/widgets/glow_border_card.dart';
import '../../../../../shared/widgets/glow_button.dart';
import '../../../domain/entities/bot_template.dart';
import '../../mappers/bot_ui_mapper.dart';
import '../../providers/demo_provider.dart';
import 'bot_creation_form.dart';
import 'color_picker_section.dart';
import 'template_selector.dart';

/// Widget coordinador para la creación de bots
/// Separado en componentes más pequeños siguiendo SRP
class BotCreatorWidget extends ConsumerStatefulWidget {
  const BotCreatorWidget({super.key});
  
  @override
  ConsumerState<BotCreatorWidget> createState() => _BotCreatorWidgetState();
}

class _BotCreatorWidgetState extends ConsumerState<BotCreatorWidget> {
  final _nameController = TextEditingController();
  final _promptController = TextEditingController();
  Color _selectedColor = AppColors.primary;
  BotTemplate? _selectedTemplate;

  @override
  void dispose() {
    _nameController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  void _selectTemplate(BotTemplate template) {
    setState(() {
      _selectedTemplate = template;
      _nameController.text = template.name;
      _promptController.text = template.prompt;
      _selectedColor = BotUIMapper.toFlutterColor(template.color);
    });
  }

  Future<void> _createBot() async {
    final name = _nameController.text;
    final prompt = _promptController.text;

    try {
      await ref.read(demoProvider.notifier).createBot(
            name: name,
            prompt: prompt,
            color: _selectedColor,
          );

      // Limpiar formulario
      _nameController.clear();
      _promptController.clear();
      setState(() => _selectedTemplate = null);

      if (!mounted) return;
      _showNotification(
        context: context,
        message: 'Bot creado exitosamente',
        icon: Icons.check_circle_rounded,
        color: AppColors.success,
      );
    } catch (e) {
      if (!mounted) return;
      _showNotification(
        context: context,
        message: e.toString().replaceFirst('Invalid argument(s): ', '').replaceFirst('Exception: ', ''),
        icon: Icons.warning_rounded,
        color: AppColors.warning,
      );
    }
  }

  void _showNotification({
    required BuildContext context,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _NotificationCard(
        message: message,
        icon: icon,
        color: color,
      ),
    );

    overlay.insert(overlayEntry);

    // Remover después de 6 segundos (5.2s visible + 0.4s animación salida + margen)
    Future.delayed(const Duration(seconds: 6), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isCreating = ref.watch(demoProvider.select((s) => s.isCreating));

    return GlowBorderCard(
      glowColor: _selectedColor,
      enableHoverScale: false,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context),
          const SizedBox(height: 24),

          // Templates
          TemplateSelector(
            selectedTemplate: _selectedTemplate,
            onTemplateSelected: _selectTemplate,
          ),
          const SizedBox(height: 24),

          // Formulario
          BotCreationForm(
            nameController: _nameController,
            promptController: _promptController,
            isCreating: isCreating,
          ),
          const SizedBox(height: 20),

          // Color Picker
          ColorPickerSection(
            selectedColor: _selectedColor,
            onColorChanged: (color) => setState(() => _selectedColor = color),
          ),
          const SizedBox(height: 24),

          // Botón de crear
          Center(
            child: GlowButton(
              onPressed: isCreating ? null : _createBot,
              text: isCreating ? 'Creando...' : 'CREAR BOT',
              icon: isCreating ? Icons.hourglass_empty : Icons.rocket_launch,
              color: AppColors.primary,
              isLoading: isCreating,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _selectedColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.add_circle_outline, color: _selectedColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CREAR NUEVO BOT',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: _selectedColor,
                      letterSpacing: 2,
                    ),
              ),
              Text(
                'Configura tu asistente virtual',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Card de notificación animada (diseño original con todas las animaciones)
class _NotificationCard extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color color;

  const _NotificationCard({
    required this.message,
    required this.icon,
    required this.color,
  });

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animación principal
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();

    // Animar salida antes de desaparecer
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  constraints: const BoxConstraints(maxWidth: 450),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.surface,
                    border: Border.all(
                      color: widget.color.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      // Sombra sutil y profesional
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Icono limpio
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: widget.color.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: widget.color.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            widget.icon,
                            color: widget.color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Mensaje
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Notificación',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 10,
                                      letterSpacing: 0.8,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.message,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
