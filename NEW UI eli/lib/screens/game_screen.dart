import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/game_board.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<String> board;
  late bool isXNext;
  late String gameStatus;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    board = List.filled(9, '');
    isXNext = true;
    gameStatus = 'X\'s Turn';
  }

  String? _calculateWinner() {
    const List<List<int>> lines = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var line in lines) {
      if (board[line[0]].isNotEmpty &&
          board[line[0]] == board[line[1]] &&
          board[line[0]] == board[line[2]]) {
        return board[line[0]];
      }
    }
    return null;
  }

  void _handleCellTap(int index) {
    if (board[index].isEmpty && _calculateWinner() == null) {
      setState(() {
        board[index] = isXNext ? 'X' : 'O';
        isXNext = !isXNext;

        final winner = _calculateWinner();
        if (winner != null) {
          gameStatus = '$winner Wins!';
        } else if (board.every((cell) => cell.isNotEmpty)) {
          gameStatus = 'Draw!';
        } else {
          gameStatus = '${isXNext ? 'X' : 'O'}\'s Turn';
        }
      });
    }
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
                    Color.lerp(AppTheme.darkBg, AppTheme.neonBlue, 0.1)!,
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.lightBg,
                    Color.lerp(AppTheme.lightBg, AppTheme.accentTeal, 0.05)!,
                  ],
                ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'NEXUS',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 32),

                // Game Status
                GlassCard(
                  isDarkMode: isDarkMode,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    child: Column(
                      children: [
                        Text(
                          gameStatus,
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Make your move',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Game Board
                GameBoard(
                  board: board,
                  onCellTap: _handleCellTap,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: GlassCard(
                        isDarkMode: isDarkMode,
                        child: InkWell(
                          onTap: () {
                            setState(_initializeGame);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'New Game',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlassCard(
                        isDarkMode: isDarkMode,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'Menu',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
