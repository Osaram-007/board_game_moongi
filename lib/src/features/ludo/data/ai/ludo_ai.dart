import 'dart:math';
import 'package:board_game_moongi/src/core/game/ai_rule_set.dart';
import 'package:board_game_moongi/src/core/game/player.dart';
import 'package:board_game_moongi/src/features/ludo/data/models/ludo_state.dart';

class LudoAI extends AIRuleSet<LudoState> {
  final Random _random = Random();

  LudoAI({
    required super.aiPlayer,
    super.maxDepth = 3,
    super.difficulty = 0.8,
  });

  @override
  double evaluateState(LudoState state) {
    double score = 0.0;
    final aiIndex = state.players.indexOf(aiPlayer);
    
    // Evaluate AI's position
    final aiPieces = state.playerPieces[aiIndex];
    
    for (final piece in aiPieces) {
      if (piece.isHome) {
        score += 100.0; // High score for pieces in home
      } else if (piece.isOnBoard) {
        // Progress towards home
        score += piece.position * 0.5;
        
        // Bonus for being close to home
        if (piece.position > 50) {
          score += (piece.position - 50) * 2.0;
        }
        
        // Bonus for pieces on the board vs in home
        score += 10.0;
      }
    }
    
    // Penalty for opponent pieces
    for (int i = 0; i < state.players.length; i++) {
      if (i != aiIndex) {
        final opponentPieces = state.playerPieces[i];
        for (final piece in opponentPieces) {
          if (piece.isOnBoard) {
            score -= piece.position * 0.3;
          }
        }
      }
    }
    
    // Bonus for having more pieces on board
    final aiPiecesOnBoard = aiPieces.where((p) => p.isOnBoard).length;
    score += aiPiecesOnBoard * 5.0;
    
    return score;
  }

  @override
  List<Map<String, dynamic>> getPossibleMoves(LudoState state) {
    final moves = <Map<String, dynamic>>[];
    final aiIndex = state.players.indexOf(aiPlayer);
    final aiPieces = state.playerPieces[aiIndex];
    
    for (int pieceIndex = 0; pieceIndex < aiPieces.length; pieceIndex++) {
      final piece = aiPieces[pieceIndex];
      final validMoves = state.getValidMovesForPiece(piece, state.currentDiceValue);
      
      for (final move in validMoves) {
        moves.add({
          'pieceIndex': pieceIndex,
          'newPosition': move,
        });
      }
    }
    
    return moves;
  }

  @override
  LudoState makeMove(LudoState state, Map<String, dynamic> move) {
    final aiIndex = state.players.indexOf(aiPlayer);
    final newPieces = List<List<Piece>>.generate(
      state.playerPieces.length,
      (i) => List<Piece>.from(state.playerPieces[i].map((p) => p.copyWith())),
    );
    
    final pieceIndex = move['pieceIndex'] as int;
    final newPosition = move['newPosition'] as int;
    
    final piece = newPieces[aiIndex][pieceIndex];
    piece.position = newPosition;
    piece.isOnBoard = true;
    
    // Check if piece reached home
    if (newPosition >= 57) {
      piece.isHome = true;
      piece.isOnBoard = false;
    }
    
    // Handle captures
    _handleCaptures(newPieces, aiIndex, newPosition);
    
    return LudoState.withPieces(
      players: state.players,
      playerPieces: newPieces,
      playerStartPositions: state.playerStartPositions,
      gameRules: state.gameRules,
      currentPlayer: state.currentPlayer,
      status: state.status,
      startedAt: state.startedAt,
      endedAt: state.endedAt,
      metadata: state.metadata,
      currentDiceValue: state.currentDiceValue,
      isRolling: state.isRolling,
    );
  }

  void _handleCaptures(List<List<Piece>> pieces, int playerIndex, int position) {
    for (int i = 0; i < pieces.length; i++) {
      if (i != playerIndex) {
        for (final piece in pieces[i]) {
          if (piece.isOnBoard && piece.position == position) {
            // Capture opponent piece
            piece.isOnBoard = false;
            piece.position = 0;
          }
        }
      }
    }
  }

  @override
  LudoState undoMove(LudoState state, Map<String, dynamic> move) {
    // Implementation for undoing moves
    return state; // Simplified for now
  }

  @override
  bool isTerminal(LudoState state) {
    return state.hasPlayerWon(aiPlayer);
  }

  Map<String, dynamic>? getBestMove(LudoState state) {
    final moves = getPossibleMoves(state);
    if (moves.isEmpty) return null;
    
    // Use heuristic scoring for immediate evaluation
    double bestScore = double.negativeInfinity;
    Map<String, dynamic>? bestMove;
    
    for (final move in moves) {
      final newState = makeMove(state, move);
      final score = evaluateState(newState);
      
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    
    return bestMove;
  }

  // Simple heuristic-based move selection
  Map<String, dynamic>? selectBestMove(LudoState state) {
    final aiIndex = state.players.indexOf(aiPlayer);
    final aiPieces = state.playerPieces[aiIndex];
    final diceValue = state.currentDiceValue;
    
    // Priority order for moves
    final validMoves = <Map<String, dynamic>>[];
    
    for (int pieceIndex = 0; pieceIndex < aiPieces.length; pieceIndex++) {
      final piece = aiPieces[pieceIndex];
      final moves = state.getValidMovesForPiece(piece, diceValue);
      
      for (final move in moves) {
        validMoves.add({
          'pieceIndex': pieceIndex,
          'newPosition': move,
          'score': _calculateMoveScore(piece, move, state),
        });
      }
    }
    
    if (validMoves.isEmpty) return null;
    
    validMoves.sort((a, b) => b['score'].compareTo(a['score']));
    return {
      'pieceIndex': validMoves.first['pieceIndex'],
      'newPosition': validMoves.first['newPosition'],
    };
  }

  double _calculateMoveScore(Piece piece, int newPosition, LudoState state) {
    double score = 0.0;
    
    // Priority 1: Get piece out of home (roll 6)
    if (!piece.isOnBoard && newPosition > 0) {
      score += 50.0;
    }
    
    // Priority 2: Move towards home
    if (piece.isOnBoard) {
      score += (newPosition - piece.position) * 2.0;
    }
    
    // Priority 3: Reach home
    if (newPosition >= 57) {
      score += 100.0;
    }
    
    // Priority 4: Capture opponent pieces
    for (int i = 0; i < state.players.length; i++) {
      if (i != state.players.indexOf(aiPlayer)) {
        final opponentPieces = state.playerPieces[i];
        for (final opponentPiece in opponentPieces) {
          if (opponentPiece.isOnBoard && opponentPiece.position == newPosition) {
            score += 30.0; // Bonus for capture
          }
        }
      }
    }
    
    // Priority 5: Avoid getting captured
    if (piece.isOnBoard && !_isSafePosition(newPosition, state)) {
      score -= 20.0;
    }
    
    return score;
  }

  bool _isSafePosition(int position, LudoState state) {
    final safeZones = state.gameRules['safeZones'] as List<int>;
    return safeZones.contains(position);
  }
}
