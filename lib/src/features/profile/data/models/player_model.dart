import 'dart:convert';

class PlayerModel {
  
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

  PlayerModel({
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

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'totalGamesPlayed': totalGamesPlayed,
      'gamesWon': gamesWon,
      'ticTacToeWins': ticTacToeWins,
      'snakesLaddersWins': snakesLaddersWins,
      'ludoWins': ludoWins,
      'createdAt': createdAt.toIso8601String(),
      'lastPlayedAt': lastPlayedAt.toIso8601String(),
      'isCurrent': isCurrent,
    };
  }

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'],
      name: json['name'],
      avatar: json['avatar'],
      totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
      gamesWon: json['gamesWon'] ?? 0,
      ticTacToeWins: json['ticTacToeWins'] ?? 0,
      snakesLaddersWins: json['snakesLaddersWins'] ?? 0,
      ludoWins: json['ludoWins'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      lastPlayedAt: DateTime.parse(json['lastPlayedAt']),
      isCurrent: json['isCurrent'] ?? false,
    );
  }
}
