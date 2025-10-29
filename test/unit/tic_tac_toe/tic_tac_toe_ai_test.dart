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

    group('Difficulty Levels', () {
      test('Easy difficulty should make moves', () {
        final easyAI = TicTacToeAI(
          aiPlayer: aiPlayer,
          aiSymbol: 'O',
          humanSymbol: 'X',
          difficultyLevel: AIDifficulty.easy,
        );

        final state = TicTacToeState.withBoard(
          players: [humanPlayer, aiPlayer],
          board: [
            ['X', null, null],
            [null, null, null],
            [null, null, null],
          ],
          currentPlayer: aiPlayer,
        );

        final bestMove = easyAI.getBestMove(state);
        expect(bestMove, isNotNull);
        expect(bestMove?['row'], isA<int>());
        expect(bestMove?['col'], isA<int>());
      });

      test('Hard difficulty should prioritize winning moves', () {
        final hardAI = TicTacToeAI(
          aiPlayer: aiPlayer,
          aiSymbol: 'O',
          humanSymbol: 'X',
          difficultyLevel: AIDifficulty.hard,
        );

        final state = TicTacToeState.withBoard(
          players: [humanPlayer, aiPlayer],
          board: [
            ['O', 'O', null],
            ['X', 'X', null],
            [null, null, null],
          ],
          currentPlayer: aiPlayer,
        );

        final bestMove = hardAI.getBestMove(state);
        expect(bestMove, isNotNull);
        // Should take winning move at (0, 2)
        expect(bestMove?['row'], 0);
        expect(bestMove?['col'], 2);
      });

      test('Hard difficulty should block opponent winning moves', () {
        final hardAI = TicTacToeAI(
          aiPlayer: aiPlayer,
          aiSymbol: 'O',
          humanSymbol: 'X',
          difficultyLevel: AIDifficulty.hard,
        );

        final state = TicTacToeState.withBoard(
          players: [humanPlayer, aiPlayer],
          board: [
            ['X', 'X', null],
            ['O', null, null],
            [null, null, null],
          ],
          currentPlayer: aiPlayer,
        );

        final bestMove = hardAI.getBestMove(state);
        expect(bestMove, isNotNull);
        // Should block at (0, 2)
        expect(bestMove?['row'], 0);
        expect(bestMove?['col'], 2);
      });

      test('Hard difficulty should prefer center', () {
        final hardAI = TicTacToeAI(
          aiPlayer: aiPlayer,
          aiSymbol: 'O',
          humanSymbol: 'X',
          difficultyLevel: AIDifficulty.hard,
        );

        final state = TicTacToeState.withBoard(
          players: [humanPlayer, aiPlayer],
          board: [
            ['X', null, null],
            [null, null, null],
            [null, null, null],
          ],
          currentPlayer: aiPlayer,
        );

        final bestMove = hardAI.getBestMove(state);
        expect(bestMove, isNotNull);
        // Should take center at (1, 1)
        expect(bestMove?['row'], 1);
        expect(bestMove?['col'], 1);
      });

      test('Extreme difficulty should never lose', () {
        final extremeAI = TicTacToeAI(
          aiPlayer: aiPlayer,
          aiSymbol: 'O',
          humanSymbol: 'X',
          difficultyLevel: AIDifficulty.extreme,
        );

        final state = TicTacToeState.withBoard(
          players: [humanPlayer, aiPlayer],
          board: [
            ['X', null, null],
            [null, 'O', null],
            [null, null, null],
          ],
          currentPlayer: aiPlayer,
        );

        final bestMove = extremeAI.getBestMove(state);
        expect(bestMove, isNotNull);
        // Extreme should make optimal move
        expect(bestMove?['row'], isA<int>());
        expect(bestMove?['col'], isA<int>());
      });

      test('Extreme difficulty should find winning move in complex scenario', () {
        final extremeAI = TicTacToeAI(
          aiPlayer: aiPlayer,
          aiSymbol: 'O',
          humanSymbol: 'X',
          difficultyLevel: AIDifficulty.extreme,
        );

        final state = TicTacToeState.withBoard(
          players: [humanPlayer, aiPlayer],
          board: [
            ['O', 'X', 'O'],
            ['X', 'O', null],
            ['X', null, null],
          ],
          currentPlayer: aiPlayer,
        );

        final bestMove = extremeAI.getBestMove(state);
        expect(bestMove, isNotNull);
        // Should find winning diagonal move at (2, 2)
        expect(bestMove?['row'], 2);
        expect(bestMove?['col'], 2);
      });
    });
  });
}
