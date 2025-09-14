import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:board_game_moongi/src/core/game/player.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = TicTacToeController(
      gameMode: widget.gameMode,
      humanPlayer: Player(
        id: 'human',
        name: 'Player',
        type: PlayerType.human,
      ),
      aiPlayer: Player(
        id: 'ai',
        name: 'AI',
        type: PlayerType.ai,
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
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tic Tac Toe'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _controller.resetGame(),
            ),
          ],
        ),
        body: Consumer<TicTacToeController>(
          builder: (context, controller, child) {
            return Column(
              children: [
                _buildGameStatus(controller.state),
                Expanded(
                  child: Center(
                    child: _buildGameBoard(controller),
                  ),
                ),
                _buildGameControls(controller),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGameStatus(TicTacToeState state) {
    String statusText;
    Color statusColor;

    if (state.status == GameStatus.finished) {
      final winner = state.getWinner();
      if (winner != null) {
        final winningPlayer = winner == 'X' ? 'Player' : 'AI';
        statusText = '$winningPlayer wins!';
        statusColor = AppTheme.successColor;
      } else {
        statusText = 'It\'s a draw!';
        statusColor = AppTheme.warningColor;
      }
    } else if (state.status == GameStatus.playing) {
      final currentPlayer = state.currentPlayer?.name ?? 'Player';
      statusText = '$currentPlayer\'s turn';
      statusColor = AppTheme.primaryColor;
    } else {
      statusText = 'Game not started';
      statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: statusColor,
        ),
        textAlign: TextAlign.center,
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildGameBoard(TicTacToeController controller) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          final row = index ~/ 3;
          final col = index % 3;
          final cellValue = controller.state.board[row][col];
          
          return GestureDetector(
            onTap: () => _handleCellTap(controller, row, col),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: 300.ms,
                  child: cellValue != null
                      ? Text(
                          cellValue,
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: cellValue == 'X' 
                                ? AppTheme.primaryColor 
                                : AppTheme.secondaryColor,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameControls(TicTacToeController controller) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: () => controller.resetGame(),
            icon: const Icon(Icons.refresh),
            label: const Text('New Game'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home),
            label: const Text('Main Menu'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCellTap(TicTacToeController controller, int row, int col) {
    if (controller.state.status != GameStatus.playing) {
      controller.startGame();
    }
    
    final move = {'row': row, 'col': col};
    controller.makeMove(move);
  }
}
