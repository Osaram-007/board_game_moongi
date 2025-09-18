import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'ludo_token.dart';
import 'ludo_player.dart';

enum CellType {
  empty,
  path,
  safe,
  start,
  homeArea,
  finishPath,
  center,
}

class BoardCell extends Equatable {
  final int x;
  final int y;
  final CellType type;
  final Color? color; // For colored areas
  final bool hasStar; // For safe squares
  final List<LudoToken> tokens; // Tokens on this cell

  const BoardCell({
    required this.x,
    required this.y,
    required this.type,
    this.color,
    this.hasStar = false,
    this.tokens = const [],
  });

  BoardCell copyWith({
    int? x,
    int? y,
    CellType? type,
    Color? color,
    bool? hasStar,
    List<LudoToken>? tokens,
  }) {
    return BoardCell(
      x: x ?? this.x,
      y: y ?? this.y,
      type: type ?? this.type,
      color: color ?? this.color,
      hasStar: hasStar ?? this.hasStar,
      tokens: tokens ?? this.tokens,
    );
  }

  @override
  List<Object?> get props => [x, y, type, color, hasStar, tokens];
}

class LudoBoard extends Equatable {
  final List<List<BoardCell>> grid; // 15x15 grid
  final List<List<List<int>>> playerPaths; // Movement paths for each player
  final List<List<int>> safeSquares; // Safe square coordinates
  final List<List<int>> startPositions; // Starting positions for each player
  final List<List<List<int>>> homeAreas; // Home area coordinates for each player
  final List<List<List<int>>> finishPaths; // Finish path coordinates for each player

  const LudoBoard({
    required this.grid,
    required this.playerPaths,
    required this.safeSquares,
    required this.startPositions,
    required this.homeAreas,
    required this.finishPaths,
  });

  // Create initial board layout
  factory LudoBoard.initialize() {
    final grid = _createInitialGrid();
    final playerPaths = _createPlayerPaths();
    final safeSquares = _createSafeSquares();
    final startPositions = _createStartPositions();
    final homeAreas = _createHomeAreas();
    final finishPaths = _createFinishPaths();

    return LudoBoard(
      grid: grid,
      playerPaths: playerPaths,
      safeSquares: safeSquares,
      startPositions: startPositions,
      homeAreas: homeAreas,
      finishPaths: finishPaths,
    );
  }

  // Create 15x15 grid with proper cell types and colors
  static List<List<BoardCell>> _createInitialGrid() {
    List<List<BoardCell>> grid = [];
    
    for (int y = 0; y < 15; y++) {
      List<BoardCell> row = [];
      for (int x = 0; x < 15; x++) {
        row.add(_createCell(x, y));
      }
      grid.add(row);
    }
    
    return grid;
  }

  // Create individual cell based on coordinates
  static BoardCell _createCell(int x, int y) {
    // Home areas (6x6 each in corners)
    if (_isInHomeArea(x, y, 0)) { // Red home (top-left)
      return BoardCell(x: x, y: y, type: CellType.homeArea, color: Colors.red);
    }
    if (_isInHomeArea(x, y, 1)) { // Green home (top-right)
      return BoardCell(x: x, y: y, type: CellType.homeArea, color: Colors.green);
    }
    if (_isInHomeArea(x, y, 2)) { // Blue home (bottom-right)
      return BoardCell(x: x, y: y, type: CellType.homeArea, color: Colors.blue);
    }
    if (_isInHomeArea(x, y, 3)) { // Yellow home (bottom-left)
      return BoardCell(x: x, y: y, type: CellType.homeArea, color: Colors.yellow);
    }

    // Center area
    if (x >= 6 && x <= 8 && y >= 6 && y <= 8) {
      return BoardCell(x: x, y: y, type: CellType.center);
    }

    // Movement paths
    if (_isOnPath(x, y)) {
      final isSafe = _isSafeSquare(x, y);
      final isStart = _isStartSquare(x, y);
      final color = _getPathColor(x, y);
      
      CellType type = CellType.path;
      if (isStart) type = CellType.start;
      if (_isFinishPath(x, y)) type = CellType.finishPath;
      
      return BoardCell(
        x: x, 
        y: y, 
        type: type, 
        color: color,
        hasStar: isSafe,
      );
    }

    // Empty cells
    return BoardCell(x: x, y: y, type: CellType.empty);
  }

  // Check if coordinates are in a home area
  static bool _isInHomeArea(int x, int y, int playerId) {
    switch (playerId) {
      case 0: // Red (top-left)
        return x >= 0 && x <= 5 && y >= 0 && y <= 5;
      case 1: // Green (top-right)
        return x >= 9 && x <= 14 && y >= 0 && y <= 5;
      case 2: // Blue (bottom-right)
        return x >= 9 && x <= 14 && y >= 9 && y <= 14;
      case 3: // Yellow (bottom-left)
        return x >= 0 && x <= 5 && y >= 9 && y <= 14;
      default:
        return false;
    }
  }

  // Check if coordinates are on the movement path
  static bool _isOnPath(int x, int y) {
    // Horizontal paths
    if (y == 6 && (x <= 5 || x >= 9)) return true;
    if (y == 7 && x >= 1 && x <= 13) return true;
    if (y == 8 && (x <= 5 || x >= 9)) return true;
    
    // Vertical paths
    if (x == 6 && (y <= 5 || y >= 9)) return true;
    if (x == 7 && y >= 1 && y <= 13) return true;
    if (x == 8 && (y <= 5 || y >= 9)) return true;
    
    return false;
  }

