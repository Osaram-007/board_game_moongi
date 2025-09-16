import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:board_game_moongi/src/core/game/player.dart';
import 'package:board_game_moongi/src/core/game/game_state.dart';
import 'package:board_game_moongi/src/core/theme/app_theme.dart';
import 'package:board_game_moongi/src/features/ludo/domain/ludo_controller.dart';
import 'package:board_game_moongi/src/features/ludo/data/models/ludo_state.dart';

class LudoScreen extends StatefulWidget {
  final String gameMode;

  const LudoScreen({super.key, required this.gameMode});

  @override
  State<LudoScreen> createState() => _LudoScreenState();
}

class _LudoScreenState extends State<LudoScreen> {
  late LudoController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LudoController(
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
        backgroundColor: const Color(0xFF4A4A8A), // Purple background like in image
        appBar: AppBar(
          title: const Text('Ludo'),
          backgroundColor: const Color(0xFF4A4A8A),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _controller.resetGame(),
            ),
          ],
        ),
        body: Consumer<LudoController>(
          builder: (context, controller, child) {
            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: _buildLudoBoard(controller),
                      ),
                    ),
                  ),
                ),
                _buildPlayerTokens(controller.state),
                _buildGameControls(controller),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGameStatus(LudoState state) {
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

  Widget _buildLudoBoard(LudoController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange, width: 4),
      ),
      child: Column(
        children: [
          // Top row
          Expanded(
            child: Row(
              children: [
                // Red quadrant
                Expanded(child: _buildQuadrant(Colors.red, 0)),
                // Top path
                Expanded(child: _buildTopPath()),
                // Green quadrant  
                Expanded(child: _buildQuadrant(Colors.green, 1)),
              ],
            ),
          ),
          // Middle row (left path + center + right path)
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildLeftPath()),
                Expanded(child: _buildCenter()),
                Expanded(child: _buildRightPath()),
              ],
            ),
          ),
          // Bottom row
          Expanded(
            child: Row(
              children: [
                // Blue quadrant
                Expanded(child: _buildQuadrant(Colors.blue, 2)),
                // Bottom path
                Expanded(child: _buildBottomPath()),
                // Yellow quadrant
                Expanded(child: _buildQuadrant(Colors.yellow, 3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuadrant(Color color, int quadrantIndex) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: List.generate(4, (index) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTopPath() {
    return Container(
      color: Colors.white,
      child: Column(
        children: List.generate(3, (row) {
          return Expanded(
            child: Row(
              children: List.generate(6, (col) {
                final isMiddleColumn = col == 1;
                final isHomeStretch = row == 1 && isMiddleColumn;
                return Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isHomeStretch ? Colors.green : Colors.white,
                      border: Border.all(color: Colors.grey, width: 0.5),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomPath() {
    return Container(
      color: Colors.white,
      child: Column(
        children: List.generate(3, (row) {
          return Expanded(
            child: Row(
              children: List.generate(6, (col) {
                final isMiddleColumn = col == 1;
                final isHomeStretch = row == 1 && isMiddleColumn;
                return Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isHomeStretch ? Colors.yellow : Colors.white,
                      border: Border.all(color: Colors.grey, width: 0.5),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLeftPath() {
    return Container(
      color: Colors.white,
      child: Row(
        children: List.generate(3, (col) {
          return Expanded(
            child: Column(
              children: List.generate(6, (row) {
                final isMiddleRow = row == 1;
                final isHomeStretch = col == 1 && isMiddleRow;
                return Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isHomeStretch ? Colors.red : Colors.white,
                      border: Border.all(color: Colors.grey, width: 0.5),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRightPath() {
    return Container(
      color: Colors.white,
      child: Row(
        children: List.generate(3, (col) {
          return Expanded(
            child: Column(
              children: List.generate(6, (row) {
                final isMiddleRow = row == 1;
                final isHomeStretch = col == 1 && isMiddleRow;
                return Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isHomeStretch ? Colors.blue : Colors.white,
                      border: Border.all(color: Colors.grey, width: 0.5),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCenter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: Stack(
        children: [
          // Center triangle paths
          CustomPaint(
            painter: CenterTrianglePainter(),
            size: const Size.square(double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerTokens(LudoState state) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          final colors = [Colors.green, Colors.orange, Colors.red, Colors.blue];
          final isActive = index < state.players.length && 
                          state.currentPlayer?.id == state.players[index].id;
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: colors[index],
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? Colors.white : Colors.transparent,
                width: 3,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 30,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGameControls(LudoController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (controller.state.status == GameStatus.waiting) ..[
            ElevatedButton.icon(
              onPressed: () => controller.startGame(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Game'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ] else ..[
            ElevatedButton.icon(
              onPressed: controller.state.status == GameStatus.playing && 
                       !controller.state.isRolling
                  ? controller.rollDice
                  : null,
              icon: const Icon(Icons.casino),
              label: Text(
                controller.state.isRolling ? 'Rolling...' : 'Roll Dice',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => controller.resetGame(),
                icon: const Icon(Icons.refresh),
                label: const Text('New Game'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4A4A8A),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home),
                label: const Text('Main Menu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4A4A8A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Offset _getPiecePosition(Piece piece, int playerIndex) {
    // Simplified position calculation for demo
    // In a real implementation, this would be more complex
    const boardSize = 300.0;
    const cellSize = 20.0;
    
    if (!piece.isOnBoard) {
      // Home positions
      final homeX = playerIndex < 2 ? 50.0 : 250.0;
      final homeY = playerIndex % 2 == 0 ? 50.0 : 250.0;
      return Offset(homeX, homeY);
    }
    
    // Board positions
    final angle = (piece.position / 52) * 2 * 3.14159;
    final centerX = boardSize / 2;
    final centerY = boardSize / 2;
    final radius = boardSize / 2 - 30;
    
    return Offset(
      centerX + cos(angle) * radius,
      centerY + sin(angle) * radius,
    );
  }

  Color _getPlayerColor(int index) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
    ];
    return colors[index % colors.length];
  }
}

class CenterTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final triangleSize = size.width * 0.3;

    // Draw colored triangles pointing to each quadrant
    // Red triangle (pointing left)
    paint.color = Colors.red;
    final redPath = Path()
      ..moveTo(centerX - triangleSize / 2, centerY)
      ..lineTo(centerX, centerY - triangleSize / 4)
      ..lineTo(centerX, centerY + triangleSize / 4)
      ..close();
    canvas.drawPath(redPath, paint);

    // Green triangle (pointing up)
    paint.color = Colors.green;
    final greenPath = Path()
      ..moveTo(centerX, centerY - triangleSize / 2)
      ..lineTo(centerX - triangleSize / 4, centerY)
      ..lineTo(centerX + triangleSize / 4, centerY)
      ..close();
    canvas.drawPath(greenPath, paint);

    // Blue triangle (pointing right)
    paint.color = Colors.blue;
    final bluePath = Path()
      ..moveTo(centerX + triangleSize / 2, centerY)
      ..lineTo(centerX, centerY - triangleSize / 4)
      ..lineTo(centerX, centerY + triangleSize / 4)
      ..close();
    canvas.drawPath(bluePath, paint);

    // Yellow triangle (pointing down)
    paint.color = Colors.yellow;
    final yellowPath = Path()
      ..moveTo(centerX, centerY + triangleSize / 2)
      ..lineTo(centerX - triangleSize / 4, centerY)
      ..lineTo(centerX + triangleSize / 4, centerY)
      ..close();
    canvas.drawPath(yellowPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
