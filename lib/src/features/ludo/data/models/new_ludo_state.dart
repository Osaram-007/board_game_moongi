import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:board_game_moongi/src/core/game/game_state.dart';
import 'package:board_game_moongi/src/core/game/player.dart';
import 'ludo_board.dart';
import 'ludo_player.dart';
import 'ludo_token.dart';

enum GameMode {
  singlePlayer,
  multiPlayer,
}

enum DifficultyLevel {
  easy,
  medium,
  hard,
}

class NewLudoState extends GameState {
  final LudoBoard board;
  final List<LudoPlayer> ludoPlayers;
  final int currentPlayerIndex;
  final int diceValue;
  final bool isDiceRolled;
  final bool isRollingDice;
  final GameMode gameMode;
  final DifficultyLevel difficulty;
  final List<LudoToken> movableTokens;
  final LudoToken? selectedToken;
  final bool waitingForMove;
  final int turnCount;
  final bool hasExtraTurn; // When player rolls 6

  const NewLudoState({
    required super.players,
    super.currentPlayer,
    super.status = GameStatus.waiting,
    super.startedAt,
    super.endedAt,
    super.metadata = const {},
    required this.board,
    required this.ludoPlayers,
    this.currentPlayerIndex = 0,
    this.diceValue = 1,
    this.isDiceRolled = false,
    this.isRollingDice = false,
    this.gameMode = GameMode.singlePlayer,
    this.difficulty = DifficultyLevel.medium,
    this.movableTokens = const [],
    this.selectedToken,
    this.waitingForMove = false,
    this.turnCount = 0,
    this.hasExtraTurn = false,
  });

  // Create initial game state
  factory NewLudoState.initial({
    required GameMode gameMode,
    DifficultyLevel difficulty = DifficultyLevel.medium,
  }) {
    final board = LudoBoard.initialize();
    
    // Create players
    final ludoPlayers = [
      LudoPlayer.create(playerId: 0, name: 'Red', color: Colors.red),
      LudoPlayer.create(playerId: 1, name: 'Green', color: Colors.green, isAI: gameMode == GameMode.singlePlayer),
      LudoPlayer.create(playerId: 2, name: 'Blue', color: Colors.blue, isAI: gameMode == GameMode.singlePlayer),
      LudoPlayer.create(playerId: 3, name: 'Yellow', color: Colors.yellow, isAI: gameMode == GameMode.singlePlayer),
    ];

    // Convert to base Player objects for parent class
    final basePlayers = ludoPlayers.map((p) => Player(
      id: p.playerId.toString(),
      name: p.name,
      type: p.isAI ? PlayerType.ai : PlayerType.human,
    )).toList();

    // Update board with initial token positions
    final boardWithTokens = board.updateTokenPositions(ludoPlayers);

    return NewLudoState(
      players: basePlayers,
      currentPlayer: basePlayers.first,
      board: boardWithTokens,
      ludoPlayers: ludoPlayers,
      gameMode: gameMode,
      difficulty: difficulty,
    );
  }

  NewLudoState copyWith({
    List<Player>? players,
    Player? currentPlayer,
    GameStatus? status,
    DateTime? startedAt,
    DateTime? endedAt,
    Map<String, dynamic>? metadata,
    LudoBoard? board,
    List<LudoPlayer>? ludoPlayers,
    int? currentPlayerIndex,
    int? diceValue,
    bool? isDiceRolled,
    bool? isRollingDice,
    GameMode? gameMode,
    DifficultyLevel? difficulty,
    List<LudoToken>? movableTokens,
    LudoToken? selectedToken,
    bool? waitingForMove,
    int? turnCount,
    bool? hasExtraTurn,
  }) {
    return NewLudoState(
      players: players ?? this.players,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      metadata: metadata ?? this.metadata,
      board: board ?? this.board,
      ludoPlayers: ludoPlayers ?? this.ludoPlayers,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      diceValue: diceValue ?? this.diceValue,
      isDiceRolled: isDiceRolled ?? this.isDiceRolled,
      isRollingDice: isRollingDice ?? this.isRollingDice,
      gameMode: gameMode ?? this.gameMode,
      difficulty: difficulty ?? this.difficulty,
      movableTokens: movableTokens ?? this.movableTokens,
      selectedToken: selectedToken ?? this.selectedToken,
      waitingForMove: waitingForMove ?? this.waitingForMove,
      turnCount: turnCount ?? this.turnCount,
      hasExtraTurn: hasExtraTurn ?? this.hasExtraTurn,
    );
  }

  // Get current Ludo player
  LudoPlayer get currentLudoPlayer => ludoPlayers[currentPlayerIndex];

  // Check if current player can roll dice
  bool get canRollDice => !isDiceRolled && !isRollingDice && status == GameStatus.playing;

  // Check if current player can move
  bool get canMove => isDiceRolled && movableTokens.isNotEmpty && !waitingForMove;

  // Check if any player has won
  bool get hasWinner => ludoPlayers.any((p) => p.hasWon);

  // Get winner if game is finished
  @override
  Player? get winner => ludoPlayers.where((p) => p.hasWon).firstOrNull;

