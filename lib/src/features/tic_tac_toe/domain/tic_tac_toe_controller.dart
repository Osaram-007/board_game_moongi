import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:board_game_moongi/src/core/game/game_controller.dart';
import 'package:board_game_moongi/src/core/game/player.dart';
import 'package:board_game_moongi/src/core/game/game_state.dart';
import 'package:board_game_moongi/src/features/tic_tac_toe/data/models/tic_tac_toe_state.dart';
import 'package:board_game_moongi/src/features/tic_tac_toe/data/ai/tic_tac_toe_ai.dart';

export 'package:board_game_moongi/src/features/tic_tac_toe/data/ai/tic_tac_toe_ai.dart' show AIDifficulty;

class TicTacToeController extends GameController<TicTacToeState> {
  final String gameMode;
  final Player player1;
  final Player player2;
  late TicTacToeAI? _ai;
  Timer? _aiMoveTimer;
  AIDifficulty _currentDifficulty;

  TicTacToeController({
    required this.gameMode,
    required this.player1,
    required this.player2,
    AIDifficulty difficulty = AIDifficulty.hard,
  })  : _currentDifficulty = difficulty,
        super(TicTacToeState(
          players: [player1, player2],
          currentPlayer: player1,
        )) {
    if (gameMode == 'vs-ai') {
      _initializeAI();
    } else {
      _ai = null;
    }
  }

  // Getters for backward compatibility
  Player get humanPlayer => player1;
  Player get aiPlayer => player2;

  AIDifficulty get currentDifficulty => _currentDifficulty;

  void _initializeAI() {
    if (gameMode == 'vs-ai') {
      _ai = TicTacToeAI(
        aiPlayer: player2,
        aiSymbol: 'O',
        humanSymbol: 'X',
        difficultyLevel: _currentDifficulty,
        maxDepth: 9,
        difficulty: 0.9,
      );
    }
  }

  void setDifficulty(AIDifficulty difficulty) {
    if (_currentDifficulty != difficulty) {
      _currentDifficulty = difficulty;
      _initializeAI();
      notifyListeners();
    }
  }

  String getSymbolForPlayer(Player player) {
    return player == humanPlayer ? 'X' : 'O';
  }

  @override
  bool isValidMove(dynamic move) {
    final moveMap = move as Map<String, int>;
    final row = moveMap['row']!;
    final col = moveMap['col']!;
    
    return state.status == GameStatus.playing &&
           state.isCellEmpty(row, col);
  }

  @override
  void processMove(dynamic move) {
    final moveMap = move as Map<String, int>;
    final newBoard = List<List<String?>>.generate(
      3,
      (i) => List<String?>.from(state.board[i]),
    );
    
    newBoard[moveMap['row']!][moveMap['col']!] = getSymbolForPlayer(state.currentPlayer!);
    
    final nextPlayer = state.currentPlayer == humanPlayer ? aiPlayer : humanPlayer;
    
    updateState(state.copyWith(
      board: newBoard,
      currentPlayer: nextPlayer,
    ));
  }

  @override
  bool checkGameEnd() {
    final winner = state.getWinner();
    
    if (winner != null) {
      final winningPlayer = winner == 'X' ? player1 : player2;
      final updatedPlayers = state.players.map((player) {
        if (player.id == winningPlayer.id) {
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
    
    if (state.isBoardFull()) {
      updateState(state.copyWith(
        status: GameStatus.finished,
        endedAt: DateTime.now(),
      ));
      return true;
    }
    
    return false;
  }

  @override
  void nextTurn() {
    print('DEBUG: nextTurn called - gameMode: $gameMode, currentPlayer: ${state.currentPlayer?.name}');
    if (gameMode == 'vs-ai' && state.currentPlayer == player2) {
      print('DEBUG: Scheduling AI move');
      _scheduleAIMove();
    }
    // In multiplayer mode, do nothing - wait for human input
  }

  void _scheduleAIMove() {
    _aiMoveTimer?.cancel();
    _aiMoveTimer = Timer(const Duration(milliseconds: 500), () {
      _makeAIMove();
    });
  }

  void _makeAIMove() {
    print('DEBUG: _makeAIMove called - status: ${state.status}, currentPlayer: ${state.currentPlayer?.name}');
    if (state.status != GameStatus.playing || state.currentPlayer != player2) {
      print('DEBUG: AI move cancelled - invalid state');
      return;
    }

    if (_ai != null) {
      final bestMove = _ai!.getBestMove(state);
      print('DEBUG: AI best move: $bestMove');
      if (bestMove != null) {
        makeMove(bestMove);
      }
    }
  }

  void resetGame() {
    _aiMoveTimer?.cancel();
    
    updateState(TicTacToeState(
      players: [player1, player2],
      currentPlayer: player1,
    ));
    
    onGameReset();
  }

  String getDifficultyDisplayName() {
    switch (_currentDifficulty) {
      case AIDifficulty.easy:
        return 'Easy';
      case AIDifficulty.hard:
        return 'Hard';
      case AIDifficulty.extreme:
        return 'Extreme';
    }
  }

  @override
  void dispose() {
    _aiMoveTimer?.cancel();
    super.dispose();
  }
}
