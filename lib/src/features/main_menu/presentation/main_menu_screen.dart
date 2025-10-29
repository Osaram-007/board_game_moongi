import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:board_game_moongi/src/core/theme/app_theme.dart';
import 'package:board_game_moongi/src/core/services/database_service.dart';
import 'package:board_game_moongi/src/features/profile/data/models/player_model.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  PlayerModel? _currentPlayer;

  @override
  void initState() {
    super.initState();
    _loadCurrentPlayer();
  }

  Future<void> _loadCurrentPlayer() async {
    final databaseService = context.read<DatabaseService>();
    final player = await databaseService.getCurrentPlayer();
    setState(() {
      _currentPlayer = player;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6366F1),
              const Color(0xFF8B5CF6),
              const Color(0xFFEC4899),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background circles
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                  .scale(duration: 3000.ms, begin: const Offset(1, 1), end: const Offset(1.2, 1.2))
                  .then()
                  .scale(duration: 3000.ms, begin: const Offset(1.2, 1.2), end: const Offset(1, 1)),
            ),
            Positioned(
              bottom: -150,
              left: -150,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                  .scale(duration: 4000.ms, begin: const Offset(1, 1), end: const Offset(1.3, 1.3))
                  .then()
                  .scale(duration: 4000.ms, begin: const Offset(1.3, 1.3), end: const Offset(1, 1)),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildGameCards(),
                            const SizedBox(height: 32),
                            _buildActionButtons(),
                          ],
                        ),
                      ),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Board Game',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      letterSpacing: -0.5,
                    ),
              ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3),
              Text(
                'Moongi',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w300,
                      fontSize: 28,
                      letterSpacing: -0.5,
                    ),
              ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideX(begin: -0.3),
            ],
          ),
          GestureDetector(
            onTap: () => context.go('/profile'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.25),
                    Colors.white.withOpacity(0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.accentColor,
                          AppTheme.accentColor.withOpacity(0.7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentColor.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.transparent,
                      child: Text(
                        _currentPlayer?.name.substring(0, 1).toUpperCase() ?? '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _currentPlayer?.name ?? 'Guest',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideX(begin: 0.3).scale(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildGameCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _GameCard(
            title: 'Tic Tac Toe',
            description: 'Classic 3x3 grid game',
            icon: Icons.tag,
            emoji: '#',
            gradient: LinearGradient(
              colors: [
                const Color(0xFF10B981).withOpacity(0.3),
                const Color(0xFF059669).withOpacity(0.2),
              ],
            ),
            onTap: () => context.go('/tic-tac-toe', extra: 'vs-ai'),
          ).animate().fadeIn(delay: 600.ms, duration: 800.ms).slideY(begin: 0.3).scale(delay: 600.ms),
          // Snakes & Ladders - Hidden
          // _GameCard(
          //   title: 'Snakes & Ladders',
          //   description: 'Race to the finish line',
          //   icon: Icons.trending_up,
          //   emoji: '🐍',
          //   gradient: LinearGradient(
          //     colors: [
          //       const Color(0xFFF59E0B).withOpacity(0.3),
          //       const Color(0xFFD97706).withOpacity(0.2),
          //     ],
          //   ),
          //   onTap: () => context.go('/snakes-ladders', extra: 'vs-ai'),
          // ).animate().fadeIn(delay: 800.ms, duration: 800.ms).slideY(begin: 0.3).scale(delay: 800.ms),
          // Ludo - Hidden
          // _GameCard(
          //   title: 'Ludo',
          //   description: 'Strategic board game',
          //   icon: Icons.casino_outlined,
          //   emoji: '🎲',
          //   gradient: LinearGradient(
          //     colors: [
          //       const Color(0xFFEF4444).withOpacity(0.3),
          //       const Color(0xFFDC2626).withOpacity(0.2),
          //     ],
          //   ),
          //   onTap: () => context.go('/ludo', extra: 'vs-ai'),
          // ).animate().fadeIn(delay: 1000.ms, duration: 800.ms).slideY(begin: 0.3).scale(delay: 1000.ms),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _buildActionButton(
              onPressed: () => context.go('/profile'),
              icon: Icons.person,
              label: 'Manage Profile',
              delay: 1200,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              onPressed: () => _showGameModeDialog(),
              icon: Icons.people,
              label: 'Multiplayer',
              delay: 1400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required int delay,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: delay.ms, duration: 600.ms).scale(delay: delay.ms);
  }

  void _showGameModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.3),
                    AppTheme.secondaryColor.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.gamepad, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 12),
            const Text('Select Game Mode'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGameModeOption(
              icon: Icons.computer,
              title: 'VS Computer',
              subtitle: 'Play against AI',
              color: AppTheme.primaryColor,
              onTap: () {
                Navigator.pop(context);
                context.go('/tic-tac-toe', extra: 'vs-ai');
              },
            ),
            const SizedBox(height: 12),
            _buildGameModeOption(
              icon: Icons.people,
              title: 'Local Multiplayer',
              subtitle: 'Play with a friend',
              color: AppTheme.successColor,
              onTap: () {
                Navigator.pop(context);
                context.go('/tic-tac-toe', extra: 'multiplayer');
              },
            ),
            const SizedBox(height: 12),
            _buildGameModeOption(
              icon: Icons.wifi,
              title: 'Online Multiplayer',
              subtitle: 'Coming soon',
              color: AppTheme.warningColor,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Online multiplayer coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              isDisabled: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameModeOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isDisabled = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(isDisabled ? 0.05 : 0.1),
                color.withOpacity(isDisabled ? 0.02 : 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(isDisabled ? 0.2 : 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(isDisabled ? 0.1 : 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isDisabled ? Colors.grey : color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDisabled ? Colors.grey : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDisabled ? Colors.grey : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isDisabled ? Icons.lock_outline : Icons.arrow_forward_ios,
                color: isDisabled ? Colors.grey : color,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final String emoji;
  final Gradient gradient;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.emoji,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) {
        setState(() => _isHovered = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 0.98 : 1.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.25 : 0.15),
                blurRadius: _isHovered ? 20 : 15,
                offset: Offset(0, _isHovered ? 8 : 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.emoji,
                    style: const TextStyle(
                      fontSize: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.6),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
