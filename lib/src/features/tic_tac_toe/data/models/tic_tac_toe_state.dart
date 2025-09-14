import 'package:board_game_moongi/src/core/game/game_state.dart';
import 'package:board_game_moongi/src/core/game/player.dart';

class TicTacToeState extends GameState {
  final List<List<String?>> board;
  final int boardSize;

  const TicTacToeState({
    required super.players,
    super.currentPlayer,
    super.status = GameStatus.waiting,
    super.startedAt,
    super.endedAt,
    super.metadata = const {},
    this.boardSize = 3,
  }) : board = const [
          [null, null, null],
          [null, null, null],
          [null, null, null],
        ];

  const TicTacToeState.withBoard({
    required super.players,
    required this.board,
    super.currentPlayer,
    super.status = GameStatus.waiting,
    super.startedAt,
    super.endedAt,
    super.metadata = const {},
    this.boardSize = 3,
  });

  @override
  TicTacToeState copyWith({
    List<Player>? players,
    Player? currentPlayer,
    GameStatus? status,
    DateTime? startedAt,
    DateTime? endedAt,
    Map<String, dynamic>? metadata,
    List<List<String?>>? board,
    int? boardSize,
  }) {
    return TicTacToeState.withBoard(
      players: players ?? this.players,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      metadata: metadata ?? this.metadata,
      board: board ?? this.board,
      boardSize: boardSize ?? this.boardSize,
    );
  }

  bool isCellEmpty(int row, int col) => board[row][col] == null;
  
  bool isBoardFull() {
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        if (board[i][j] == null) return false;
      }
    }
    return true;
  }

  String? getWinner() {
    // Check rows
    for (int i = 0; i < boardSize; i++) {
      if (board[i][0] != null &&
          board[i][0] == board[i][1] &&
          board[i][0] == board[i][2]) {
        return board[i][0];
      }
    }

    // Check columns
    for (int j = 0; j < boardSize; j++) {
      if (board[0][j] != null &&
          board[0][j] == board[1][j] &&
          board[0][j] == board[2][j]) {
        return board[0][j];
      }
    }

    // Check diagonals
    if (board[0][0] != null &&
        board[0][0] == board[1][1] &&
        board[0][0] == board[2][2]) {
      return board[0][0];
    }

    if (board[0][2] != null &&
        board[0][2] == board[1][1] &&
        board[0][2] == board[2][0]) {
      return board[0][2];
    }

    return null;
  }

  bool hasWinner() => getWinner() != null;

  @override
  List<Object?> get props => [
        ...super.props,
        board,
        boardSize,
      ];
}
