import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

enum TokenState {
  home,
  active,
  safe,
  finished,
}

class LudoToken extends Equatable {
  final String id;
  final int playerId;
  final Color color;
  final TokenState state;
  final int pathIndex; // Position along the movement path (0-57)
  final int boardX; // X coordinate on 15x15 grid
  final int boardY; // Y coordinate on 15x15 grid
  final bool isAtStart; // Whether token is at starting position
  final bool canMove; // Whether token can move with current dice value

  const LudoToken({
    required this.id,
    required this.playerId,
    required this.color,
    this.state = TokenState.home,
    this.pathIndex = -1,
    this.boardX = -1,
    this.boardY = -1,
    this.isAtStart = false,
    this.canMove = false,
  });

  LudoToken copyWith({
    String? id,
    int? playerId,
    Color? color,
    TokenState? state,
    int? pathIndex,
    int? boardX,
    int? boardY,
    bool? isAtStart,
    bool? canMove,
  }) {
    return LudoToken(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      color: color ?? this.color,
      state: state ?? this.state,
      pathIndex: pathIndex ?? this.pathIndex,
      boardX: boardX ?? this.boardX,
      boardY: boardY ?? this.boardY,
      isAtStart: isAtStart ?? this.isAtStart,
      canMove: canMove ?? this.canMove,
    );
  }

  // Move token to new position
  LudoToken moveTo(int newPathIndex, int newX, int newY) {
    TokenState newState = TokenState.active;
    
    // Determine new state based on position
    if (newPathIndex >= 57) {
      newState = TokenState.finished;
    } else if (_isSafeSquare(newX, newY)) {
      newState = TokenState.safe;
    }

    return copyWith(
      pathIndex: newPathIndex,
      boardX: newX,
      boardY: newY,
      state: newState,
      isAtStart: newPathIndex == 0,
    );
  }

  // Return token to home
  LudoToken returnHome() {
    return copyWith(
      state: TokenState.home,
      pathIndex: -1,
      boardX: -1,
      boardY: -1,
      isAtStart: false,
    );
  }

  // Check if position is a safe square
  bool _isSafeSquare(int x, int y) {
    // Safe squares are marked with stars in the reference image
    const safeSquares = [
      [1, 6], [2, 8], [6, 1], [6, 13], [8, 2], [8, 12], [12, 6], [13, 8]
    ];
    
    return safeSquares.any((pos) => pos[0] == x && pos[1] == y);
  }

  @override
  List<Object?> get props => [
    id, playerId, color, state, pathIndex, boardX, boardY, isAtStart, canMove
  ];
}
