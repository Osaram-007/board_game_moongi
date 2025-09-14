import 'package:board_game_moongi/src/core/game/game_state.dart';
import 'package:board_game_moongi/src/core/game/player.dart';

class SnakesLaddersState extends GameState {
  final List<int> playerPositions;
  final int currentDiceValue;
  final bool isRolling;
  final List<Snake> snakes;
  final List<Ladder> ladders;
  final int boardSize;

  static const List<Snake> _defaultSnakes = [
    Snake(start: 16, end: 6),
    Snake(start: 47, end: 26),
    Snake(start: 49, end: 11),
    Snake(start: 56, end: 53),
    Snake(start: 62, end: 19),
    Snake(start: 64, end: 60),
    Snake(start: 87, end: 24),
    Snake(start: 93, end: 73),
    Snake(start: 95, end: 75),
    Snake(start: 98, end: 78),
  ];

  static const List<Ladder> _defaultLadders = [
    Ladder(start: 1, end: 38),
    Ladder(start: 4, end: 14),
    Ladder(start: 9, end: 31),
    Ladder(start: 21, end: 42),
    Ladder(start: 28, end: 84),
    Ladder(start: 36, end: 44),
    Ladder(start: 51, end: 67),
    Ladder(start: 71, end: 91),
    Ladder(start: 80, end: 100),
  ];

  const SnakesLaddersState({
    required super.players,
    super.currentPlayer,
    super.status = GameStatus.waiting,
    super.startedAt,
    super.endedAt,
    super.metadata = const {},
    this.playerPositions = const [],
    this.currentDiceValue = 1,
    this.isRolling = false,
    this.boardSize = 100,
  }) : snakes = _defaultSnakes, ladders = _defaultLadders;

  const SnakesLaddersState.withPositions({
    required super.players,
    required this.playerPositions,
    required this.snakes,
    required this.ladders,
    super.currentPlayer,
    super.status = GameStatus.waiting,
    super.startedAt,
    super.endedAt,
    super.metadata = const {},
    this.currentDiceValue = 1,
    this.isRolling = false,
    this.boardSize = 100,
  });

  @override
  SnakesLaddersState copyWith({
    List<Player>? players,
    Player? currentPlayer,
    GameStatus? status,
    DateTime? startedAt,
    DateTime? endedAt,
    Map<String, dynamic>? metadata,
    List<int>? playerPositions,
    int? currentDiceValue,
    bool? isRolling,
    List<Snake>? snakes,
    List<Ladder>? ladders,
    int? boardSize,
  }) {
    return SnakesLaddersState.withPositions(
      players: players ?? this.players,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      metadata: metadata ?? this.metadata,
      playerPositions: playerPositions ?? this.playerPositions,
      currentDiceValue: currentDiceValue ?? this.currentDiceValue,
      isRolling: isRolling ?? this.isRolling,
      snakes: snakes ?? this.snakes,
      ladders: ladders ?? this.ladders,
      boardSize: boardSize ?? this.boardSize,
    );
  }

  int getPlayerPosition(Player player) {
    final index = players.indexOf(player);
    return index >= 0 && index < playerPositions.length 
        ? playerPositions[index] 
        : 1;
  }

  int getNextPosition(int currentPosition, int diceValue) {
    int newPosition = currentPosition + diceValue;
    
    if (newPosition > boardSize) {
      return currentPosition;
    }
    
    // Check for snakes
    for (final snake in snakes) {
      if (newPosition == snake.start) {
        return snake.end;
      }
    }
    
    // Check for ladders
    for (final ladder in ladders) {
      if (newPosition == ladder.start) {
        return ladder.end;
      }
    }
    
    return newPosition;
  }

  bool hasPlayerWon(Player player) {
    final position = getPlayerPosition(player);
    return position == boardSize;
  }

  bool canPlayerMove(Player player, int diceValue) {
    final currentPosition = getPlayerPosition(player);
    return currentPosition + diceValue <= boardSize;
  }

  @override
  List<Object?> get props => [
        ...super.props,
        playerPositions,
        currentDiceValue,
        isRolling,
        snakes,
        ladders,
        boardSize,
      ];
}

class Snake {
  final int start;
  final int end;

  const Snake({
    required this.start,
    required this.end,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Snake && other.start == start && other.end == end;
  }

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}

class Ladder {
  final int start;
  final int end;

  const Ladder({
    required this.start,
    required this.end,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ladder && other.start == start && other.end == end;
  }

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}
