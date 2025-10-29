import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import 'package:board_game_moongi/src/core/game/player.dart';
import 'package:board_game_moongi/src/core/game/game_state.dart';
import 'package:board_game_moongi/src/core/theme/app_theme.dart';
import 'package:board_game_moongi/src/features/snakes_ladders/domain/snakes_ladders_controller.dart';
import 'package:board_game_moongi/src/features/snakes_ladders/data/models/snakes_ladders_state.dart';

class SnakesLaddersScreen extends StatefulWidget {
  final String gameMode;

  const SnakesLaddersScreen({super.key, required this.gameMode});

  @override
  State<SnakesLaddersScreen> createState() => _SnakesLaddersScreenState();
}

class _SnakesLaddersScreenState extends State<SnakesLaddersScreen> {
  late SnakesLaddersController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SnakesLaddersController(
      gameMode: widget.gameMode,
      players: [
        Player(
          id: 'player1',
          name: 'Player 1',
          type: PlayerType.human,
        ),
        if (widget.gameMode == 'vs-ai')
          Player(
            id: 'ai',
            name: 'AI',
            type: PlayerType.ai,
          )
        else
          Player(
            id: 'player2',
            name: 'Player 2',
            type: PlayerType.human,
          ),
      ],
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
          title: const Text('Snakes & Ladders'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _controller.resetGame(),
            ),
          ],
        ),
        body: Consumer<SnakesLaddersController>(
          builder: (context, controller, child) {
            return Column(
              children: [
                _buildGameStatus(controller.state),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildGameBoard(controller.state),
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

  Widget _buildGameStatus(SnakesLaddersState state) {
    String statusText;
    Color statusColor;

    if (state.status == GameStatus.finished) {
      final winner = state.players.firstWhere(
        (player) => state.hasPlayerWon(player),
        orElse: () => Player(id: '', name: ''),
      );
      
      if (winner.id.isNotEmpty) {
        statusText = '${winner.name} wins!';
        statusColor = AppTheme.successColor;
      } else {
        statusText = 'Game Over';
        statusColor = AppTheme.errorColor;
      }
    } else if (state.status == GameStatus.playing) {
      statusText = '${state.currentPlayer?.name}\'s turn';
      statusColor = AppTheme.primaryColor;
    } else {
      statusText = 'Tap "Start Game" to begin';
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
      child: Column(
        children: [
          Text(
            statusText,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          if (state.status == GameStatus.playing) ...[
            const SizedBox(height: 8),
            Text(
              'Dice: ${state.currentDiceValue}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryColor,
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildGameBoard(SnakesLaddersState state) {
    return Container(
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
      child: Stack(
        children: [
          // Board grid
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 10,
              childAspectRatio: 1,
            ),
            itemCount: 100,
            itemBuilder: (context, index) {
              final position = _getBoardPosition(index);
              final isSnakeHead = state.snakes.any((snake) => snake.start == position);
              final isSnakeTail = state.snakes.any((snake) => snake.end == position);
              final isLadderStart = state.ladders.any((ladder) => ladder.start == position);
              final isLadderEnd = state.ladders.any((ladder) => ladder.end == position);
              
              Color cellColor = Colors.white;
              if (isSnakeHead) cellColor = Colors.red[100]!;
              if (isSnakeTail) cellColor = Colors.red[50]!;
              if (isLadderStart) cellColor = Colors.green[100]!;
              if (isLadderEnd) cellColor = Colors.green[50]!;
              
              return Container(
                decoration: BoxDecoration(
                  color: cellColor,
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        position.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isLadderStart)
                      const Positioned(
                        bottom: 2,
                        right: 2,
                        child: Icon(Icons.arrow_upward, size: 12, color: Colors.green),
                      ),
                  ],
                ),
              );
            },
          ),
          
          // Snake SVGs
          ..._buildSnakes(state),
          
          // Player tokens
          ..._buildPlayerTokens(state),
        ],
      ),
    );
  }

  List<Widget> _buildSnakes(SnakesLaddersState state) {
    final snakes = <Widget>[];
    
    for (final snake in state.snakes) {
      final startIndex = _getCellIndex(snake.start);
      final endIndex = _getCellIndex(snake.end);
      
      final startRow = startIndex ~/ 10;
      final startCol = startIndex % 10;
      final endRow = endIndex ~/ 10;
      final endCol = endIndex % 10;
      
      // Calculate snake position and rotation
      final startX = startCol * 30.0 + 15;
      final startY = startRow * 30.0 + 15;
      final endX = endCol * 30.0 + 15;
      final endY = endRow * 30.0 + 15;
      
      final deltaX = endX - startX;
      final deltaY = endY - startY;
      final distance = math.sqrt(deltaX * deltaX + deltaY * deltaY);
      final angle = math.atan2(deltaY, deltaX);
      
      snakes.add(
        Positioned(
          left: startX - 15,
          top: startY - 15,
          child: Transform.rotate(
            angle: angle,
            child: SizedBox(
              width: distance,
              height: 30,
              child: SvgPicture.asset(
                'assets/images/snake.svg',
                width: distance,
                height: 30,
                fit: BoxFit.fill,
                colorFilter: ColorFilter.mode(
                  Colors.red.withOpacity(0.8),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    return snakes;
  }

  List<Widget> _buildPlayerTokens(SnakesLaddersState state) {
    final tokens = <Widget>[];
    
    for (int i = 0; i < state.players.length; i++) {
      final player = state.players[i];
      final position = state.getPlayerPosition(player);
      final cellIndex = _getCellIndex(position);
      
      tokens.add(
        Positioned(
          left: _getTokenX(cellIndex, i, state.players.length),
          top: _getTokenY(cellIndex, i, state.players.length),
          child: AnimatedContainer(
            duration: 800.ms,
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _getPlayerColor(i),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                player.name.substring(0, 1),
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
            ),
          ),
        ),
      );
    }
    
    return tokens;
  }

  Widget _buildGameControls(SnakesLaddersController controller) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          if (controller.state.status == GameStatus.waiting) ...[
            ElevatedButton.icon(
              onPressed: () => controller.startGame(),
              icon: const Icon(Icons.play_arrow),
              label: const Text(
                'Start Game',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: AppTheme.successColor,
                foregroundColor: Colors.white,
              ),
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: controller.state.status == GameStatus.playing && !controller.state.isRolling
                  ? controller.rollDice
                  : null,
              icon: const Icon(Icons.casino),
              label: Text(
                controller.state.isRolling ? 'Rolling...' : 'Roll Dice',
                style: const TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => controller.resetGame(),
                icon: const Icon(Icons.refresh),
                label: const Text('New Game'),
              ),
              ElevatedButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home),
                label: const Text('Main Menu'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _getBoardPosition(int index) {
    final row = index ~/ 10;
    final col = index % 10;
    
    if (row % 2 == 0) {
      return 100 - (row * 10 + col);
    } else {
      return 100 - (row * 10 + (9 - col));
    }
  }

  int _getCellIndex(int position) {
    // Convert game position (1-100) to grid index (0-99)
    final adjustedPosition = position - 1;
    final row = adjustedPosition ~/ 10;
    final col = adjustedPosition % 10;
    
    // Snake and ladders board has alternating row directions
    // Bottom row (0): left to right
    // Next row (1): right to left, etc.
    if (row % 2 == 0) {
      return (9 - row) * 10 + col;
    } else {
      return (9 - row) * 10 + (9 - col);
    }
  }

  double _getTokenX(int cellIndex, int playerIndex, int totalPlayers) {
    final col = cellIndex % 10;
    final baseX = col * 30.0 + 15;
    
    if (totalPlayers == 1) return baseX;
    
    final offset = (playerIndex - (totalPlayers - 1) / 2) * 8;
    return baseX + offset;
  }

  double _getTokenY(int cellIndex, int playerIndex, int totalPlayers) {
    final row = cellIndex ~/ 10;
    final baseY = row * 30.0 + 15;
    
    if (totalPlayers == 1) return baseY;
    
    final offset = (playerIndex - (totalPlayers - 1) / 2) * 8;
    return baseY + offset;
  }

  Color _getPlayerColor(int index) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.yellow,
    ];
    return colors[index % colors.length];
  }
}
