import 'package:board_game_moongi/src/core/game/ai_rule_set.dart';
import 'package:board_game_moongi/src/core/game/player.dart';
import 'package:board_game_moongi/src/features/tic_tac_toe/data/models/tic_tac_toe_state.dart';

class TicTacToeAI extends AIRuleSet<TicTacToeState> {
  final String aiSymbol;
  final String humanSymbol;

  TicTacToeAI({
    required super.aiPlayer,
    required this.aiSymbol,
    required this.humanSymbol,
    super.maxDepth = 9,
    super.difficulty = 0.9,
  });

  @override
  double evaluateState(TicTacToeState state) {
    final winner = state.getWinner();
    
    if (winner == aiSymbol) {
      return 10.0;
    } else if (winner == humanSymbol) {
      return -10.0;
    } else if (state.isBoardFull()) {
      return 0.0;
    }

    // Heuristic evaluation for non-terminal states
    double score = 0.0;
    
    // Evaluate rows
    for (int i = 0; i < 3; i++) {
      score += _evaluateLine(state, [0, 1, 2], [i, i, i]);
    }

    // Evaluate columns
    for (int j = 0; j < 3; j++) {
      score += _evaluateLine(state, [0, 1, 2], [j, j, j]);
    }

    // Evaluate diagonals
    score += _evaluateLine(state, [0, 1, 2], [0, 1, 2]);
    score += _evaluateLine(state, [0, 1, 2], [2, 1, 0]);

    return score;
  }

  double _evaluateLine(TicTacToeState state, List<int> rows, List<int> cols) {
    int aiCount = 0;
    int humanCount = 0;
    int emptyCount = 0;

    for (int k = 0; k < 3; k++) {
      final cell = state.board[rows[k]][cols[k]];
      if (cell == aiSymbol) {
        aiCount++;
      } else if (cell == humanSymbol) {
        humanCount++;
      } else {
        emptyCount++;
      }
    }

    if (aiCount == 2 && emptyCount == 1) return 5.0;
    if (aiCount == 1 && emptyCount == 2) return 1.0;
    if (humanCount == 2 && emptyCount == 1) return -5.0;
    if (humanCount == 1 && emptyCount == 2) return -1.0;
    
    return 0.0;
  }

  @override
  List<Map<String, int>> getPossibleMoves(TicTacToeState state) {
    final moves = <Map<String, int>>[];
    
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (state.isCellEmpty(i, j)) {
          moves.add({'row': i, 'col': j});
        }
      }
    }
    
    return moves;
  }

  @override
  TicTacToeState makeMove(TicTacToeState state, dynamic move) {
    final moveMap = move as Map<String, int>;
    final newBoard = List<List<String?>>.generate(
      3,
      (i) => List<String?>.from(state.board[i]),
    );
    
    newBoard[moveMap['row']!][moveMap['col']!] = aiSymbol;
    
    return TicTacToeState.withBoard(
      players: state.players,
      currentPlayer: state.currentPlayer,
      status: state.status,
      startedAt: state.startedAt,
      endedAt: state.endedAt,
      metadata: state.metadata,
      board: newBoard,
    );
  }

  @override
  TicTacToeState undoMove(TicTacToeState state, dynamic move) {
    final moveMap = move as Map<String, int>;
    final newBoard = List<List<String?>>.generate(
      3,
      (i) => List<String?>.from(state.board[i]),
    );
    
    newBoard[moveMap['row']!][moveMap['col']!] = null;
    
    return TicTacToeState.withBoard(
      players: state.players,
      currentPlayer: state.currentPlayer,
      status: state.status,
      startedAt: state.startedAt,
      endedAt: state.endedAt,
      metadata: state.metadata,
      board: newBoard,
    );
  }

  @override
  bool isTerminal(TicTacToeState state) {
    return state.hasWinner() || state.isBoardFull();
  }

  Map<String, int>? getBestMove(TicTacToeState state) {
    return super.getBestMove(state);
  }
}
