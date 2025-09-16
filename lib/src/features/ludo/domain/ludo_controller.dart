import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/ludo_state.dart';
import 'package:board_game_moongi/src/core/game/game_controller.dart';
import 'package:board_game_moongi/src/core/game/player.dart';
import 'package:board_game_moongi/src/core/game/game_state.dart';
import 'package:board_game_moongi/src/features/ludo/data/models/ludo_state.dart';
import 'package:board_game_moongi/src/features/ludo/data/ai/ludo_ai.dart';

class LudoController extends GameController<LudoState> {
  final String gameMode;
  final Random _random = Random();
  late final LudoAI _ai;
  Timer? _aiMoveTimer;
  Timer? _animationTimer;

  LudoController({
    required this.gameMode,
    required List<Player> players,
  }) : super(_createInitialState(players)) {
    _ai = LudoAI(
      aiPlayer: players.firstWhere((p) => p.type == PlayerType.ai),
      maxDepth: 3,
      difficulty: 0.8,
    );
  }

  static LudoState _createInitialState(List<Player> players) {
    final colors = [Colors.red, Colors.blue, Colors.green, Colors.yellow];
    final playerPieces = List<List<Piece>>.generate(
      players.length,
      (playerIndex) => List<Piece>.generate(
        4,
        (pieceIndex) => Piece(
          id: '${players[playerIndex].id}_$pieceIndex',
          playerId: players[playerIndex].id,
          playerIndex: playerIndex,
          initialPosition: 0,
          color: colors[playerIndex],
        ),
      ),
    );

    return LudoState.withPieces(
      players: players,
      playerPieces: playerPieces,
      playerStartPositions: [1, 14, 27, 40],
      gameRules: const {
        'boardSize': 52,
        'piecesPerPlayer': 4,
        'safeZones': [1, 9, 14, 22, 27, 35, 40, 48],
        'homeStretch': 6,
        'sixRule': true,
        'captureRule': true,
      },
    );
  }

  @override
  bool isValidMove(dynamic move) {
    final moveMap = move as Map<String, dynamic>;
    final pieceIndex = moveMap['pieceIndex'] as int;
    final newPosition = moveMap['newPosition'] as int;
    
    if (state.status != GameStatus.playing) return false;
    if (state.isRolling) return false;
    
    final pieces = state.getCurrentPlayerPieces();
    if (pieceIndex < 0 || pieceIndex >= pieces.length) return false;
    
    final piece = pieces[pieceIndex];
    return state.canMovePiece(piece, state.currentDiceValue);
  }

  @override
  void processMove(dynamic move) {
    final moveMap = move as Map<String, dynamic>;
    final pieceIndex = moveMap['pieceIndex'] as int;
    final newPosition = moveMap['newPosition'] as int;
    
    final playerIndex = state.players.indexOf(state.currentPlayer!);
    final newPieces = List<List<Piece>>.generate(
      state.playerPieces.length,
      (i) => List<Piece>.from(state.playerPieces[i].map((p) => p.copyWith())),
    );
    
    final piece = newPieces[playerIndex][pieceIndex];
    piece.position = newPosition;
    piece.isOnBoard = true;
    
    // Check if piece reached home
    if (newPosition >= 57) {
      piece.isHome = true;
      piece.isOnBoard = false;
    }
    
    // Handle captures
    _handleCaptures(newPieces, playerIndex, newPosition);
    
    updateState(state.copyWith(
      playerPieces: newPieces,
      selectedPieceIndex: null,
      validMoves: [],
    ));
  }

  void _handleCaptures(List<List<Piece>> pieces, int playerIndex, int position) {
    final safeZones = state.gameRules['safeZones'] as List<int>;
    
    if (safeZones.contains(position)) return; // Safe zone, no captures
    
    for (int i = 0; i < pieces.length; i++) {
      if (i != playerIndex) {
        for (final piece in pieces[i]) {
          if (piece.isOnBoard && piece.position == position) {
            // Capture opponent piece
            piece.isOnBoard = false;
            piece.position = 0;
            
            // Bonus roll for capture
            _triggerBonusRoll();
          }
        }
      }
    }
  }

