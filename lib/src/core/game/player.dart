import 'package:equatable/equatable.dart';

class Player extends Equatable {
  final String id;
  final String name;
  final PlayerType type;
  final String? avatar;
  final int score;
  final bool isActive;
  final bool hasWon;
  final Map<String, dynamic> gameData;

  const Player({
    required this.id,
    required this.name,
    this.type = PlayerType.human,
    this.avatar,
    this.score = 0,
    this.isActive = true,
    this.hasWon = false,
    this.gameData = const {},
  });

  Player copyWith({
    String? id,
    String? name,
    PlayerType? type,
    String? avatar,
    int? score,
    bool? isActive,
    bool? hasWon,
    Map<String, dynamic>? gameData,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      avatar: avatar ?? this.avatar,
      score: score ?? this.score,
      isActive: isActive ?? this.isActive,
      hasWon: hasWon ?? this.hasWon,
      gameData: gameData ?? this.gameData,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        avatar,
        score,
        isActive,
        hasWon,
        gameData,
      ];
}

enum PlayerType {
  human,
  ai,
}
