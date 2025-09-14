import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

abstract class GameBoard extends Equatable {
  final int rows;
  final int columns;
  final List<List<dynamic>> cells;
  final Size cellSize;

  const GameBoard({
    required this.rows,
    required this.columns,
    required this.cellSize,
    List<List<dynamic>>? cells,
  }) : cells = cells ?? const [];

  bool isValidPosition(int row, int col) {
    return row >= 0 && row < rows && col >= 0 && col < columns;
  }

  dynamic getCell(int row, int col) {
    if (!isValidPosition(row, col)) return null;
    return cells[row][col];
  }

  void setCell(int row, int col, dynamic value) {
    if (!isValidPosition(row, col)) return;
    cells[row][col] = value;
  }

  void clearCell(int row, int col) {
    setCell(row, col, null);
  }

  Size get boardSize => Size(
        columns * cellSize.width,
        rows * cellSize.height,
      );

  void reset() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        cells[i][j] = null;
      }
    }
  }

  @override
  List<Object?> get props => [rows, columns, cellSize, cells];
}

abstract class BoardPainter extends CustomPainter {
  final GameBoard board;
  final Animation<double>? animation;

  const BoardPainter(this.board, {this.animation});

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) {
    return oldDelegate.board != board ||
        (animation != null && animation!.value != oldDelegate.animation?.value);
  }
}
