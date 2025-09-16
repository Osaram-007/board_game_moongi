import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:board_game_moongi/src/features/profile/data/models/player_model.dart';

class DatabaseService {
  static const String _playersKey = 'players';
  static const String _currentPlayerKey = 'current_player';

  DatabaseService();

  // Player CRUD operations
  Future<List<PlayerModel>> getAllPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final playersJson = prefs.getStringList(_playersKey) ?? [];
    return playersJson.map((json) => PlayerModel.fromJson(jsonDecode(json))).toList();
  }

  Future<PlayerModel?> getPlayer(String id) async {
    final players = await getAllPlayers();
    try {
      return players.firstWhere((player) => player.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> savePlayer(PlayerModel player) async {
    final prefs = await SharedPreferences.getInstance();
    final players = await getAllPlayers();
    
    // Remove existing player with same ID
    players.removeWhere((p) => p.id == player.id);
    
    // Add updated player
    players.add(player);
    
    // Save to SharedPreferences
    final playersJson = players.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_playersKey, playersJson);
  }

  Future<void> deletePlayer(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final players = await getAllPlayers();
    
    players.removeWhere((player) => player.id == id);
    
    final playersJson = players.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_playersKey, playersJson);
  }

  Future<PlayerModel?> getCurrentPlayer() async {
    final prefs = await SharedPreferences.getInstance();
    final currentPlayerId = prefs.getString(_currentPlayerKey);
    
    if (currentPlayerId != null) {
      return await getPlayer(currentPlayerId);
    }
    return null;
  }

  Future<void> setCurrentPlayer(String? playerId) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (playerId != null) {
      await prefs.setString(_currentPlayerKey, playerId);
    } else {
      await prefs.remove(_currentPlayerKey);
    }
  }
}
