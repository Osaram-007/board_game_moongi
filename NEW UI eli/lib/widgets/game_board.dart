import 'package:flutter/material.dart';
import 'glass_card.dart';
import '../theme/app_theme.dart';

class GameBoard extends StatefulWidget {
  final List<String> board;
  final Function(int) onCellTap;
  final bool isDarkMode;

  const GameBoard({
    Key? key,
    required this.board,
    required this.onCellTap,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> with TickerProviderStateMixin {
  late List<AnimationController> _cellControllers;

  @override
  void initState() {
    super.initState();
    _cellControllers = List.generate(
      9,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ),
    );
  }

  @override
  void didUpdateWidget(GameBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (int i = 0; i < widget.board.length; i++) {
      if (oldWidget.board[i] != widget.board[i] && widget.board[i].isNotEmpty) {
        _cellControllers[i].forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _cellControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      isDarkMode: widget.isDarkMode,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: 9,
          itemBuilder: (context, index) {
            return ScaleTransition(
              scale: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(parent: _cellControllers[index], curve: Curves.elasticOut),
              ),
              child: _buildCell(index),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCell(int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isDarkMode
              ? AppTheme.neonMagenta.withOpacity(0.4)
              : AppTheme.accentPurple.withOpacity(0.3),
          width: 2,
        ),
        color: widget.isDarkMode
            ? AppTheme.darkBgSecondary.withOpacity(0.5)
            : AppTheme.lightBgSecondary.withOpacity(0.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onCellTap(index),
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              widget.board[index],
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: widget.board[index] == 'X'
                    ? (widget.isDarkMode ? AppTheme.neonCyan : AppTheme.accentTeal)
                    : (widget.isDarkMode ? AppTheme.neonMagenta : AppTheme.accentPurple),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
