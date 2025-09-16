import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:board_game_moongi/src/core/game/game_controller.dart';
import 'package:board_game_moongi/src/core/game/player.dart';
import 'package:board_game_moongi/src/core/game/game_state.dart';
import 'package:board_game_moongi/src/features/snakes_ladders/data/models/snakes_ladders_state.dart';

class SnakesLaddersController extends GameController<SnakesLaddersState> {
  final String gameMode;
  final Random _random = Random();
  Timer? _aiMoveTimer;
  Timer? _animationTimer;

  SnakesLaddersController({
    required this.gameMode,
    required List<Player> players,
  }) : super(SnakesLaddersState(
          players: players,
          currentPlayer: players.first,
          playerPositions: List.filled(players.length, 1),
        ));

  @override
  bool isValidMove(dynamic move) {
    final diceValue = move as int;
    return state.status == GameStatus.playing &&
           state.currentPlayer != null &&
           !state.isRolling &&
           state.canPlayerMove(state.currentPlayer!, diceValue);
  }

  @override
  void processMove(dynamic move) {
    final diceValue = move as int;
    final currentPlayerIndex = state.players.indexOf(state.currentPlayer!);
    final currentPosition = state.playerPositions[currentPlayerIndex];
    final newPosition = state.getNextPosition(currentPosition, diceValue);
    
    final newPositions = List<int>.from(state.playerPositions);
    newPositions[currentPlayerIndex] = newPosition;
    
    updateState(state.copyWith(
      currentDiceValue: diceValue,
      playerPositions: newPositions,
    ));
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
          
          if (isValidMove(finalValue)) {
            makeMove(finalValue);
          } else {
            // Player can't move, skip turn
            nextTurn();
          }
        });
      }
    });
  }

  void _scheduleAIMove() {
    _aiMoveTimer?.cancel();
    _aiMoveTimer = Timer(const Duration(milliseconds: 1500), () {
      rollDice();
    });
  }

  @override
  void resetGame() {
    _aiMoveTimer?.cancel();
    _animationTimer?.cancel();
    
    updateState(SnakesLaddersState(
      players: state.players,
      currentPlayer: state.players.first,
      playerPositions: List.filled(state.players.length, 1),
    ));
    
    onGameReset();
  }

  @override
  void dispose() {
    _aiMoveTimer?.cancel();
    _animationTimer?.cancel();
    super.dispose();
  }
}
