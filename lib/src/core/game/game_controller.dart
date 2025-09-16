import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:board_game_moongi/src/core/game/game_state.dart';
import 'package:board_game_moongi/src/core/game/player.dart';

abstract class GameController<T extends GameState> extends ChangeNotifier {
  T _state;
  Timer? _gameTimer;
  
  GameController(T initialState) : _state = initialState;

  T get state => _state;
  
  void updateState(T newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> startGame() async {
    if (_state.status != GameStatus.waiting) return;
    
    updateState(_state.copyWith(
      status: GameStatus.playing,
      startedAt: DateTime.now(),
    ) as T);
    
    _startGameTimer();
    onGameStart();
  }

  Future<void> pauseGame() async {
    if (_state.status != GameStatus.playing) return;
    
    updateState(_state.copyWith(
      status: GameStatus.paused,
    ) as T);
    
    _stopGameTimer();
    onGamePause();
  }

  Future<void> resumeGame() async {
    if (_state.status != GameStatus.paused) return;
    
    updateState(_state.copyWith(
      status: GameStatus.playing,
    ) as T);
    
    _startGameTimer();
    onGameResume();
  }

  Future<void> endGame() async {
    _stopGameTimer();
    
    updateState(_state.copyWith(
      status: GameStatus.finished,
      endedAt: DateTime.now(),
    ) as T);
    
    onGameEnd();
  }

  void resetGame() {
    _stopGameTimer();
    onGameReset();
  }

  void makeMove(dynamic move) {
    if (_state.status != GameStatus.playing) return;
    
    if (isValidMove(move)) {
      processMove(move);
      onMoveMade(move);
      
      if (checkGameEnd()) {
        endGame();
      } else {
        nextTurn();
      }
    }
  }

  bool isValidMove(dynamic move);
  void processMove(dynamic move);
  bool checkGameEnd();
  void nextTurn();

  // Lifecycle hooks
  void onGameStart() {}
  void onGamePause() {}
  void onGameResume() {}
  void onGameEnd() {}
  void onGameReset() {}
  void onMoveMade(dynamic move) {}

  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      onGameTick();
    });
  }

  void _stopGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  void onGameTick() {}

  @override
  void dispose() {
    _stopGameTimer();
    super.dispose();
  }
}
