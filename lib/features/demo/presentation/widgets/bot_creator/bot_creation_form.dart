import 'package:flutter/material.dart';

import '../../../../../core/config/app_colors.dart';

/// Formulario de creación de bot (nombre y prompt)
class BotCreationForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController promptController;
  final bool isCreating;

  const BotCreationForm({
    super.key,
    required this.nameController,
    required this.promptController,
    required this.isCreating,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo de nombre
        Text(
          'Nombre del Bot',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: nameController,
          enabled: !isCreating,
          decoration: InputDecoration(
            hintText: 'Ej: Vendedor Pro, Soporte 24/7...',
            prefixIcon: const Icon(Icons.badge_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderGlass),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderGlass),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Campo de personalidad
        Text(
          'Personalidad del Bot',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: promptController,
          enabled: !isCreating,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: 'Define cómo debe comportarse tu bot, su tono, especialización...',
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 120),
              child: Icon(Icons.psychology_outlined),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderGlass),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderGlass),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