  void _triggerBonusRoll() {
    // Player gets another turn after capture
    // This is handled in the nextTurn logic
  }

  @override
  bool checkGameEnd() {
    final winner = state.players.firstWhere(
      (player) => state.hasPlayerWon(player),
      orElse: () => Player(id: '', name: ''),
    );
    
    if (winner.id.isNotEmpty) {
      final updatedPlayers = state.players.map((player) {
        if (player.id == winner.id) {
          return player.copyWith(hasWon: true);
        }
        return player;
      }).toList();
      
      updateState(state.copyWith(
        players: updatedPlayers,
        status: GameStatus.finished,
        endedAt: DateTime.now(),
      ));
      
      return true;
    }
    
    return false;
  }

  @override
  void nextTurn() {
    final currentIndex = state.players.indexOf(state.currentPlayer!);
    final nextIndex = (currentIndex + 1) % state.players.length;
    final nextPlayer = state.players[nextIndex];
    
    updateState(state.copyWith(
      currentPlayer: nextPlayer,
      currentDiceValue: 1,
      selectedPieceIndex: null,
      validMoves: [],
    ));
    
    if (gameMode == 'vs-ai' && nextPlayer.type == PlayerType.ai) {
      _scheduleAIMove();
    }
  }

  void rollDice() {
    if (state.status != GameStatus.playing || state.isRolling) return;
    
    updateState(state.copyWith(isRolling: true));
    
    // Simulate dice rolling animation
    int rollCount = 0;
    const maxRolls = 10;
    const rollDuration = Duration(milliseconds: 100);
    
    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(rollDuration, (timer) {
      final randomValue = _random.nextInt(6) + 1;
      updateState(state.copyWith(currentDiceValue: randomValue));
      
      rollCount++;
      if (rollCount >= maxRolls) {
        timer.cancel();
        final finalValue = _random.nextInt(6) + 1;
        
        Future.delayed(const Duration(milliseconds: 200), () {
          updateState(state.copyWith(
            currentDiceValue: finalValue,
            isRolling: false,
          ));
          
          _updateValidMoves();
        });
      }
    });
  }

  void _updateValidMoves() {
    final pieces = state.getCurrentPlayerPieces();
    final diceValue = state.currentDiceValue;
    final validMoves = <int>[];
    
    for (int i = 0; i < pieces.length; i++) {
      final piece = pieces[i];
      final moves = state.getValidMovesForPiece(piece, diceValue);
      if (moves.isNotEmpty) {
        validMoves.add(i);
      }
    }
    
    updateState(state.copyWith(validMoves: validMoves));
  }

  void selectPiece(int pieceIndex) {
    if (!state.validMoves.contains(pieceIndex)) return;
    
    final pieces = state.getCurrentPlayerPieces();
    final piece = pieces[pieceIndex];
    final moves = state.getValidMovesForPiece(piece, state.currentDiceValue);
    
    if (moves.isNotEmpty) {
      updateState(state.copyWith(selectedPieceIndex: pieceIndex));
    }
  }

  void moveSelectedPiece() {
    if (state.selectedPieceIndex == null) return;
    
    final pieces = state.getCurrentPlayerPieces();
    final piece = pieces[state.selectedPieceIndex!];
    final moves = state.getValidMovesForPiece(piece, state.currentDiceValue);
    
    if (moves.isNotEmpty) {
      final move = {
        'pieceIndex': state.selectedPieceIndex,
        'newPosition': moves.first,
      };
      makeMove(move);
    }
  }

  void _scheduleAIMove() {
    _aiMoveTimer?.cancel();
    _aiMoveTimer = Timer(const Duration(milliseconds: 1500), () {
      rollDice();
      
      Future.delayed(const Duration(milliseconds: 2000), () {
        final bestMove = _ai.selectBestMove(state);
        if (bestMove != null) {
          makeMove(bestMove);
        } else {
          nextTurn();
        }
      });
    });
  }

  @override
  void resetGame() {
    _aiMoveTimer?.cancel();
    _animationTimer?.cancel();
    
    updateState(_createInitialState(state.players));
    
    onGameReset();
  }

  @override
  void dispose() {
    _aiMoveTimer?.cancel();
    _animationTimer?.cancel();
    super.dispose();
  }
}
