import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:board_game_moongi/src/core/services/database_service.dart';
import 'package:board_game_moongi/src/features/profile/data/models/player_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<PlayerModel> _players = [];
  PlayerModel? _selectedPlayer;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadPlayers() async {
    final databaseService = context.read<DatabaseService>();
    final players = await databaseService.getAllPlayers();
    final currentPlayer = await databaseService.getCurrentPlayer();
    
    setState(() {
      _players = players;
      _selectedPlayer = currentPlayer;
    });
  }

  Future<void> _createPlayer() async {
    if (!_formKey.currentState!.validate()) return;

    final databaseService = context.read<DatabaseService>();
    final newPlayer = PlayerModel(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      createdAt: DateTime.now(),
      lastPlayedAt: DateTime.now(),
    );

    await databaseService.savePlayer(newPlayer);
    await databaseService.setCurrentPlayer(newPlayer.id);
    
    _nameController.clear();
    await _loadPlayers();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Player created successfully')),
      );
    }
  }

  Future<void> _selectPlayer(PlayerModel player) async {
    final databaseService = context.read<DatabaseService>();
    await databaseService.setCurrentPlayer(player.id);
    await _loadPlayers();
  }

  Future<void> _deletePlayer(PlayerModel player) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Player'),
        content: Text('Are you sure you want to delete "${player.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final databaseService = context.read<DatabaseService>();
      await databaseService.deletePlayer(player.id);
      await _loadPlayers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Profiles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showStatsDialog(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCreatePlayerForm(),
            const SizedBox(height: 24),
            _buildPlayerList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatePlayerForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create New Player',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Player Name',
                    prefixIcon: Icon(Icons.person),
                    hintText: 'Enter player name',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a name';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _createPlayer,
                child: const Text('Create'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerList() {
    if (_players.isEmpty) {
      return const Center(
        child: Text('No players created yet. Create a player to get started!'),
      );
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Player',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _players.length,
              itemBuilder: (context, index) {
                final player = _players[index];
                return _PlayerCard(
                  player: player,
                  isSelected: _selectedPlayer?.id == player.id,
                  onSelect: () => _selectPlayer(player),
                  onDelete: () => _deletePlayer(player),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showStatsDialog() {
    if (_selectedPlayer == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_selectedPlayer!.name}\'s Stats'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatRow(
              label: 'Total Games',
              value: _selectedPlayer!.totalGamesPlayed.toString(),
            ),
            _StatRow(
              label: 'Games Won',
              value: _selectedPlayer!.gamesWon.toString(),
            ),
            _StatRow(
              label: 'Win Rate',
              value: '${(_selectedPlayer!.winRate * 100).toStringAsFixed(1)}%',
            ),
            const Divider(),
            _StatRow(
              label: 'Tic Tac Toe Wins',
              value: _selectedPlayer!.ticTacToeWins.toString(),
            ),
            _StatRow(
              label: 'Snakes & Ladders Wins',
              value: _selectedPlayer!.snakesLaddersWins.toString(),
            ),
            _StatRow(
              label: 'Ludo Wins',
              value: _selectedPlayer!.ludoWins.toString(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final PlayerModel player;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onDelete;

  const _PlayerCard({
    required this.player,
    required this.isSelected,
    required this.onSelect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            player.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(player.name),
        subtitle: Text(
          'Created ${player.createdAt.day}/${player.createdAt.month}/${player.createdAt.year}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.green),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
              color: Colors.red,
            ),
          ],
        ),
        onTap: onSelect,
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