  // Roll dice and update movable tokens
  NewLudoState rollDice(int newDiceValue) {
    final currentPlayer = ludoPlayers[currentPlayerIndex];
    final availableTokens = currentPlayer.getAvailableTokens(newDiceValue);
    
    return copyWith(
      diceValue: newDiceValue,
      isDiceRolled: true,
      isRollingDice: false,
      movableTokens: availableTokens,
      waitingForMove: availableTokens.isNotEmpty,
      hasExtraTurn: newDiceValue == 6,
    );
  }

  // Select token for movement
  NewLudoState selectToken(LudoToken token) {
    if (!movableTokens.contains(token)) return this;
    
    return copyWith(selectedToken: token);
  }

  // Move selected token
  NewLudoState moveToken(LudoToken token, int steps) {
    final currentPlayer = ludoPlayers[currentPlayerIndex];
    final tokenIndex = currentPlayer.tokens.indexWhere((t) => t.id == token.id);
    if (tokenIndex == -1) return this;

    // Calculate new position
    int newPathIndex = token.pathIndex;
    int newX = token.boardX;
    int newY = token.boardY;

    if (token.state == TokenState.home && steps == 6) {
      // Move token from home to start position
      final startPos = currentPlayer.getStartPosition();
      newPathIndex = 0;
      newX = startPos[0];
      newY = startPos[1];
    } else if (token.state != TokenState.home) {
      // Move token along path
      newPathIndex = token.pathIndex + steps;
      // Calculate new board coordinates (simplified)
      final pathCoords = board.playerPaths[currentPlayerIndex];
      if (newPathIndex < pathCoords.length) {
        final coord = pathCoords[newPathIndex];
        newX = coord[0];
        newY = coord[1];
      }
    }

    // Update token
    final updatedToken = token.moveTo(newPathIndex, newX, newY);
    
    // Update player's tokens
    final updatedTokens = [...currentPlayer.tokens];
    updatedTokens[tokenIndex] = updatedToken;
    final updatedPlayer = currentPlayer.updateTokens(updatedTokens);
    
    // Update all players
    final updatedPlayers = [...ludoPlayers];
    updatedPlayers[currentPlayerIndex] = updatedPlayer;
    
    // Update board with new positions
    final updatedBoard = board.updateTokenPositions(updatedPlayers);
    
    // Check for captures (simplified)
    final capturedState = _processCaptures(updatedBoard, updatedPlayers, updatedToken);
    
    return copyWith(
      board: capturedState.board,
      ludoPlayers: capturedState.players,
      selectedToken: null,
      waitingForMove: false,
      isDiceRolled: false,
    );
  }

  // Process token captures
  ({LudoBoard board, List<LudoPlayer> players}) _processCaptures(
    LudoBoard board, 
    List<LudoPlayer> players, 
    LudoToken movedToken
  ) {
    // Check if moved token landed on opponent's token
    final cell = board.grid[movedToken.boardY][movedToken.boardX];
    
    if (cell.hasStar) {
      // Safe square - no captures
      return (board: board, players: players);
    }

    // Find opponent tokens on same cell
    final opponentTokens = cell.tokens.where((t) => 
      t.playerId != movedToken.playerId && t.state != TokenState.finished
    ).toList();

    if (opponentTokens.isEmpty) {
      return (board: board, players: players);
    }

    // Send opponent tokens home
    List<LudoPlayer> updatedPlayers = [...players];
    
    for (final opponentToken in opponentTokens) {
      final playerIndex = opponentToken.playerId;
      final player = updatedPlayers[playerIndex];
      final tokenIndex = player.tokens.indexWhere((t) => t.id == opponentToken.id);
      
      if (tokenIndex != -1) {
        final updatedTokens = [...player.tokens];
        updatedTokens[tokenIndex] = opponentToken.returnHome();
        updatedPlayers[playerIndex] = player.updateTokens(updatedTokens);
      }
    }

    final updatedBoard = board.updateTokenPositions(updatedPlayers);
    return (board: updatedBoard, players: updatedPlayers);
  }

  // End current turn and switch to next player
  NewLudoState endTurn() {
    if (hasExtraTurn) {
      // Player gets another turn for rolling 6
      return copyWith(
        isDiceRolled: false,
        movableTokens: [],
        selectedToken: null,
        waitingForMove: false,
        hasExtraTurn: false,
      );
    }

    // Switch to next player
    int nextPlayerIndex = (currentPlayerIndex + 1) % ludoPlayers.length;
    final nextPlayer = players[nextPlayerIndex];
    
    return copyWith(
      currentPlayerIndex: nextPlayerIndex,
      currentPlayer: nextPlayer,
      isDiceRolled: false,
      movableTokens: [],
      selectedToken: null,
      waitingForMove: false,
      hasExtraTurn: false,
      turnCount: turnCount + 1,
    );
  }

  // Check if game should end
  NewLudoState checkGameEnd() {
    final winner = ludoPlayers.where((p) => p.hasWon).firstOrNull;
    
    if (winner != null) {
      return copyWith(
        status: GameStatus.finished,
        endedAt: DateTime.now(),
      );
    }
    
    return this;
  }

  @override
  List<Object?> get props => [
    ...super.props,
    board,
    ludoPlayers,
    currentPlayerIndex,
    diceValue,
    isDiceRolled,
    isRollingDice,
    gameMode,
    difficulty,
    movableTokens,
    selectedToken,
    waitingForMove,
    turnCount,
    hasExtraTurn,
  ];
}
