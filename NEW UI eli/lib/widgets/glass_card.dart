import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final bool isDarkMode;
  final VoidCallback? onTap;

  const GlassCard({
    Key? key,
    required this.child,
    required this.isDarkMode,
    this.onTap,
  }) : super(key: key);

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isDarkMode
                  ? AppTheme.neonCyan.withOpacity(0.3)
                  : AppTheme.accentBlue.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isDarkMode
                    ? AppTheme.neonCyan.withOpacity(0.1)
                    : AppTheme.accentBlue.withOpacity(0.05),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.isDarkMode
                      ? AppTheme.darkGlass
                      : AppTheme.lightGlass,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
