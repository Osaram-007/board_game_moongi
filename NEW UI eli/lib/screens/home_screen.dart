import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/theme_toggle.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late List<AnimationController> _cardControllers;
  late List<Animation<double>> _cardAnimations;

  @override
  void initState() {
    super.initState();
    _cardControllers = List.generate(
      3,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600 + (index * 150)),
        vsync: this,
      ),
    );

    _cardAnimations = _cardControllers
        .map((controller) => Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeOut),
            ))
        .toList();

    for (var controller in _cardControllers) {
      controller.forward();
    }
  }

  @override
  void dispose() {
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.darkBg,
                    Color.lerp(AppTheme.darkBg, AppTheme.neonPurple, 0.1)!,
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.lightBg,
                    Color.lerp(AppTheme.lightBg, AppTheme.accentBlue, 0.05)!,
                  ],
                ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Theme Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NEXUS',
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                          Text(
                            'Tic Tac Toe',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const ThemeToggle(),
                    ],
                  ),
                  const SizedBox(height: 48),

                  // Game Cards
                  ..._buildGameCards(context, isDarkMode),

                  const SizedBox(height: 48),

                  // Bottom Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildGlassButton(
                          context,
                          'Profile',
                          Icons.person,
                          isDarkMode,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildGlassButton(
                          context,
                          'Multiplayer',
                          Icons.people,
                          isDarkMode,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGameCards(BuildContext context, bool isDarkMode) {
    final games = [
      {
        'title': 'Tic Tac Toe',
        'description': 'Classic 3x3 grid game',
        'icon': '⊞',
      },
      {
        'title': 'Snakes & Ladders',
        'description': 'Race to the finish line',
        'icon': '↗',
      },
      {
        'title': 'Ludo',
        'description': 'Strategic board game',
        'icon': '⚲',
      },
    ];

    return List.generate(
      games.length,
      (index) => FadeTransition(
        opacity: _cardAnimations[index],
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(_cardAnimations[index]),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: GlassCard(
              isDarkMode: isDarkMode,
              child: InkWell(
                onTap: () {
                  if (index == 0) {
                    Navigator.pushNamed(context, '/game');
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        games[index]['icon'] as String,
                        style: const TextStyle(fontSize: 48),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        games[index]['title'] as String,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        games[index]['description'] as String,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton(
    BuildContext context,
    String label,
    IconData icon,
    bool isDarkMode,
  ) {
    return GlassCard(
      isDarkMode: isDarkMode,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
