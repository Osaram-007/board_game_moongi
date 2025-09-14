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
              AppTheme.primaryColor,
              AppTheme.secondaryColor,
              AppTheme.accentColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildGameCards(),
                        const SizedBox(height: 40),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
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
                    ),
              ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3),
              Text(
                'Moongi',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w300,
                    ),
              ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideX(begin: -0.3),
            ],
          ),
          GestureDetector(
            onTap: () => context.go('/profile'),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.accentColor,
                    child: Text(
                      _currentPlayer?.name.substring(0, 1).toUpperCase() ?? '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _currentPlayer?.name ?? 'Guest',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideX(begin: 0.3),
        ],
      ),
    );
  }

  Widget _buildGameCards() {
    return Column(
      children: [
        _GameCard(
          title: 'Tic Tac Toe',
          description: 'Classic 3x3 grid game',
          icon: Icons.grid_3x3,
          color: AppTheme.successColor,
          onTap: () => context.go('/tic-tac-toe', extra: 'vs-ai'),
        ).animate().fadeIn(delay: 600.ms, duration: 800.ms).slideY(begin: 0.3),
        const SizedBox(height: 16),
        _GameCard(
          title: 'Snakes & Ladders',
          description: 'Race to the finish line',
          icon: Icons.timeline,
          color: AppTheme.warningColor,
          onTap: () => context.go('/snakes-ladders', extra: 'vs-ai'),
        ).animate().fadeIn(delay: 800.ms, duration: 800.ms).slideY(begin: 0.3),
        const SizedBox(height: 16),
        _GameCard(
          title: 'Ludo',
          description: 'Strategic board game',
          icon: Icons.casino,
          color: AppTheme.errorColor,
          onTap: () => context.go('/ludo', extra: 'vs-ai'),
        ).animate().fadeIn(delay: 1000.ms, duration: 800.ms).slideY(begin: 0.3),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () => context.go('/profile'),
          icon: const Icon(Icons.person_add),
          label: const Text('Manage Profile'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.2),
            foregroundColor: Colors.white,
          ),
        ).animate().fadeIn(delay: 1200.ms, duration: 600.ms),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => _showGameModeDialog(),
          icon: const Icon(Icons.people),
          label: const Text('Multiplayer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.2),
            foregroundColor: Colors.white,
          ),
        ).animate().fadeIn(delay: 1400.ms, duration: 600.ms),
      ],
    );
  }

  void _showGameModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Game Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.computer),
              title: const Text('VS Computer'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Local Multiplayer'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.wifi),
              title: const Text('Online Multiplayer'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
