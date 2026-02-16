import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

import '../../core/config/app_colors.dart';
import '../../core/config/app_constants.dart';

/// Barra de navegación superior con efecto tecnológico
class Navbar extends StatelessWidget {
  final VoidCallback? onMenuTap;
  
  const Navbar({super.key, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppConstants.tablet;
    final isTablet = screenWidth >= AppConstants.tablet && screenWidth < 1024;
    
    // Padding responsive progresivo
    final horizontalPadding = isMobile 
        ? AppConstants.mobilePadding 
        : (isTablet ? 32.0 : AppConstants.desktopPadding);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.borderGlass),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo (flexible para contraerse si es necesario)
              Flexible(
                flex: isMobile ? 1 : (isTablet ? 1 : 0),
                child: _NavLogo(),
              ),

              // Espaciado adaptativo
              if (!isMobile) SizedBox(width: isTablet ? 8 : 16),

              // Links de navegación (solo desktop y tablet)
              if (!isMobile) 
                Flexible(
                  flex: isTablet ? 2 : 3,
                  child: _NavLinks(isTablet: isTablet),
                ),

              // Espaciado adaptativo
              if (!isMobile) SizedBox(width: isTablet ? 8 : 16),

              // Botón CTA o Menu (sin flex para mantener su tamaño)
              _NavCTA(
                isMobile: isMobile, 
                isTablet: isTablet,
                onMenuTap: onMenuTap,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
  }
}

/// Logo de BotLode
class _NavLogo extends StatefulWidget {
  @override
  State<_NavLogo> createState() => _NavLogoState();
}

class _NavLogoState extends State<_NavLogo> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasValidSize = constraints.maxWidth > 0;
        final screenWidth = MediaQuery.of(context).size.width;
        
        // Mostrar solo el icono si el espacio es muy limitado
        final showText = constraints.maxWidth > 80 && screenWidth > 600;
        final iconSize = screenWidth < 768 ? 36.0 : 40.0;

