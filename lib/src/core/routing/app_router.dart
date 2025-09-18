import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:board_game_moongi/src/features/main_menu/presentation/main_menu_screen.dart';
import 'package:board_game_moongi/src/features/profile/presentation/profile_screen.dart';
import 'package:board_game_moongi/src/features/tic_tac_toe/presentation/tic_tac_toe_screen.dart';
import 'package:board_game_moongi/src/features/snakes_ladders/presentation/snakes_ladders_screen.dart';
import 'package:board_game_moongi/src/features/ludo/presentation/new_ludo_screen.dart';
import 'package:board_game_moongi/src/core/game/game_state.dart';
import 'package:board_game_moongi/src/features/ludo/data/models/new_ludo_state.dart';

class AppRouter {
  static final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: 'mainMenu',
        builder: (context, state) => const MainMenuScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/tic-tac-toe',
        name: 'ticTacToe',
        builder: (context, state) {
          final mode = state.extra as String? ?? 'vs-ai';
          return TicTacToeScreen(gameMode: mode);
        },
      ),
      GoRoute(
        path: '/snakes-ladders',
        name: 'snakesLadders',
        builder: (context, state) {
          final mode = state.extra as String? ?? 'vs-ai';
          return SnakesLaddersScreen(gameMode: mode);
        },
      ),
      GoRoute(
        path: '/ludo',
        name: 'ludo',
        builder: (context, state) {
          String modeStr = 'vs-ai';
          String difficultyStr = 'medium';
          
          if (state.extra is Map<String, dynamic>) {
            final params = state.extra as Map<String, dynamic>;
            modeStr = params['gameMode'] as String? ?? 'vs-ai';
            difficultyStr = params['difficulty'] as String? ?? 'medium';
          } else if (state.extra is String) {
            modeStr = state.extra as String;
          }
          
          GameMode gameMode = modeStr == 'multiplayer' ? GameMode.multiPlayer : GameMode.singlePlayer;
          DifficultyLevel difficulty = DifficultyLevel.values.firstWhere(
            (d) => d.name == difficultyStr,
            orElse: () => DifficultyLevel.medium,
          );
          
          return NewLudoScreen(gameMode: gameMode, difficulty: difficulty);
        },
      ),
    ],
    errorBuilder: (context, state) => const ErrorScreen(),
  );
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Page not found'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
