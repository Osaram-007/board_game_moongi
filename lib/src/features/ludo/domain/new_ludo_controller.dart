import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:board_game_moongi/src/core/game/game_controller.dart';
import 'package:board_game_moongi/src/core/game/game_state.dart';
import 'package:board_game_moongi/src/core/game/player.dart';
import '../data/models/new_ludo_state.dart';
import '../data/models/ludo_player.dart';
import '../data/models/ludo_token.dart';

class NewLudoController extends GameController<NewLudoState> {
  final Random _random = Random();
  Timer? _diceRollTimer;
  Timer? _aiMoveTimer;

  NewLudoController({
    required GameMode gameMode,
    DifficultyLevel difficulty = DifficultyLevel.medium,
  }) : super(NewLudoState.initial(gameMode: gameMode, difficulty: difficulty));

  @override
  void onGameStart() {
    // Game starts with first player's turn
    updateState(state.copyWith(
      status: GameStatus.playing,
      startedAt: DateTime.now(),
    ));
  }

  // Start the game
  @override
  Future<void> startGame() async {
    onGameStart();
  }

  // Roll dice with animation
  Future<void> rollDice() async {
    if (!state.canRollDice) return;

    // Start rolling animation
    updateState(state.copyWith(isRollingDice: true));

    // Simulate dice rolling animation
    int rollCount = 0;
    const maxRolls = 10;
    const rollDuration = Duration(milliseconds: 100);

    _diceRollTimer?.cancel();
    _diceRollTimer = Timer.periodic(rollDuration, (timer) {
      final randomValue = _random.nextInt(6) + 1;
      updateState(state.copyWith(diceValue: randomValue));

      rollCount++;
      if (rollCount >= maxRolls) {
        timer.cancel();
        _finalizeDiceRoll();
      }
    });
  }

  void _finalizeDiceRoll() {
    final finalValue = _random.nextInt(6) + 1;
    final newState = state.rollDice(finalValue);
    updateState(newState);

    // Check if AI should make a move
    if (newState.currentLudoPlayer.isAI && newState.canMove) {
      _scheduleAIMove();
    } else if (newState.movableTokens.isEmpty) {
      // No valid moves, end turn automatically
      Timer(const Duration(milliseconds: 1000), () {
        endTurn();
      });
    }
  }

  // Schedule AI move after a delay
  void _scheduleAIMove() {
    _aiMoveTimer?.cancel();
    _aiMoveTimer = Timer(const Duration(milliseconds: 1500), () {
      _makeAIMove();
    });
  }

  void _makeAIMove() {
    if (!state.currentLudoPlayer.isAI || state.movableTokens.isEmpty) return;

    final aiPlayer = state.currentLudoPlayer;
    final bestToken = aiPlayer.selectBestMove(state.movableTokens, state.diceValue);
    
    if (bestToken != null) {
      moveToken(bestToken);
    } else {
      endTurn();
    }
  }

  // Select token for movement
  void selectToken(LudoToken token) {
    if (!state.movableTokens.any((t) => t.id == token.id)) return;
    
    updateState(state.selectToken(token));
  }

  // Move token
  void moveToken(LudoToken token) {
    if (!state.movableTokens.any((t) => t.id == token.id)) return;

    final newState = state.moveToken(token, state.diceValue);
    updateState(newState);

    // Check for game end
    final endState = newState.checkGameEnd();
    if (endState.status == GameStatus.finished) {
      updateState(endState);
      return;
    }

    // End turn after a short delay
    Timer(const Duration(milliseconds: 500), () {
      endTurn();
    });
  }

  // End current turn
  void endTurn() {
    final newState = state.endTurn();
    updateState(newState);

    // If next player is AI, schedule their turn
    if (newState.currentLudoPlayer.isAI && newState.status == GameStatus.playing) {
      Timer(const Duration(milliseconds: 1000), () {
        if (state.canRollDice) {
          rollDice();
        }
      });
    }
  }

  // Get valid moves for current player and dice value
  List<LudoToken> getValidMoves(int diceValue) {
    return state.currentLudoPlayer.getAvailableTokens(diceValue);
  }

  // Check if token can move
  bool canMoveToken(LudoToken token, int diceValue) {
    return state.currentLudoPlayer.canMoveToken(token, diceValue);
  }

  // Get token at board position
  List<LudoToken> getTokensAt(int x, int y) {
    if (x < 0 || x >= 15 || y < 0 || y >= 15) return [];
    return state.board.grid[y][x].tokens;
  }

  // Check if position is safe
  bool isSafePosition(int x, int y) {
    if (x < 0 || x >= 15 || y < 0 || y >= 15) return false;
    return state.board.grid[y][x].hasStar;
  }

  // Get player color
  Color getPlayerColor(int playerId) {
    if (playerId < 0 || playerId >= state.ludoPlayers.length) return Colors.grey;
    return state.ludoPlayers[playerId].color;
  }

  // Get current player
  LudoPlayer getCurrentPlayer() {
    return state.currentLudoPlayer;
  }

  // Get all players
  List<LudoPlayer> getAllPlayers() {
    return state.ludoPlayers;
  }

  // Check if game is finished
  bool get isGameFinished => state.status == GameStatus.finished;

  // Get winner
  LudoPlayer? get winner => state.winner as LudoPlayer?;

  // Reset game
  @override
  void resetGame() {
    _diceRollTimer?.cancel();
    _aiMoveTimer?.cancel();

    final initialState = NewLudoState.initial(
      gameMode: state.gameMode,
      difficulty: state.difficulty,
    );
    
    updateState(initialState);
  }

  @override
  bool isValidMove(dynamic move) {
    if (move is! Map<String, dynamic>) return false;
    
    final tokenId = move['tokenId'] as String?;
    if (tokenId == null) return false;

    return state.movableTokens.any((token) => token.id == tokenId);
  }

  @override
  void makeMove(dynamic move) {
    if (!isValidMove(move)) return;
    
    final tokenId = move['tokenId'] as String;
    final token = state.movableTokens.firstWhere((t) => t.id == tokenId);
    
    moveToken(token);
  }

  @override
  void nextTurn() {
    endTurn();
  }

  @override
  bool checkGameEnd() {
    return state.hasWinner;
  }

  @override
  void processMove(dynamic move) {
    makeMove(move);
  }

  @override
  void dispose() {
    _diceRollTimer?.cancel();
    _aiMoveTimer?.cancel();
    super.dispose();
  }
}