        return MouseRegion(
          onEnter:
              hasValidSize ? (_) => setState(() => _isHovered = true) : null,
          onExit:
              hasValidSize ? (_) => setState(() => _isHovered = false) : null,
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => context.go(AppConstants.routeHome),
            child: AnimatedContainer(
              duration: AppConstants.durationFast,
              transform: Matrix4.diagonal3Values(
                _isHovered ? 1.05 : 1.0,
                _isHovered ? 1.05 : 1.0,
                1.0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icono/Logo
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: _isHovered
                          ? AppColors.glowShadow(intensity: 0.3)
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/icons/favicon.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: FaIcon(
                            FontAwesomeIcons.robot,
                            color: AppColors.background,
                            size: iconSize * 0.6,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Texto (solo si hay espacio suficiente)
                  if (showText) ...[
                    const SizedBox(width: 12),
                    Flexible(
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: _isHovered
                              ? [AppColors.primaryGlow, AppColors.primary]
                              : [AppColors.textPrimary, AppColors.textPrimary],
                        ).createShader(bounds),
                        child: Text(
                          'BOTLODE',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                                color: Colors.white,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Links de navegación con barra animada
class _NavLinks extends StatefulWidget {
  final bool isTablet;
  
  const _NavLinks({this.isTablet = false});

  @override
  State<_NavLinks> createState() => _NavLinksState();
}

class _NavLinksState extends State<_NavLinks> {
  late List<GlobalKey> _keys;
  late List<Map<String, dynamic>> _navItems;
  double _indicatorLeft = 0;
  double _indicatorWidth = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _navItems = [
      {'label': 'Home', 'route': AppConstants.routeHome, 'isHighlighted': false},
      {'label': 'Bot', 'route': AppConstants.routeBot, 'isHighlighted': false},
      {'label': 'Factory', 'route': AppConstants.routeFactory, 'isHighlighted': false},
      {'label': 'Tutorial', 'route': AppConstants.routeTutorial, 'isHighlighted': false},
      {'label': 'Demo', 'route': AppConstants.routeDemo, 'isHighlighted': false},
    ];
    _keys = List.generate(_navItems.length, (_) => GlobalKey());
    SchedulerBinding.instance.addPostFrameCallback((_) => _updateIndicator());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectedIndex();
    SchedulerBinding.instance.addPostFrameCallback((_) => _updateIndicator());
  }

  void _updateSelectedIndex() {
    final currentRoute = GoRouterState.of(context).uri.toString();
    final newIndex = _navItems.indexWhere((item) => currentRoute == item['route']);
    if (newIndex != -1 && newIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = newIndex;
      });
    }
  }

  void _updateIndicator() {
    if (!mounted || _selectedIndex < 0 || _selectedIndex >= _keys.length) return;
    
    try {
      final key = _keys[_selectedIndex];
      final RenderBox? renderBox = key.currentContext?.findRenderObject() as RenderBox?;

      if (renderBox != null && renderBox.hasSize && renderBox.attached) {
        final parentRenderBox = context.findRenderObject() as RenderBox?;
        if (parentRenderBox != null && parentRenderBox.hasSize && parentRenderBox.attached) {
          final itemOffset = renderBox.localToGlobal(Offset.zero);
          final parentOffset = parentRenderBox.localToGlobal(Offset.zero);
          final relativeX = itemOffset.dx - parentOffset.dx;
          
          if (mounted) {
            setState(() {
              _indicatorLeft = relativeX;
              _indicatorWidth = renderBox.size.width;
            });
          }
        }
      }
    } catch (e) {
      // Ignorar errores durante transiciones de layout
    }
  }

  @override
  Widget build(BuildContext context) {
    // Espaciado adaptativo según el tamaño de pantalla
    final horizontalPadding = widget.isTablet ? 6.0 : 12.0;
    
    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: _navItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == _selectedIndex;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: InkWell(
                  onTap: () => context.go(item['route']),
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Center(
                    child: Container(
                      key: _keys[index],
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: _NavLinkText(
                        text: item['label'],
                        isSelected: isSelected,
                        isHighlighted: item['isHighlighted'],
                        isCompact: widget.isTablet,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          // Barra indicadora animada
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.fastOutSlowIn,
            left: _indicatorLeft,
            width: _indicatorWidth,
            bottom: 10,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Texto del link con hover y estilos
class _NavLinkText extends StatefulWidget {
  final String text;
  final bool isSelected;
  final bool isHighlighted;
  final bool isCompact;

  const _NavLinkText({
    required this.text,
    required this.isSelected,
    this.isHighlighted = false,
    this.isCompact = false,
  });

  @override
  State<_NavLinkText> createState() => _NavLinkTextState();
}

class _NavLinkTextState extends State<_NavLinkText> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Ajustes de tamaño según compacidad
    final horizontalPadding = widget.isCompact ? 10.0 : 16.0;
    final letterSpacing = widget.isCompact ? 1.0 : 1.5;
    final fontSize = widget.isCompact ? 13.0 : null;
    
    // Para el botón DEMO destacado, pintamos todo el fondo cuando está seleccionado
    if (widget.isHighlighted && widget.isSelected) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: AppConstants.durationFast,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
          decoration: BoxDecoration(
            gradient: _isHovered ? AppColors.primaryGradient : null,
            color: _isHovered ? null : AppColors.primary,
            borderRadius: BorderRadius.circular(8),
            boxShadow: _isHovered 
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Text(
            widget.text.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.background,
                  fontWeight: FontWeight.w700,
                  letterSpacing: letterSpacing,
                  fontSize: fontSize,
                ),
          ),
        ),
      );
    }

    // Para los demás links, solo texto con hover
    final color = (widget.isSelected || _isHovered) 
        ? AppColors.primary 
        : AppColors.textSecondary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: Theme.of(context).textTheme.labelLarge!.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: letterSpacing,
          fontSize: fontSize,
          color: color,
        ),
        child: Text(widget.text.toUpperCase()),
      ),
    );
  }
}

/// Botón CTA de la navbar o botón de menú en móvil
class _NavCTA extends StatefulWidget {
  final bool isMobile;
  final bool isTablet;
  final VoidCallback? onMenuTap;

  const _NavCTA({
    required this.isMobile, 
    this.isTablet = false,
    this.onMenuTap,
  });

  @override
  State<_NavCTA> createState() => _NavCTAState();
}

class _NavCTAState extends State<_NavCTA> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // En móvil, mostrar botón de menú
    if (widget.isMobile) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final hasValidSize = constraints.maxWidth > 0;
          
          return MouseRegion(
            onEnter: hasValidSize ? (_) => setState(() => _isHovered = true) : null,
            onExit: hasValidSize ? (_) => setState(() => _isHovered = false) : null,
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: widget.onMenuTap,
              child: AnimatedContainer(
                duration: AppConstants.durationFast,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: _isHovered ? AppColors.primaryGradient : null,
                  color: _isHovered ? null : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _isHovered 
                        ? AppColors.primary.withValues(alpha: 0.5)
                        : AppColors.borderGlass.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  boxShadow: _isHovered 
                      ? AppColors.glowShadow(intensity: 0.3)
                      : [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                transform: Matrix4.compose(
                  vm.Vector3(0.0, _isHovered ? -1.0 : 0.0, 0.0),
                  vm.Quaternion.identity(),
                  vm.Vector3(_isHovered ? 1.05 : 1.0, _isHovered ? 1.05 : 1.0, 1.0),
                ),
                child: Icon(
                  Icons.menu_rounded,
                  color: _isHovered ? Colors.white : AppColors.primary,
                  size: 24,
                ),
              ),
            ),
          );
        },
      );
    }
    
    // En desktop, mostrar botón "PROBAR DEMO"
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasValidSize = constraints.maxWidth > 0;
        
        // Padding y texto adaptativo según el tamaño de pantalla
        final horizontalPadding = widget.isTablet ? 16.0 : 24.0;
        final verticalPadding = widget.isTablet ? 10.0 : 12.0;
        final buttonText = widget.isTablet ? 'DEMO' : 'PROBAR DEMO';
        final fontSize = widget.isTablet ? 13.0 : null;
        
        return MouseRegion(
          onEnter: hasValidSize ? (_) => setState(() => _isHovered = true) : null,
          onExit: hasValidSize ? (_) => setState(() => _isHovered = false) : null,
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => context.go(AppConstants.routeDemo),
            child: AnimatedContainer(
              duration: AppConstants.durationFast,
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              decoration: BoxDecoration(
                gradient: _isHovered ? AppColors.primaryGradient : null,
                color: _isHovered ? null : AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              transform: Matrix4.translationValues(0.0, _isHovered ? -2.0 : 0.0, 0.0),
              child: Text(
                buttonText,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.background,
                      fontWeight: FontWeight.w700,
                      fontSize: fontSize,
                    ),
              ),
            ),
          ),
        );
      },
    );
  }
}
