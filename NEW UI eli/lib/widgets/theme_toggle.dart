import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class ThemeToggle extends StatefulWidget {
  const ThemeToggle({Key? key}) : super(key: key);

  @override
  State<ThemeToggle> createState() => _ThemeToggleState();
}

class _ThemeToggleState extends State<ThemeToggle> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;

    return GlassCard(
      isDarkMode: isDarkMode,
      child: InkWell(
        onTap: () {
          _rotationController.forward(from: 0.0);
          context.read<ThemeProvider>().toggleTheme();
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: RotationTransition(
            turns: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
            ),
            child: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              size: 24,
              color: isDarkMode ? AppTheme.neonCyan : AppTheme.accentBlue,
            ),
          ),
        ),
      ),
    );
  }
}
