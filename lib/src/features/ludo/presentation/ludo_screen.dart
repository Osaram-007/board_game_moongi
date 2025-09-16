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
        appBar: AppBar(
          title: const Text('Ludo'),
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
                _buildGameStatus(controller.state),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(child: _buildGameBoard(controller)),
                        const SizedBox(width: 16),
                        _buildPlayerInfo(controller.state),
                      ],
                    ),
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

  Widget _buildGameBoard(LudoController controller) {
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
          // Ludo board layout
          Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: CustomPaint(
                painter: LudoBoardPainter(),
              ),
            ),
          ),
          
          // Player pieces
          ..._buildPlayerPieces(controller.state),
        ],
      ),
    );
  }

  List<Widget> _buildPlayerPieces(LudoState state) {
    final pieces = <Widget>[];
    
    for (int playerIndex = 0; playerIndex < state.players.length; playerIndex++) {
      final playerPieces = state.playerPieces[playerIndex];
      final playerColor = _getPlayerColor(playerIndex);
      
      for (int pieceIndex = 0; pieceIndex < playerPieces.length; pieceIndex++) {
        final piece = playerPieces[pieceIndex];
        final position = _getPiecePosition(piece, playerIndex);
        
        pieces.add(
          Positioned(
            left: position.dx,
            top: position.dy,
            child: GestureDetector(
              onTap: () => _controller.selectPiece(pieceIndex),
              child: AnimatedContainer(
                duration: 600.ms,
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: piece.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: state.selectedPieceIndex == pieceIndex 
                        ? Colors.yellow 
                        : Colors.white,
                    width: state.selectedPieceIndex == pieceIndex ? 3 : 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${pieceIndex + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ).animate().scale(
                duration: 300.ms,
                curve: Curves.easeOut,
              ),
            ),
          ),
        );
      }
    }
    
    return pieces;
  }

  Widget _buildPlayerInfo(LudoState state) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Players',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...List.generate(state.players.length, (index) {
            final player = state.players[index];
            final piecesInHome = state.getPiecesInHome(player);
            final color = _getPlayerColor(index);
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: state.currentPlayer?.id == player.id 
                      ? color 
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    'Pieces Home: $piecesInHome/4',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGameControls(LudoController controller) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: controller.state.status == GameStatus.playing && 
                         !controller.state.isRolling &&
                         controller.state.validMoves.isNotEmpty
                    ? controller.moveSelectedPiece
                    : null,
                icon: const Icon(Icons.move_up),
                label: const Text('Move Piece'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(width: 16),
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
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

class LudoBoardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.black;

    // Draw board outline
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw center square
    final centerSize = size.width * 0.3;
    final centerOffset = (size.width - centerSize) / 2;
    canvas.drawRect(
      Rect.fromLTWH(centerOffset, centerOffset, centerSize, centerSize),
      paint,
    );

    // Draw home stretches
    _drawHomeStretch(canvas, size, Colors.red, 0);
    _drawHomeStretch(canvas, size, Colors.blue, 1);
    _drawHomeStretch(canvas, size, Colors.green, 2);
    _drawHomeStretch(canvas, size, Colors.yellow, 3);
  }

  void _drawHomeStretch(Canvas canvas, Size size, Color color, int playerIndex) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final cellSize = size.width / 15;
    
    // Draw player home areas (simplified)
    switch (playerIndex) {
      case 0: // Red - top left
        canvas.drawRect(
          Rect.fromLTWH(0, 0, cellSize * 6, cellSize * 6),
          paint,
        );
        break;
      case 1: // Blue - top right
        canvas.drawRect(
          Rect.fromLTWH(size.width - cellSize * 6, 0, cellSize * 6, cellSize * 6),
          paint,
        );
        break;
      case 2: // Green - bottom right
        canvas.drawRect(
          Rect.fromLTWH(
            size.width - cellSize * 6, 
            size.height - cellSize * 6, 
            cellSize * 6, 
            cellSize * 6
          ),
          paint,
        );
        break;
      case 3: // Yellow - bottom left
        canvas.drawRect(
          Rect.fromLTWH(0, size.height - cellSize * 6, cellSize * 6, cellSize * 6),
          paint,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
