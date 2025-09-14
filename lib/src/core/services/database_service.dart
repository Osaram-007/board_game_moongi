import 'package:isar/isar.dart';
import 'package:board_game_moongi/src/features/profile/data/models/player_model.dart';

class DatabaseService {
  final Isar _isar;

  DatabaseService(this._isar);

  // Player CRUD operations
  Future<List<PlayerModel>> getAllPlayers() async {
    return await _isar.playerModels.where().findAll();
  }

  Future<PlayerModel?> getPlayer(String id) async {
    return await _isar.playerModels.get(fastHash(id));
  }

  Future<void> savePlayer(PlayerModel player) async {
    await _isar.writeTxn(() async {
      await _isar.playerModels.put(player);
    });
  }

  Future<void> deletePlayer(String id) async {
    await _isar.writeTxn(() async {
      await _isar.playerModels.delete(fastHash(id));
    });
  }

  Future<PlayerModel?> getCurrentPlayer() async {
    return await _isar.playerModels
        .filter()
        .isCurrentEqualTo(true)
        .findFirst();
  }

  Future<void> setCurrentPlayer(String? playerId) async {
    await _isar.writeTxn(() async {
      // Clear current player flag from all players
      final allPlayers = await _isar.playerModels.where().findAll();
      for (final player in allPlayers) {
        player.isCurrent = false;
        await _isar.playerModels.put(player);
      }

      // Set new current player
      if (playerId != null) {
        final player = await _isar.playerModels.get(fastHash(playerId));
        if (player != null) {
          player.isCurrent = true;
          await _isar.playerModels.put(player);
        }
      }
    });
  }

  // Utility method for generating hash from string ID
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
