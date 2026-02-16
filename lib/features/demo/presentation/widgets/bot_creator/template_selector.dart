import 'package:flutter/material.dart';

import '../../../../../core/config/app_colors.dart';
import '../../../data/bot_templates_data.dart';
import '../../../domain/entities/bot_template.dart';
import '../../mappers/bot_ui_mapper.dart';

/// Widget para seleccionar templates de bots
class TemplateSelector extends StatelessWidget {
  final BotTemplate? selectedTemplate;
  final ValueChanged<BotTemplate> onTemplateSelected;

  const TemplateSelector({
    super.key,
    required this.selectedTemplate,
    required this.onTemplateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Templates rápidos',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: BotTemplatesData.templates.map((template) {
            final isSelected = selectedTemplate == template;
            return _TemplateChip(
              template: template,
              isSelected: isSelected,
              onTap: () => onTemplateSelected(template),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Chip de template
class _TemplateChip extends StatefulWidget {
  final BotTemplate template;
  final bool isSelected;
  final VoidCallback onTap;

  const _TemplateChip({
    required this.template,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_TemplateChip> createState() => _TemplateChipState();
}

class _TemplateChipState extends State<_TemplateChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? BotUIMapper.toFlutterColor(widget.template.color)
                : (_isHovered
                    ? BotUIMapper.toFlutterColor(widget.template.color).withValues(alpha: 0.2)
                    : AppColors.surface),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected || _isHovered
                  ? BotUIMapper.toFlutterColor(widget.template.color)
                  : AppColors.borderGlass,
              width: widget.isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                BotUIMapper.toFlutterIcon(widget.template.icon),
                size: 16,
                color: widget.isSelected
                    ? AppColors.background
                    : BotUIMapper.toFlutterColor(widget.template.color),
              ),
              const SizedBox(width: 6),
              Text(
                widget.template.name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: widget.isSelected
                          ? AppColors.background
                          : (_isHovered
                              ? BotUIMapper.toFlutterColor(widget.template.color)
                              : AppColors.textSecondary),
                      fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
