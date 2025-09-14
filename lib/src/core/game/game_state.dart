import 'package:equatable/equatable.dart';
import 'package:board_game_moongi/src/core/game/player.dart';

abstract class GameState extends Equatable {
  final List<Player> players;
  final Player? currentPlayer;
  final GameStatus status;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final Map<String, dynamic> metadata;

  const GameState({
    required this.players,
    this.currentPlayer,
    this.status = GameStatus.waiting,
    this.startedAt,
    this.endedAt,
    this.metadata = const {},
  });

  GameState copyWith({
    List<Player>? players,
    Player? currentPlayer,
    GameStatus? status,
    DateTime? startedAt,
    DateTime? endedAt,
    Map<String, dynamic>? metadata,
  });

  bool get isGameOver => status == GameStatus.finished || status == GameStatus.abandoned;
  
  Player? get winner {
    if (!isGameOver) return null;
    return players.firstWhere(
      (player) => player.hasWon,
      orElse: () => players.first,
    );
  }

  @override
  List<Object?> get props => [
        players,
        currentPlayer,
        status,
        startedAt,
        endedAt,
        metadata,
      ];
}

enum GameStatus {
  waiting,
  playing,
  paused,
  finished,
  abandoned,
}
