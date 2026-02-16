import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../../../../core/config/app_colors.dart';

/// Widget compacto y profesional para seleccionar el color del bot
class ColorPickerSection extends StatefulWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPickerSection({
    super.key,
    required this.selectedColor,
    required this.onColorChanged,
  });

  @override
  State<ColorPickerSection> createState() => _ColorPickerSectionState();
}

class _ColorPickerSectionState extends State<ColorPickerSection> {
  late TextEditingController _hexController;
  bool _isHexInputError = false;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _hexController = TextEditingController(
      text: widget.selectedColor.value.toRadixString(16).toUpperCase().substring(2),
    );
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  void _updateHexText(Color color) {
    if (mounted) {
      _hexController.text = color.value.toRadixString(16).toUpperCase().substring(2);
    }
  }

  void _handleHexSubmit(String value) {
    final hexCode = value.toUpperCase().replaceAll('#', '');
    if (hexCode.length != 6) {
      setState(() => _isHexInputError = true);
      return;
    }
    try {
      final newColor = Color(int.parse('0xFF$hexCode'));
      setState(() {
        widget.onColorChanged(newColor);
        _isHexInputError = false;
      });
      FocusScope.of(context).unfocus();
    } catch (e) {
      setState(() => _isHexInputError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black.withValues(alpha: 0.3),
        border: Border.all(
          color: AppColors.borderGlass,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildCompactHeader(),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isExpanded ? _buildExpandedPicker() : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactHeader() {
    return InkWell(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Preview del color (limpio, sin glow)
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: widget.selectedColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.palette_outlined,
                color: _getContrastColor(widget.selectedColor),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // Info y controles
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "CALIBRACIÓN DE NÚCLEO",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Input HEX compacto
                  SizedBox(
                    height: 36,
                    child: TextField(
                      controller: _hexController,
                      style: TextStyle(
                        color: widget.selectedColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Courier',
                        fontSize: 13,
                      ),
                      maxLength: 6,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]')),
                        UpperCaseTextFormatter(),
                      ],
                      decoration: InputDecoration(
                        counterText: "",
                        prefixText: "# ",
                        prefixStyle: TextStyle(
                          color: widget.selectedColor.withValues(alpha: 0.6),
                          fontWeight: FontWeight.bold,
                        ),
                        filled: true,
                        fillColor: Colors.black.withValues(alpha: 0.5),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _isHexInputError
                                ? AppColors.error
                                : AppColors.borderGlass,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _isHexInputError ? AppColors.error : AppColors.borderLight,
                            width: 1.5,
                          ),
                        ),
                      ),
                      onSubmitted: _handleHexSubmit,
                      onTapOutside: (_) => _handleHexSubmit(_hexController.text),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedPicker() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          Container(
            height: 1,
            margin: const EdgeInsets.only(bottom: 16),
            color: AppColors.borderGlass,
          ),
          
          // ColorPicker optimizado
          Theme(
            data: ThemeData.dark(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.borderGlass,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: ColorPicker(
                pickerColor: widget.selectedColor,
                onColorChanged: (color) {
                  widget.onColorChanged(color);
                  setState(() {
                    _isHexInputError = false;
                    _updateHexText(color);
                  });
                },
                portraitOnly: true,
                enableAlpha: false,
                displayThumbColor: true,
                paletteType: PaletteType.hsvWithHue,
                hexInputBar: false,
                labelTypes: const [],
                pickerAreaHeightPercent: 0.5,
                pickerAreaBorderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getContrastColor(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

// Formatter para convertir el texto a mayúsculas (exactamente igual a botslode)
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
