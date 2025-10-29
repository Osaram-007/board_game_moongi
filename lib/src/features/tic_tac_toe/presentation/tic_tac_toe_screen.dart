import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:board_game_moongi/src/core/game/player.dart';
import 'package:board_game_moongi/src/core/game/game_state.dart';
import 'package:board_game_moongi/src/core/theme/app_theme.dart';
import 'package:board_game_moongi/src/features/tic_tac_toe/domain/tic_tac_toe_controller.dart';
import 'package:board_game_moongi/src/features/tic_tac_toe/data/models/tic_tac_toe_state.dart';

class TicTacToeScreen extends StatefulWidget {
  final String gameMode;

  const TicTacToeScreen({super.key, required this.gameMode});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  late TicTacToeController _controller;
  int _player1Wins = 0;
  int _player2Wins = 0;
  int _draws = 0;
  List<int>? _winningLine;

  @override
  void initState() {
    super.initState();
    final isMultiplayer = widget.gameMode == 'multiplayer';
    _controller = TicTacToeController(
      gameMode: widget.gameMode,
      player1: Player(
        id: 'player1',
        name: isMultiplayer ? 'Player 1' : 'Player',
        type: PlayerType.human,
      ),
      player2: Player(
        id: 'player2',
        name: isMultiplayer ? 'Player 2' : 'AI',
        type: isMultiplayer ? PlayerType.human : PlayerType.ai,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            'Tic Tac Toe',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => _resetGame(),
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF1a1a2e),
                      const Color(0xFF16213e),
                      const Color(0xFF0f3460),
                    ]
                  : [
                      AppTheme.primaryColor.withOpacity(0.8),
                      AppTheme.secondaryColor.withOpacity(0.8),
                      AppTheme.accentColor.withOpacity(0.6),
                    ],
            ),
          ),
          child: SafeArea(
            child: Consumer<TicTacToeController>(
              builder: (context, controller, child) {
                final isMultiplayer = widget.gameMode == 'multiplayer';
                return Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildScoreBoard(),
                    if (!isMultiplayer) ...[
                      const SizedBox(height: 12),
                      _buildDifficultySelector(controller),
                    ],
                    const SizedBox(height: 12),
                    _buildGameStatus(controller.state),
                    Expanded(
                      child: Center(
                        child: _buildGameBoard(controller),
                      ),
                    ),
                    _buildGameControls(controller),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultySelector(TicTacToeController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDifficultyButton(
              label: 'Easy',
              icon: Icons.sentiment_satisfied,
              difficulty: AIDifficulty.easy,
              isSelected: controller.currentDifficulty == AIDifficulty.easy,
              onTap: () => _changeDifficulty(controller, AIDifficulty.easy),
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildDifficultyButton(
              label: 'Hard',
              icon: Icons.psychology,
              difficulty: AIDifficulty.hard,
              isSelected: controller.currentDifficulty == AIDifficulty.hard,
              onTap: () => _changeDifficulty(controller, AIDifficulty.hard),
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildDifficultyButton(
              label: 'Extreme',
              icon: Icons.whatshot,
              difficulty: AIDifficulty.extreme,
              isSelected: controller.currentDifficulty == AIDifficulty.extreme,
              onTap: () => _changeDifficulty(controller, AIDifficulty.extreme),
              color: Colors.red,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0, delay: 100.ms);
  }

  Widget _buildDifficultyButton({
    required String label,
    required IconData icon,
    required AIDifficulty difficulty,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    color.withOpacity(0.8),
                    color.withOpacity(0.6),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: Colors.white.withOpacity(0.5), width: 2)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white60,
              size: isSelected ? 24 : 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: isSelected ? 13 : 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changeDifficulty(TicTacToeController controller, AIDifficulty difficulty) {
    if (controller.state.status == GameStatus.playing) {
      // Show dialog to confirm difficulty change during game
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Change Difficulty?'),
          content: const Text(
            'Changing difficulty will reset the current game. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.setDifficulty(difficulty);
                controller.resetGame();
              },
              child: const Text('Change'),
            ),
          ],
        ),
      );
    } else {
      controller.setDifficulty(difficulty);
    }
  }

  Widget _buildScoreBoard() {
    final isMultiplayer = widget.gameMode == 'multiplayer';
    final player1Label = isMultiplayer ? 'Player 1 (X)' : 'Player (X)';
    final player2Label = isMultiplayer ? 'Player 2 (O)' : 'AI (O)';
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreItem(player1Label, _player1Wins, AppTheme.primaryColor),
          Container(
            width: 2,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.5),
                  Colors.white.withOpacity(0.1),
                ],
              ),
            ),
          ),
          _buildScoreItem('Draws', _draws, AppTheme.warningColor),
          Container(
            width: 2,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.5),
                  Colors.white.withOpacity(0.1),
                ],
              ),
            ),
          ),
          _buildScoreItem(player2Label, _player2Wins, AppTheme.secondaryColor),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildScoreItem(String label, int score, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Text(
            score.toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameStatus(TicTacToeState state) {
    String statusText;
    IconData statusIcon;
    Color statusColor;
    final isMultiplayer = widget.gameMode == 'multiplayer';

    if (state.status == GameStatus.finished) {
      final winner = state.getWinner();
      if (winner != null) {
        final winningPlayer = winner == 'X' 
            ? (isMultiplayer ? 'Player 1' : 'Player') 
            : (isMultiplayer ? 'Player 2' : 'AI');
        statusText = '$winningPlayer Wins! 🎉';
        statusIcon = Icons.emoji_events;
        statusColor = AppTheme.successColor;
      } else {
        statusText = 'It\'s a Draw!';
        statusIcon = Icons.handshake;
        statusColor = AppTheme.warningColor;
      }
    } else if (state.status == GameStatus.playing) {
      final currentPlayer = state.currentPlayer?.name ?? (isMultiplayer ? 'Player 1' : 'Player');
      final symbol = state.currentPlayer == _controller.player1 ? 'X' : 'O';
      statusText = '$currentPlayer\'s Turn ($symbol)';
      statusIcon = state.currentPlayer == _controller.player1 ? Icons.person : (isMultiplayer ? Icons.person_outline : Icons.smart_toy);
      statusColor = state.currentPlayer == _controller.player1 ? AppTheme.primaryColor : AppTheme.secondaryColor;
    } else {
      statusText = 'Tap to Start';
      statusIcon = Icons.play_circle_outline;
      statusColor = Colors.white70;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.3),
            statusColor.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(statusIcon, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Text(
            statusText,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).scale(delay: 100.ms);
  }

  Widget _buildGameBoard(TicTacToeController controller) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = (screenWidth * 0.85).clamp(280.0, 380.0);
    
    return Container(
      width: boardSize,
      height: boardSize,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          final row = index ~/ 3;
          final col = index % 3;
          final cellValue = controller.state.board[row][col];
          final isWinningCell = _winningLine?.contains(index) ?? false;
          
          return _buildCell(controller, row, col, cellValue, isWinningCell, index);
        },
      ),
    ).animate().scale(duration: 500.ms, curve: Curves.elasticOut);
  }

  Widget _buildCell(TicTacToeController controller, int row, int col, String? cellValue, bool isWinningCell, int index) {
    return GestureDetector(
      onTap: () => _handleCellTap(controller, row, col),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isWinningCell
                ? [
                    AppTheme.successColor.withOpacity(0.6),
                    AppTheme.successColor.withOpacity(0.3),
                  ]
                : cellValue != null
                    ? [
                        Colors.white.withOpacity(0.25),
                        Colors.white.withOpacity(0.15),
                      ]
                    : [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.05),
                      ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isWinningCell
                ? AppTheme.successColor.withOpacity(0.8)
                : Colors.white.withOpacity(0.3),
            width: isWinningCell ? 3 : 1.5,
          ),
          boxShadow: isWinningCell
              ? [
                  BoxShadow(
                    color: AppTheme.successColor.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : cellValue != null
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: 300.ms,
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: RotationTransition(
                  turns: animation,
                  child: child,
                ),
              );
            },
            child: cellValue != null
                ? Text(
                    cellValue,
                    key: ValueKey('$row-$col-$cellValue'),
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: cellValue == 'X'
                          ? Colors.white
                          : Colors.white.withOpacity(0.95),
                      shadows: [
                        Shadow(
                          color: cellValue == 'X'
                              ? AppTheme.primaryColor
                              : AppTheme.secondaryColor,
                          blurRadius: 15,
                        ),
                      ],
                    ),
                  ).animate().scale(duration: 300.ms, curve: Curves.elasticOut)
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  Widget _buildGameControls(TicTacToeController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildControlButton(
              onPressed: () => _resetGame(),
              icon: Icons.refresh,
              label: 'New Game',
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.8),
                  AppTheme.secondaryColor.withOpacity(0.8),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildControlButton(
              onPressed: () => context.go('/'),
              icon: Icons.home,
              label: 'Menu',
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Gradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0);
  }

  void _handleCellTap(TicTacToeController controller, int row, int col) {
    if (controller.state.status != GameStatus.playing) {
      controller.startGame();
    }
    
    final move = {'row': row, 'col': col};
    controller.makeMove(move);
    
    // Check for winner and update winning line
    if (controller.state.status == GameStatus.finished) {
      _updateScoreAndWinningLine(controller.state);
    }
  }

  void _resetGame() {
    setState(() {
      _winningLine = null;
    });
    _controller.resetGame();
  }

  void _updateScoreAndWinningLine(TicTacToeState state) {
    final winner = state.getWinner();
    
    setState(() {
      if (winner != null) {
        if (winner == 'X') {
          _player1Wins++;
        } else {
          _player2Wins++;
        }
        _winningLine = _getWinningLine(state);
      } else if (state.isBoardFull()) {
        _draws++;
      }
    });
  }

  List<int>? _getWinningLine(TicTacToeState state) {
    final winner = state.getWinner();
    if (winner == null) return null;

    // Check rows
    for (int i = 0; i < 3; i++) {
      if (state.board[i][0] == winner &&
          state.board[i][1] == winner &&
          state.board[i][2] == winner) {
        return [i * 3, i * 3 + 1, i * 3 + 2];
      }
    }

    // Check columns
    for (int j = 0; j < 3; j++) {
      if (state.board[0][j] == winner &&
          state.board[1][j] == winner &&
          state.board[2][j] == winner) {
        return [j, j + 3, j + 6];
      }
    }

    // Check diagonals
    if (state.board[0][0] == winner &&
        state.board[1][1] == winner &&
        state.board[2][2] == winner) {
      return [0, 4, 8];
    }

    if (state.board[0][2] == winner &&
        state.board[1][1] == winner &&
        state.board[2][0] == winner) {
      return [2, 4, 6];
    }

    return null;
  }
}
