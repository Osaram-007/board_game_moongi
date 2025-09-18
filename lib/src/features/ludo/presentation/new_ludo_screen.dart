import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:board_game_moongi/src/core/game/game_state.dart';
import '../domain/new_ludo_controller.dart';
import '../data/models/new_ludo_state.dart';
import '../data/models/ludo_board.dart';
import '../data/models/ludo_token.dart';
import '../data/models/ludo_player.dart';

class NewLudoScreen extends StatefulWidget {
  final GameMode gameMode;
  final DifficultyLevel difficulty;

  const NewLudoScreen({
    super.key,
    this.gameMode = GameMode.singlePlayer,
    this.difficulty = DifficultyLevel.medium,
  });

  @override
  State<NewLudoScreen> createState() => _NewLudoScreenState();
}

class _NewLudoScreenState extends State<NewLudoScreen> {
  late NewLudoController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NewLudoController(
      gameMode: widget.gameMode,
      difficulty: widget.difficulty,
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
        backgroundColor: Colors.orange[100],
        appBar: AppBar(
          title: const Text('Ludo'),
          backgroundColor: Colors.orange[300],
          foregroundColor: Colors.black,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _controller.resetGame(),
            ),
          ],
        ),
        body: Consumer<NewLudoController>(
          builder: (context, controller, child) {
            return Column(
              children: [
                // Game Status Header
                _buildGameStatus(controller.state),
                
                // Game Board
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: _buildGameBoard(controller),
                      ),
                    ),
                  ),
                ),
                
                // Player Status
                _buildPlayerStatus(controller.state),
                
                // Game Controls
                _buildGameControls(controller),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGameStatus(NewLudoState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Current Player Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (state.status == GameStatus.playing) ...[
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: state.currentLudoPlayer.color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      state.status == GameStatus.playing 
                        ? '${state.currentLudoPlayer.name}\'s Turn'
                        : state.status == GameStatus.waiting 
                          ? 'Ready to Play!'
                          : state.hasWinner
                            ? '${state.winner?.name} Wins!'
                            : 'Game Over',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: state.status == GameStatus.playing
                            ? state.currentLudoPlayer.color
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
                if (state.status == GameStatus.playing) ...[
                  const SizedBox(height: 4),
                  Text(
                    state.isRollingDice 
                      ? 'Rolling dice...' 
                      : state.isDiceRolled
                        ? state.movableTokens.isNotEmpty 
                          ? 'Select a token to move'
                          : 'No valid moves - passing turn'
                        : 'Tap dice to roll',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Dice Display
          if (state.status == GameStatus.playing) ...[
            GestureDetector(
              onTap: state.canRollDice ? () => _controller.rollDice() : null,
              child: Container(
                width: 60,
                height: 60,
                margin: const EdgeInsets.only(left: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: state.canRollDice ? state.currentLudoPlayer.color : Colors.grey, 
                    width: 2
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: state.isRollingDice
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : _buildDiceFace(state.diceValue),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDiceFace(int value) {
    return CustomPaint(
      size: const Size(40, 40),
      painter: DicePainter(value),
    );
  }

  Widget _buildGameBoard(NewLudoController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildBoardGrid(controller),
      ),
    );
  }

  Widget _buildBoardGrid(NewLudoController controller) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 15,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
      ),
      itemCount: 225, // 15x15 grid
      itemBuilder: (context, index) {
        final x = index % 15;
        final y = index ~/ 15;
        final cell = controller.state.board.grid[y][x];
        
        return GestureDetector(
          onTap: () => _onCellTapped(controller, x, y),
          child: _buildBoardCell(controller, cell, x, y),
        );
      },
    );
  }

  Widget _buildBoardCell(NewLudoController controller, BoardCell cell, int x, int y) {
    Color backgroundColor = Colors.white;
    Widget? content;
    
    // Set background color based on cell type
    switch (cell.type) {
      case CellType.homeArea:
        backgroundColor = cell.color ?? Colors.white;
        break;
      case CellType.path:
      case CellType.start:
        backgroundColor = Colors.grey[100]!;
        break;
      case CellType.safe:
        backgroundColor = Colors.yellow[100]!;
        break;
      case CellType.finishPath:
        backgroundColor = cell.color ?? Colors.white;
        break;
      case CellType.center:
        backgroundColor = Colors.grey[300]!;
        break;
      case CellType.empty:
        backgroundColor = Colors.transparent;
        break;
    }

    // Add star for safe squares
    if (cell.hasStar) {
      content = const Icon(
        Icons.star,
        size: 12,
        color: Colors.amber,
      );
    }

    // Add tokens if present
    if (cell.tokens.isNotEmpty) {
      if (cell.tokens.length == 1) {
        content = _buildSingleToken(cell.tokens.first, controller.state);
      } else {
        content = _buildMultipleTokens(cell.tokens, controller.state);
      }
    }

    // Highlight if cell is selectable
    bool isHighlighted = false;
    if (controller.state.selectedToken != null) {
      // Highlight possible destination
      isHighlighted = _canMoveToCell(controller, controller.state.selectedToken!, x, y);
    } else if (controller.state.movableTokens.isNotEmpty) {
      // Highlight movable tokens
      isHighlighted = cell.tokens.any((token) => 
        controller.state.movableTokens.any((movable) => movable.id == token.id)
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: isHighlighted ? Colors.green : Colors.grey[400]!,
          width: isHighlighted ? 2 : 0.5,
        ),
      ),
      child: content,
    );
  }

  Widget _buildSingleToken(LudoToken token, NewLudoState state) {
    final isSelected = state.selectedToken?.id == token.id;
    final isMovable = state.movableTokens.any((t) => t.id == token.id);
    
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: token.color,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? Colors.white : Colors.black,
          width: isSelected ? 3 : 1,
        ),
        boxShadow: isMovable ? [
          BoxShadow(
            color: token.color.withOpacity(0.5),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ] : null,
      ),
      child: Center(
        child: Text(
          '${token.playerId + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMultipleTokens(List<LudoToken> tokens, NewLudoState state) {
    return Stack(
      children: tokens.asMap().entries.map((entry) {
        final index = entry.key;
        final token = entry.value;
        final offset = index * 2.0;
        
        return Positioned(
          left: offset,
          top: offset,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: token.color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 0.5),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlayerStatus(NewLudoState state) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: state.ludoPlayers.map((player) {
          final isCurrentPlayer = player.playerId == state.currentPlayerIndex;
          
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isCurrentPlayer ? player.color.withOpacity(0.2) : Colors.transparent,
                  shape: BoxShape.circle,
                  border: isCurrentPlayer 
                      ? Border.all(color: player.color, width: 3)
                      : Border.all(color: Colors.grey[300]!, width: 1),
                  boxShadow: isCurrentPlayer ? [
                    BoxShadow(
                      color: player.color.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ] : null,
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: player.color,
                  child: Text(
                    '${player.playerId + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                player.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isCurrentPlayer ? FontWeight.bold : FontWeight.w500,
                  color: isCurrentPlayer ? player.color : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'H:${player.tokensHome}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'A:${player.tokensActive}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'F:${player.tokensFinished}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGameControls(NewLudoController controller) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (controller.state.status == GameStatus.waiting) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => controller.startGame(),
                icon: const Icon(Icons.play_arrow, size: 24),
                label: const Text('Start Game', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
          if (controller.state.status == GameStatus.finished) ...[
            Column(
              children: [
                Text(
                  '🎉 ${controller.winner?.name ?? "Game"} Wins! 🎉',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: controller.winner?.color ?? Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => controller.resetGame(),
                    icon: const Icon(Icons.refresh, size: 24),
                    label: const Text('New Game', style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.resetGame(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('New Game'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.home),
                  label: const Text('Main Menu'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onCellTapped(NewLudoController controller, int x, int y) {
    final cell = controller.state.board.grid[y][x];
    
    if (controller.state.selectedToken != null) {
      // Try to move selected token to this cell
      if (_canMoveToCell(controller, controller.state.selectedToken!, x, y)) {
        controller.moveToken(controller.state.selectedToken!);
      } else {
        // Deselect token
        controller.selectToken(controller.state.selectedToken!);
      }
    } else if (cell.tokens.isNotEmpty) {
      // Try to select a token from this cell
      final movableToken = cell.tokens.firstWhere(
        (token) => controller.state.movableTokens.any((movable) => movable.id == token.id),
        orElse: () => cell.tokens.first,
      );
      
      if (controller.state.movableTokens.any((movable) => movable.id == movableToken.id)) {
        controller.selectToken(movableToken);
      }
    }
  }

  bool _canMoveToCell(NewLudoController controller, LudoToken token, int x, int y) {
    // Simplified - in a full implementation, this would calculate the exact path
    // For now, just check if it's a valid board position
    return x >= 0 && x < 15 && y >= 0 && y < 15;
  }
}

class DicePainter extends CustomPainter {
  final int value;

  DicePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final dotRadius = size.width * 0.06;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final quarterX = size.width / 4;
    final quarterY = size.height / 4;

    switch (value) {
      case 1:
        canvas.drawCircle(Offset(centerX, centerY), dotRadius, paint);
        break;
      case 2:
        canvas.drawCircle(Offset(quarterX, quarterY), dotRadius, paint);
        canvas.drawCircle(Offset(centerX + quarterX, centerY + quarterY), dotRadius, paint);
        break;
      case 3:
        canvas.drawCircle(Offset(quarterX, quarterY), dotRadius, paint);
        canvas.drawCircle(Offset(centerX, centerY), dotRadius, paint);
        canvas.drawCircle(Offset(centerX + quarterX, centerY + quarterY), dotRadius, paint);
        break;
      case 4:
        canvas.drawCircle(Offset(quarterX, quarterY), dotRadius, paint);
        canvas.drawCircle(Offset(centerX + quarterX, quarterY), dotRadius, paint);
        canvas.drawCircle(Offset(quarterX, centerY + quarterY), dotRadius, paint);
        canvas.drawCircle(Offset(centerX + quarterX, centerY + quarterY), dotRadius, paint);
        break;
      case 5:
        canvas.drawCircle(Offset(quarterX, quarterY), dotRadius, paint);
        canvas.drawCircle(Offset(centerX + quarterX, quarterY), dotRadius, paint);
        canvas.drawCircle(Offset(centerX, centerY), dotRadius, paint);
        canvas.drawCircle(Offset(quarterX, centerY + quarterY), dotRadius, paint);
        canvas.drawCircle(Offset(centerX + quarterX, centerY + quarterY), dotRadius, paint);
        break;
      case 6:
        canvas.drawCircle(Offset(quarterX, quarterY), dotRadius, paint);
        canvas.drawCircle(Offset(centerX + quarterX, quarterY), dotRadius, paint);
        canvas.drawCircle(Offset(quarterX, centerY), dotRadius, paint);
        canvas.drawCircle(Offset(centerX + quarterX, centerY), dotRadius, paint);
        canvas.drawCircle(Offset(quarterX, centerY + quarterY), dotRadius, paint);
        canvas.drawCircle(Offset(centerX + quarterX, centerY + quarterY), dotRadius, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(DicePainter oldDelegate) => oldDelegate.value != value;
}
