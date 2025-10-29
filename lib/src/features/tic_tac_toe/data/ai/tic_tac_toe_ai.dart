import 'dart:math';
import 'package:board_game_moongi/src/core/game/ai_rule_set.dart';
import 'package:board_game_moongi/src/core/game/player.dart';
import 'package:board_game_moongi/src/features/tic_tac_toe/data/models/tic_tac_toe_state.dart';

enum AIDifficulty {
  easy,
  hard,
  extreme,
}

class TicTacToeAI extends AIRuleSet<TicTacToeState> {
  final String aiSymbol;
  final String humanSymbol;
  final AIDifficulty difficultyLevel;
  final Random _random = Random();

  TicTacToeAI({
    required super.aiPlayer,
    required this.aiSymbol,
    required this.humanSymbol,
    this.difficultyLevel = AIDifficulty.hard,
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
    switch (difficultyLevel) {
      case AIDifficulty.easy:
        return _getEasyMove(state);
      case AIDifficulty.hard:
        return _getHardMove(state);
      case AIDifficulty.extreme:
        return _getExtremeMove(state);
    }
  }

  /// Easy difficulty: 70% random moves, 30% smart moves
  Map<String, int>? _getEasyMove(TicTacToeState state) {
    final possibleMoves = getPossibleMoves(state);
    if (possibleMoves.isEmpty) return null;

    // 30% chance to make a smart move
    if (_random.nextDouble() < 0.3) {
      // Check if AI can win
      final winningMove = _findWinningMove(state, aiSymbol);
      if (winningMove != null) return winningMove;

      // Check if need to block player
      final blockingMove = _findWinningMove(state, humanSymbol);
      if (blockingMove != null) return blockingMove;
    }

    // 70% random move
    return possibleMoves[_random.nextInt(possibleMoves.length)];
  }

  /// Hard difficulty: Uses minimax with depth 4 and strategic priorities
  Map<String, int>? _getHardMove(TicTacToeState state) {
    final possibleMoves = getPossibleMoves(state);
    if (possibleMoves.isEmpty) return null;

    // Always check for winning move first
    final winningMove = _findWinningMove(state, aiSymbol);
    if (winningMove != null) return winningMove;

    // Always block opponent's winning move
    final blockingMove = _findWinningMove(state, humanSymbol);
    if (blockingMove != null) return blockingMove;

    // Take center if available
    if (state.isCellEmpty(1, 1)) {
      return {'row': 1, 'col': 1};
    }

    // Take corners if available
    final corners = [
      {'row': 0, 'col': 0},
      {'row': 0, 'col': 2},
      {'row': 2, 'col': 0},
      {'row': 2, 'col': 2},
    ];
    final availableCorners = corners.where((corner) {
      return state.isCellEmpty(corner['row']!, corner['col']!);
    }).toList();
    if (availableCorners.isNotEmpty) {
      return availableCorners[_random.nextInt(availableCorners.length)];
    }

    // Use minimax for remaining moves with limited depth
    return _getMinimaxMove(state, 4);
  }

  /// Extreme difficulty: Uses full minimax with alpha-beta pruning
  Map<String, int>? _getExtremeMove(TicTacToeState state) {
    final possibleMoves = getPossibleMoves(state);
    if (possibleMoves.isEmpty) return null;

    // Use full depth minimax with alpha-beta pruning
    return _getMinimaxMoveWithAlphaBeta(state, 9);
  }

  /// Find a winning move for the given symbol
  Map<String, int>? _findWinningMove(TicTacToeState state, String symbol) {
    final possibleMoves = getPossibleMoves(state);
    
    for (final move in possibleMoves) {
      final testState = _simulateMove(state, move, symbol);
      if (testState.getWinner() == symbol) {
        return move;
      }
    }
    
    return null;
  }

  /// Simulate a move without changing the actual state
  TicTacToeState _simulateMove(TicTacToeState state, Map<String, int> move, String symbol) {
    final newBoard = List<List<String?>>.generate(
      3,
      (i) => List<String?>.from(state.board[i]),
    );
    
    newBoard[move['row']!][move['col']!] = symbol;
    
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

  /// Get best move using minimax algorithm with specified depth
  Map<String, int>? _getMinimaxMove(TicTacToeState state, int depth) {
    double bestScore = double.negativeInfinity;
    Map<String, int>? bestMove;
    
    final possibleMoves = getPossibleMoves(state);
    
    for (final move in possibleMoves) {
      final newState = makeMove(state, move);
      final score = _minimax(newState, depth - 1, false);
      
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    
    return bestMove;
  }

  /// Minimax algorithm implementation
  double _minimax(TicTacToeState state, int depth, bool isMaximizing) {
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
        final newState = _simulateMove(state, move, humanSymbol);
        final eval = _minimax(newState, depth - 1, true);
        minEval = eval < minEval ? eval : minEval;
      }
      
      return minEval;
    }
  }

  /// Get best move using minimax with alpha-beta pruning
  Map<String, int>? _getMinimaxMoveWithAlphaBeta(TicTacToeState state, int depth) {
    double bestScore = double.negativeInfinity;
    Map<String, int>? bestMove;
    
    final possibleMoves = getPossibleMoves(state);
    
    for (final move in possibleMoves) {
      final newState = makeMove(state, move);
      final score = _alphabeta(
        newState,
        depth - 1,
        double.negativeInfinity,
        double.infinity,
        false,
      );
      
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    
    return bestMove;
  }

  /// Alpha-beta pruning optimization
  double _alphabeta(TicTacToeState state, int depth, double alpha, double beta, bool isMaximizing) {
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
        final newState = _simulateMove(state, move, humanSymbol);
        final eval = _alphabeta(newState, depth - 1, alpha, beta, true);
        minEval = eval < minEval ? eval : minEval;
        beta = beta < eval ? beta : eval;
        
        
        if (beta <= alpha) break; // Alpha cutoff
      }
      
      return minEval;
    }
  }
}
