import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:board_game_moongi/src/core/game/game_controller.dart';
import 'package:board_game_moongi/src/core/game/player.dart';
import 'package:board_game_moongi/src/core/game/game_state.dart';
import 'package:board_game_moongi/src/features/tic_tac_toe/data/models/tic_tac_toe_state.dart';
import 'package:board_game_moongi/src/features/tic_tac_toe/data/ai/tic_tac_toe_ai.dart';

class TicTacToeController extends GameController<TicTacToeState> {
  final String gameMode;
  final Player humanPlayer;
  final Player aiPlayer;
  late final TicTacToeAI _ai;
  Timer? _aiMoveTimer;

  TicTacToeController({
    required this.gameMode,
    required this.humanPlayer,
    required this.aiPlayer,
  }) : super(TicTacToeState(
          players: [humanPlayer, aiPlayer],
          currentPlayer: humanPlayer,
        )) {
    _ai = TicTacToeAI(
      aiPlayer: aiPlayer,
      aiSymbol: 'O',
      humanSymbol: 'X',
      maxDepth: 9,
      difficulty: 0.9,
    );
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
           state.isCellEmpty(row, col) &&
           state.currentPlayer == humanPlayer;
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
      final winningPlayer = winner == 'X' ? humanPlayer : aiPlayer;
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
    if (gameMode == 'vs-ai' && state.currentPlayer == aiPlayer) {
      _scheduleAIMove();
    }
  }

  void _scheduleAIMove() {
    _aiMoveTimer?.cancel();
    _aiMoveTimer = Timer(const Duration(milliseconds: 500), () {
      _makeAIMove();
    });
  }

  void _makeAIMove() {
    if (state.status != GameStatus.playing || state.currentPlayer != aiPlayer) {
      return;
    }

    final bestMove = _ai.getBestMove(state);
    if (bestMove != null) {
      makeMove(bestMove);
    }
  }

  void resetGame() {
    _aiMoveTimer?.cancel();
    
    updateState(TicTacToeState(
      players: [humanPlayer, aiPlayer],
      currentPlayer: humanPlayer,
    ));
    
    onGameReset();
  }

  @override
  void dispose() {
    _aiMoveTimer?.cancel();
    super.dispose();
  }
}
