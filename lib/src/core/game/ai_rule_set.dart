import 'package:board_game_moongi/src/core/game/game_state.dart';
import 'package:board_game_moongi/src/core/game/player.dart';

abstract class AIRuleSet<T extends GameState> {
  final Player aiPlayer;
  final int maxDepth;
  final double difficulty;

  const AIRuleSet({
    required this.aiPlayer,
    this.maxDepth = 3,
    this.difficulty = 0.8,
  });

  /// Evaluate the current game state from AI's perspective
  double evaluateState(T state);

  /// Get all possible moves for the current player
  List<dynamic> getPossibleMoves(T state);

  /// Make a move and return the new game state
  T makeMove(T state, dynamic move);

  /// Undo a move and return the previous game state
  T undoMove(T state, dynamic move);

  /// Check if the game is over
  bool isTerminal(T state);

  /// Get the best move using minimax algorithm
  dynamic getBestMove(T state) {
    double bestScore = double.negativeInfinity;
    dynamic bestMove;
    
    final possibleMoves = getPossibleMoves(state);
    
    for (final move in possibleMoves) {
      final newState = makeMove(state, move);
      final score = _minimax(newState, maxDepth, false);
      
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    
    return bestMove;
  }

  /// Minimax algorithm implementation
  double _minimax(T state, int depth, bool isMaximizing) {
    if (depth == 0 || isTerminal(state)) {
      return evaluateState(state);
    }

    if (isMaximizing) {
      double maxEval = double.negativeInfinity;
      final possibleMoves = getPossibleMoves(state);
      
      for (final move in possibleMoves) {
        final newState = makeMove(state, move);
        final eval = _minimax(newState, depth - 1, false);
        maxEval = eval > maxEval ? eval : maxEval;
      }
      
      return maxEval;
    } else {
      double minEval = double.infinity;
      final possibleMoves = getPossibleMoves(state);
      
      for (final move in possibleMoves) {
        final newState = makeMove(state, move);
        final eval = _minimax(newState, depth - 1, true);
        minEval = eval < minEval ? eval : minEval;
      }
      
      return minEval;
    }
  }

  /// Alpha-beta pruning optimization
  double _alphabeta(T state, int depth, double alpha, double beta, bool isMaximizing) {
    if (depth == 0 || isTerminal(state)) {
      return evaluateState(state);
    }

    if (isMaximizing) {
      double maxEval = double.negativeInfinity;
      final possibleMoves = getPossibleMoves(state);
      
      for (final move in possibleMoves) {
        final newState = makeMove(state, move);
        final eval = _alphabeta(newState, depth - 1, alpha, beta, false);
        maxEval = eval > maxEval ? eval : maxEval;
        alpha = alpha > eval ? alpha : eval;
        
        if (beta <= alpha) break; // Beta cutoff
      }
      
      return maxEval;
    } else {
      double minEval = double.infinity;
      final possibleMoves = getPossibleMoves(state);
      
      for (final move in possibleMoves) {
        final newState = makeMove(state, move);
        final eval = _alphabeta(newState, depth - 1, alpha, beta, true);
        minEval = eval < minEval ? eval : minEval;
        beta = beta < eval ? beta : eval;
        
        if (beta <= alpha) break; // Alpha cutoff
      }
      
      return minEval;
    }
  }
}
