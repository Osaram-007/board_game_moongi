import 'package:flutter_test/flutter_test.dart';
import 'package:board_game_moongi/src/core/game/player.dart';
import 'package:board_game_moongi/src/features/tic_tac_toe/data/ai/tic_tac_toe_ai.dart';
import 'package:board_game_moongi/src/features/tic_tac_toe/data/models/tic_tac_toe_state.dart';

void main() {
  group('TicTacToeAI', () {
    late TicTacToeAI ai;
    late Player aiPlayer;
    late Player humanPlayer;

    setUp(() {
      aiPlayer = Player(id: 'ai', name: 'AI', type: PlayerType.ai);
      humanPlayer = Player(id: 'human', name: 'Human', type: PlayerType.human);
      ai = TicTacToeAI(
        aiPlayer: aiPlayer,
        aiSymbol: 'O',
        humanSymbol: 'X',
        maxDepth: 9,
      );
    });

    test('should return winning move when available', () {
      final state = TicTacToeState.withBoard(
        players: [humanPlayer, aiPlayer],
        board: [
          ['O', 'O', null],
          ['X', 'X', null],
          [null, null, null],
        ],
        currentPlayer: aiPlayer,
      );

      final bestMove = ai.getBestMove(state);
      expect(bestMove, isNotNull);
      expect(bestMove?['row'], 0);
      expect(bestMove?['col'], 2);
    });

    test('should block opponent winning move', () {
      final state = TicTacToeState.withBoard(
        players: [humanPlayer, aiPlayer],
        board: [
          ['X', 'X', null],
          ['O', null, null],
          [null, null, null],
        ],
        currentPlayer: aiPlayer,
      );

      final bestMove = ai.getBestMove(state);
      expect(bestMove, isNotNull);
      expect(bestMove?['row'], 0);
      expect(bestMove?['col'], 2);
    });

    test('should return null when no moves available', () {
      final state = TicTacToeState.withBoard(
        players: [humanPlayer, aiPlayer],
        board: [
          ['X', 'O', 'X'],
          ['O', 'X', 'O'],
          ['O', 'X', 'O'],
        ],
        currentPlayer: aiPlayer,
      );

      final bestMove = ai.getBestMove(state);
      expect(bestMove, isNull);
    });
  });
}
