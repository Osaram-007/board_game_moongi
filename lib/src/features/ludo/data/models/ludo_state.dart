import 'package:board_game_moongi/src/core/game/game_state.dart';
import 'package:board_game_moongi/src/core/game/player.dart';

class LudoState extends GameState {
  final List<List<Piece>> playerPieces;
  final List<int> playerStartPositions;
  final int currentDiceValue;
  final bool isRolling;
  final int? selectedPieceIndex;
  final List<int> validMoves;
  final Map<String, dynamic> gameRules;

  const LudoState({
    required super.players,
    super.currentPlayer,
    super.status = GameStatus.waiting,
    super.startedAt,
    super.endedAt,
    super.metadata = const {},
    this.playerPieces = const [],
    this.playerStartPositions = const [1, 27, 40, 14],
    this.currentDiceValue = 1,
    this.isRolling = false,
    this.selectedPieceIndex,
    this.validMoves = const [],
  }) : gameRules = const {
          'boardSize': 52,
          'piecesPerPlayer': 4,
          'safeZones': [1, 9, 14, 22, 27, 35, 40, 48],
          'homeStretch': 6,
          'sixRule': true,
          'captureRule': true,
        };

  const LudoState.withPieces({
    required super.players,
    required this.playerPieces,
    required this.playerStartPositions,
    required this.gameRules,
    super.currentPlayer,
    super.status = GameStatus.waiting,
    super.startedAt,
    super.endedAt,
    super.metadata = const {},
    this.currentDiceValue = 1,
    this.isRolling = false,
    this.selectedPieceIndex,
    this.validMoves = const [],
  });

  @override
  LudoState copyWith({
    List<Player>? players,
    Player? currentPlayer,
    GameStatus? status,
    DateTime? startedAt,
    DateTime? endedAt,
    Map<String, dynamic>? metadata,
    List<List<Piece>>? playerPieces,
    List<int>? playerStartPositions,
    int? currentDiceValue,
    bool? isRolling,
    int? selectedPieceIndex,
    List<int>? validMoves,
    Map<String, dynamic>? gameRules,
  }) {
    return LudoState.withPieces(
      players: players ?? this.players,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      metadata: metadata ?? this.metadata,
      playerPieces: playerPieces ?? this.playerPieces,
      playerStartPositions: playerStartPositions ?? this.playerStartPositions,
      currentDiceValue: currentDiceValue ?? this.currentDiceValue,
      isRolling: isRolling ?? this.isRolling,
      selectedPieceIndex: selectedPieceIndex ?? this.selectedPieceIndex,
      validMoves: validMoves ?? this.validMoves,
      gameRules: gameRules ?? this.gameRules,
    );
  }

  List<Piece> getCurrentPlayerPieces() {
    final currentIndex = players.indexOf(currentPlayer!);
    return playerPieces[currentIndex];
  }

  bool canMovePiece(Piece piece, int diceValue) {
    if (piece.isHome) return false;
    if (!piece.isOnBoard && diceValue != 6) return false;
    if (piece.isOnBoard && piece.position + diceValue > 57) return false;
    
    return true;
  }

  List<int> getValidMovesForPiece(Piece piece, int diceValue) {
    if (!canMovePiece(piece, diceValue)) return [];
    
    final validMoves = <int>[];
    
    if (!piece.isOnBoard) {
      // Move from home to start
      final startPos = playerStartPositions[players.indexOf(currentPlayer!)];
      if (!_isPositionOccupied(startPos, piece.playerId)) {
        validMoves.add(startPos);
      }
    } else {
      // Move on board
      final newPosition = piece.position + diceValue;
      if (newPosition <= 57) {
        validMoves.add(newPosition);
      }
    }
    
    return validMoves;
  }

  bool _isPositionOccupied(int position, String playerId) {
    for (final pieces in playerPieces) {
      for (final piece in pieces) {
        if (piece.isOnBoard && piece.position == position && piece.playerId != playerId) {
          return true;
        }
      }
    }
    return false;
  }

  bool hasPlayerWon(Player player) {
    final playerIndex = players.indexOf(player);
    final pieces = playerPieces[playerIndex];
    return pieces.every((piece) => piece.isHome);
  }

  int getPiecesInHome(Player player) {
    final playerIndex = players.indexOf(player);
    return playerPieces[playerIndex].where((piece) => piece.isHome).length;
  }

  @override
  List<Object?> get props => [
        ...super.props,
        playerPieces,
        playerStartPositions,
        currentDiceValue,
        isRolling,
        selectedPieceIndex,
        validMoves,
        gameRules,
      ];
}

class Piece {
  final String id;
  final String playerId;
  final int playerIndex;
  final int initialPosition;
  int position;
  bool isOnBoard;
  bool isHome;
  final Color color;

  Piece({
    required this.id,
    required this.playerId,
    required this.playerIndex,
    required this.initialPosition,
    this.position = 0,
    this.isOnBoard = false,
    this.isHome = false,
    required this.color,
  });

  Piece copyWith({
    String? id,
    String? playerId,
    int? playerIndex,
    int? initialPosition,
    int? position,
    bool? isOnBoard,
    bool? isHome,
    Color? color,
  }) {
    return Piece(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      playerIndex: playerIndex ?? this.playerIndex,
      initialPosition: initialPosition ?? this.initialPosition,
      position: position ?? this.position,
      isOnBoard: isOnBoard ?? this.isOnBoard,
      isHome: isHome ?? this.isHome,
      color: color ?? this.color,
    );
  }

  @override
  List<Object?> get props => [
        id,
        playerId,
        playerIndex,
        initialPosition,
        position,
        isOnBoard,
        isHome,
        color,
      ];
}
