import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_colors.dart';
import '../../core/config/app_constants.dart';
import '../../core/providers/head_tracking_provider.dart';
import 'navbar.dart';

/// Layout principal que envuelve todas las páginas
/// Incluye Navbar fijo arriba y contenido scrollable
/// El Footer debe ser incluido al final de cada vista dentro de su scroll
class MainLayout extends ConsumerStatefulWidget {
  final Widget child;

  const MainLayout({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openEndDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      // ✅ Captura el movimiento del mouse a nivel GLOBAL (incluyendo el AppBar)
      onHover: (event) {
        ref.read(globalPointerPositionProvider.notifier).state = event.position;
      },
      // ✅ NO limpiar el provider cuando el mouse sale - mantener la última posición
      // Esto evita que el bot vuelva al centro bruscamente cuando el mouse sale del área
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.background,
        endDrawer: const _FuturisticNavigationDrawer(),
        body: Column(
          children: [
            // Navbar fijo arriba (siempre visible)
            Navbar(onMenuTap: _openEndDrawer),
            // Contenido scrollable (cada vista maneja su propio scroll e incluye el footer)
            Expanded(child: widget.child),
          ],
        ),
      ),
    );
  }
}

/// Drawer de navegación lateral con diseño futurista
class _FuturisticNavigationDrawer extends StatefulWidget {
  const _FuturisticNavigationDrawer();

  @override
  State<_FuturisticNavigationDrawer> createState() => _FuturisticNavigationDrawerState();
}

class _FuturisticNavigationDrawerState extends State<_FuturisticNavigationDrawer> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    
    final navItems = [
      _NavItem(
        icon: Icons.home_rounded,
        label: 'Home',
        route: AppConstants.routeHome,
        description: 'Inicio',
      ),
      _NavItem(
        icon: FontAwesomeIcons.robot,
        label: 'Bot',
        route: AppConstants.routeBot,
        description: 'Conoce tu Bot',
        useFaIcon: true,
      ),
      _NavItem(
        icon: Icons.factory_rounded,
        label: 'Factory',
        route: AppConstants.routeFactory,
        description: 'Crea tu fábrica',
      ),
      _NavItem(
        icon: Icons.school_rounded,
        label: 'Tutorial',
        route: AppConstants.routeTutorial,
        description: 'Aprende a usar',
      ),
      _NavItem(
        icon: Icons.play_circle_rounded,
        label: 'Demo',
        route: AppConstants.routeDemo,
        description: 'Prueba gratis',
        isHighlighted: true,
      ),
    ];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surface.withValues(alpha: 0.95),
                AppColors.background.withValues(alpha: 0.98),
              ],
            ),
            border: Border(
              left: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(-5, 0),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header del Drawer
                _DrawerHeader(),
                
                const SizedBox(height: 24),
                
                // Items de navegación
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: navItems.length,
                    itemBuilder: (context, index) {
                      final item = navItems[index];
                      final isSelected = currentRoute == item.route;
                      
                      return _DrawerNavItem(
                        item: item,
                        isSelected: isSelected,
                        index: index,
                      ).animate().fadeIn(
                        duration: 300.ms,
                        delay: (50 * index).ms,
                      ).slideX(
                        begin: 0.3,
                        end: 0,
                        duration: 400.ms,
                        delay: (50 * index).ms,
                      );
                    },
                  ),
                ),
                
                // Footer del Drawer
                const _DrawerFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Header del drawer con logo y botón de cierre
class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderGlass.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo y texto
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: AppColors.primaryGradient,
                    boxShadow: AppColors.glowShadow(intensity: 0.3),
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.robot,
                    color: AppColors.background,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                        child: Text(
                          'BOTLODE',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                color: Colors.white,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'Navegación',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textTertiary,
                              letterSpacing: 1,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Botón cerrar
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              customBorder: const CircleBorder(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.borderGlass.withValues(alpha: 0.5),
                  ),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Item de navegación del drawer
class _DrawerNavItem extends StatefulWidget {
  final _NavItem item;
  final bool isSelected;
  final int index;

  const _DrawerNavItem({
    required this.item,
    required this.isSelected,
    required this.index,
  });

  @override
  State<_DrawerNavItem> createState() => _DrawerNavItemState();
}

class _DrawerNavItemState extends State<_DrawerNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isHighlighted = widget.item.isHighlighted && !widget.isSelected;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            context.go(widget.item.route);
            Navigator.of(context).pop();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: widget.isSelected
                  ? AppColors.primaryGradient
                  : isHighlighted
                      ? LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.15),
                            AppColors.primaryGlow.withValues(alpha: 0.15),
                          ],
                        )
                      : null,
              color: !widget.isSelected && !isHighlighted
                  ? (_isHovered
                      ? AppColors.surface.withValues(alpha: 0.5)
                      : Colors.transparent)
                  : null,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isSelected
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : isHighlighted
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : (_isHovered
                            ? AppColors.borderGlass.withValues(alpha: 0.3)
                            : Colors.transparent),
                width: widget.isSelected ? 1.5 : 1,
              ),
              boxShadow: widget.isSelected || (isHighlighted && _isHovered)
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            transform: Matrix4.identity()
              ..translate(
                _isHovered ? 4.0 : 0.0,
                0.0,
              ),
            child: Row(
              children: [
                // Icono
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : (_isHovered
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.transparent),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: widget.item.useFaIcon
                      ? FaIcon(
                          widget.item.icon,
                          color: widget.isSelected
                              ? Colors.white
                              : (isHighlighted || _isHovered
                                  ? AppColors.primary
                                  : AppColors.textSecondary),
                          size: 22,
                        )
                      : Icon(
                          widget.item.icon,
                          color: widget.isSelected
                              ? Colors.white
                              : (isHighlighted || _isHovered
                                  ? AppColors.primary
                                  : AppColors.textSecondary),
                          size: 22,
                        ),
                ),
                
                const SizedBox(width: 16),
                
                // Textos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.label.toUpperCase(),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: widget.isSelected
                                  ? Colors.white
                                  : (isHighlighted || _isHovered
                                      ? AppColors.primary
                                      : AppColors.textPrimary),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.item.description,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: widget.isSelected
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : AppColors.textTertiary,
                            ),
                      ),
                    ],
                  ),
                ),
                
                // Indicador de selección
                if (widget.isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ).animate(onPlay: (controller) => controller.repeat())
                    .fade(duration: 1000.ms, begin: 0.5, end: 1.0)
                else if (isHighlighted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      'NUEVO',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Footer del drawer con información adicional
class _DrawerFooter extends StatelessWidget {
  const _DrawerFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.borderGlass.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Center(
        child: Text(
          '© 2026 BotLode Suite',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textTertiary.withValues(alpha: 0.6),
                fontSize: 11,
              ),
        ),
      ),
    );
  }
}


/// Modelo de datos para items de navegación
class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  final String description;
  final bool isHighlighted;
  final bool useFaIcon;

  _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.description,
    this.isHighlighted = false,
    this.useFaIcon = false,
  });
}