  // Check if coordinates are a safe square (marked with star)
  static bool _isSafeSquare(int x, int y) {
    const safeSquares = [
      [1, 6], [2, 8], [6, 1], [6, 13], [8, 2], [8, 12], [12, 6], [13, 8]
    ];
    return safeSquares.any((pos) => pos[0] == x && pos[1] == y);
  }

  // Check if coordinates are a starting square
  static bool _isStartSquare(int x, int y) {
    const startSquares = [
      [1, 6], [8, 1], [13, 8], [6, 13]
    ];
    return startSquares.any((pos) => pos[0] == x && pos[1] == y);
  }

  // Check if coordinates are on a finish path
  static bool _isFinishPath(int x, int y) {
    // Red finish path
    if (y == 7 && x >= 1 && x <= 6) return true;
    // Green finish path  
    if (x == 7 && y >= 1 && y <= 6) return true;
    // Blue finish path
    if (y == 7 && x >= 8 && x <= 13) return true;
    // Yellow finish path
    if (x == 7 && y >= 8 && y <= 13) return true;
    
    return false;
  }

  // Get color for path cells
  static Color? _getPathColor(int x, int y) {
    // Colored finish paths
    if (y == 7 && x >= 1 && x <= 6) return Colors.red;
    if (x == 7 && y >= 1 && y <= 6) return Colors.green;  
    if (y == 7 && x >= 8 && x <= 13) return Colors.blue;
    if (x == 7 && y >= 8 && y <= 13) return Colors.yellow;
    
    return null; // White path
  }

  // Create movement paths for each player (58 positions each: 52 main path + 6 home stretch)
  static List<List<List<int>>> _createPlayerPaths() {
    return [
      _createRedPath(),
      _createGreenPath(),
      _createBluePath(),
      _createYellowPath(),
    ];
  }

  static List<List<int>> _createRedPath() {
    List<List<int>> path = [];
    // Start at red starting position and move clockwise
    path.add([1, 6]); // Start
    // Move right along bottom of red home
    for (int x = 2; x <= 5; x++) path.add([x, 6]);
    // Move up right side
    for (int y = 5; y >= 1; y--) path.add([6, y]);
    // Continue around board clockwise...
    // This would be a long list of coordinates for the full path
    return path;
  }

  static List<List<int>> _createGreenPath() {
    // Similar implementation for green player path
    return [];
  }

  static List<List<int>> _createBluePath() {
    // Similar implementation for blue player path  
    return [];
  }

  static List<List<int>> _createYellowPath() {
    // Similar implementation for yellow player path
    return [];
  }

  static List<List<int>> _createSafeSquares() {
    return [
      [1, 6], [2, 8], [6, 1], [6, 13], [8, 2], [8, 12], [12, 6], [13, 8]
    ];
  }

  static List<List<int>> _createStartPositions() {  
    return [
      [1, 6],   // Red
      [8, 1],   // Green
      [13, 8],  // Blue
      [6, 13],  // Yellow
    ];
  }

  static List<List<List<int>>> _createHomeAreas() {
    return [
      [[1, 1], [1, 2], [2, 1], [2, 2]], // Red home positions
      [[12, 1], [12, 2], [13, 1], [13, 2]], // Green home positions  
      [[12, 12], [12, 13], [13, 12], [13, 13]], // Blue home positions
      [[1, 12], [1, 13], [2, 12], [2, 13]], // Yellow home positions
    ];
  }

  static List<List<List<int>>> _createFinishPaths() {
    return [
      [[2, 7], [3, 7], [4, 7], [5, 7], [6, 7]], // Red finish path
      [[7, 2], [7, 3], [7, 4], [7, 5], [7, 6]], // Green finish path
      [[8, 7], [9, 7], [10, 7], [11, 7], [12, 7]], // Blue finish path  
      [[7, 8], [7, 9], [7, 10], [7, 11], [7, 12]], // Yellow finish path
    ];
  }

  // Update board with new token positions
  LudoBoard updateTokenPositions(List<LudoPlayer> players) {
    // Clear all tokens from grid
    final newGrid = grid.map((row) => 
      row.map((cell) => cell.copyWith(tokens: <LudoToken>[])).toList()
    ).toList();

    // Place tokens on their current positions
    for (final player in players) {
      for (final token in player.tokens) {
        if (token.boardX >= 0 && token.boardY >= 0 && 
            token.boardX < 15 && token.boardY < 15) {
          final cell = newGrid[token.boardY][token.boardX];
          final updatedTokens = [...cell.tokens, token];
          newGrid[token.boardY][token.boardX] = cell.copyWith(tokens: updatedTokens);
        }
      }
    }

    return copyWith(grid: newGrid);
  }

  LudoBoard copyWith({
    List<List<BoardCell>>? grid,
    List<List<List<int>>>? playerPaths,
    List<List<int>>? safeSquares,
    List<List<int>>? startPositions,
    List<List<List<int>>>? homeAreas,
    List<List<List<int>>>? finishPaths,
  }) {
    return LudoBoard(
      grid: grid ?? this.grid,
      playerPaths: playerPaths ?? this.playerPaths,
      safeSquares: safeSquares ?? this.safeSquares,
      startPositions: startPositions ?? this.startPositions,
      homeAreas: homeAreas ?? this.homeAreas,
      finishPaths: finishPaths ?? this.finishPaths,
    );
  }

  @override
  List<Object?> get props => [
    grid, playerPaths, safeSquares, startPositions, homeAreas, finishPaths
  ];
}
