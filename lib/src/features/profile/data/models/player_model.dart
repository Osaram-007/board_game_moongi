import 'package:isar/isar.dart';

part 'player_model.g.dart';

@collection
class PlayerModel {
  Id get isarId => fastHash(id);
  
  final String id;
  final String name;
  final String? avatar;
  final int totalGamesPlayed;
  final int gamesWon;
  final int ticTacToeWins;
  final int snakesLaddersWins;
  final int ludoWins;
  final DateTime createdAt;
  final DateTime lastPlayedAt;
  final bool isCurrent;

  const PlayerModel({
    required this.id,
    required this.name,
    this.avatar,
    this.totalGamesPlayed = 0,
    this.gamesWon = 0,
    this.ticTacToeWins = 0,
    this.snakesLaddersWins = 0,
    this.ludoWins = 0,
    required this.createdAt,
    required this.lastPlayedAt,
    this.isCurrent = false,
  });

  PlayerModel copyWith({
    String? id,
    String? name,
    String? avatar,
    int? totalGamesPlayed,
    int? gamesWon,
    int? ticTacToeWins,
    int? snakesLaddersWins,
    int? ludoWins,
    DateTime? createdAt,
    DateTime? lastPlayedAt,
    bool? isCurrent,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      ticTacToeWins: ticTacToeWins ?? this.ticTacToeWins,
      snakesLaddersWins: snakesLaddersWins ?? this.snakesLaddersWins,
      ludoWins: ludoWins ?? this.ludoWins,
      createdAt: createdAt ?? this.createdAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }

  double get winRate => totalGamesPlayed > 0 ? gamesWon / totalGamesPlayed : 0.0;

  static int fastHash(String string) {
    var hash = 0xcbf29ce484222325;
    var i = 0;
    while (i < string.length) {
      final codeUnit = string.codeUnitAt(i++);
      hash ^= codeUnit >> 8;
      hash *= 0x100000001b3;
      hash ^= codeUnit & 0xFF;
      hash *= 0x100000001b3;
    }
    return hash;
  }
}
