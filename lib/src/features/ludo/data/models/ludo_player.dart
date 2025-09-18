import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:board_game_moongi/src/core/game/player.dart';
import 'ludo_token.dart';

class LudoPlayer extends Player {
  final int playerId; // 0-3 for Red, Green, Blue, Yellow
  final Color color;
  final List<LudoToken> tokens;
  final int tokensHome;
  final int tokensActive;
  final int tokensFinished;

  const LudoPlayer({
    required this.playerId,
    required String name,
    required this.color,
    required this.tokens,
    bool isAI = false,
    this.tokensHome = 4,
    this.tokensActive = 0,
    this.tokensFinished = 0,
    bool hasWon = false,
  }) : super(
    id: 'player_$playerId',
    name: name,
    type: isAI ? PlayerType.ai : PlayerType.human,
    hasWon: hasWon,
    gameData: const {},
  );

  // Create initial player with 4 tokens in home
  factory LudoPlayer.create({
    required int playerId,
    required String name,
    required Color color,
    bool isAI = false,
  }) {
    // Get home positions for this player
    final homePositions = _getHomePositions(playerId);
    
    final tokens = List.generate(4, (index) {
      final homePos = homePositions[index];
      return LudoToken(
        id: '${playerId}_$index',
        playerId: playerId,
        color: color,
        state: TokenState.home,
        boardX: homePos[0],
        boardY: homePos[1],
      );
    });

    return LudoPlayer(
      playerId: playerId,
      name: name,
      color: color,
      tokens: tokens,
      isAI: isAI,
      tokensHome: 4,
    );
  }

  // Get home positions for a player
  static List<List<int>> _getHomePositions(int playerId) {
    switch (playerId) {
      case 0: // Red - top-left
        return [[1, 1], [1, 2], [2, 1], [2, 2]];
      case 1: // Green - top-right
        return [[12, 1], [12, 2], [13, 1], [13, 2]];
      case 2: // Blue - bottom-right
        return [[12, 12], [12, 13], [13, 12], [13, 13]];
      case 3: // Yellow - bottom-left
        return [[1, 12], [1, 13], [2, 12], [2, 13]];
      default:
        return [[1, 1], [1, 2], [2, 1], [2, 2]];
    }
  }

  @override
  LudoPlayer copyWith({
    String? id,
    String? name,
    PlayerType? type,
    String? avatar,
    int? score,
    bool? isActive,
    bool? hasWon,
    Map<String, dynamic>? gameData,
    int? playerId,
    Color? color,
    List<LudoToken>? tokens,
    bool? isAI,
    int? tokensHome,
    int? tokensActive,
    int? tokensFinished,
  }) {
    return LudoPlayer(
      playerId: playerId ?? this.playerId,
      name: name ?? this.name,
      color: color ?? this.color,
      tokens: tokens ?? this.tokens,
      isAI: isAI ?? (type ?? this.type) == PlayerType.ai,
      tokensHome: tokensHome ?? this.tokensHome,
      tokensActive: tokensActive ?? this.tokensActive,
      tokensFinished: tokensFinished ?? this.tokensFinished,
      hasWon: hasWon ?? this.hasWon,
    );
  }

  // Helper getter for AI status
  bool get isAI => type == PlayerType.ai;

  // Update player with new token states
  LudoPlayer updateTokens(List<LudoToken> newTokens) {
    final homeCount = newTokens.where((t) => t.state == TokenState.home).length;
    final activeCount = newTokens.where((t) => t.state == TokenState.active || t.state == TokenState.safe).length;
    final finishedCount = newTokens.where((t) => t.state == TokenState.finished).length;
    
    return copyWith(
      tokens: newTokens,
      tokensHome: homeCount,
      tokensActive: activeCount,
      tokensFinished: finishedCount,
      hasWon: finishedCount == 4,
    );
  }

  // Get tokens that can move with given dice value
  List<LudoToken> getAvailableTokens(int diceValue) {
    List<LudoToken> availableTokens = [];

    for (final token in tokens) {
      if (canMoveToken(token, diceValue)) {
        availableTokens.add(token.copyWith(canMove: true));
      }
    }

    return availableTokens;
  }

  // Check if a token can move with given dice value
  bool canMoveToken(LudoToken token, int diceValue) {
    switch (token.state) {
      case TokenState.home:
        // Can only move out of home with a 6
        return diceValue == 6;
      
      case TokenState.active:
      case TokenState.safe:
        // Can move if won't go past finish line
        return token.pathIndex + diceValue <= 57;
      
      case TokenState.finished:
        // Finished tokens cannot move
        return false;
    }
  }

  // AI move selection (basic implementation)
  LudoToken? selectBestMove(List<LudoToken> availableTokens, int diceValue) {
    if (!isAI || availableTokens.isEmpty) return null;

    // Simple AI strategy: prioritize by preference
    // 1. Move tokens out of home
    // 2. Move tokens closest to finish
    // 3. Capture opponent tokens (TODO: implement capture detection)
    
    // First, try to move tokens out of home
    final homeTokens = availableTokens.where((t) => t.state == TokenState.home).toList();
    if (homeTokens.isNotEmpty && diceValue == 6) {
      return homeTokens.first;
    }

    // Then, move tokens closest to finish
    final activeTokens = availableTokens.where((t) => t.state != TokenState.home).toList();
    if (activeTokens.isNotEmpty) {
      activeTokens.sort((a, b) => b.pathIndex.compareTo(a.pathIndex));
      return activeTokens.first;
    }

    return availableTokens.first;
  }

  // Get starting position coordinates for this player
  List<int> getStartPosition() {
    switch (playerId) {
      case 0: return [1, 6]; // Red
      case 1: return [8, 1]; // Green  
      case 2: return [13, 8]; // Blue
      case 3: return [6, 13]; // Yellow
      default: return [1, 6];
    }
  }

  // Get home area coordinates for this player
  List<List<int>> getHomePositions() {
    switch (playerId) {
      case 0: // Red - top-left
        return [[1, 1], [1, 2], [2, 1], [2, 2]];
      case 1: // Green - top-right
        return [[12, 1], [12, 2], [13, 1], [13, 2]];
      case 2: // Blue - bottom-right
        return [[12, 12], [12, 13], [13, 12], [13, 13]];
      case 3: // Yellow - bottom-left
        return [[1, 12], [1, 13], [2, 12], [2, 13]];
      default:
        return [[1, 1], [1, 2], [2, 1], [2, 2]];
    }
  }

  @override
  List<Object?> get props => [
    ...super.props,
    playerId, color, tokens,
    tokensHome, tokensActive, tokensFinished
  ];
}
