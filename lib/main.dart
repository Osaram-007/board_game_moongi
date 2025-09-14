import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:board_game_moongi/src/core/services/database_service.dart';
import 'package:board_game_moongi/src/core/routing/app_router.dart';
import 'package:board_game_moongi/src/core/theme/app_theme.dart';
import 'package:board_game_moongi/src/features/profile/data/models/player_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize database
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [PlayerModelSchema],
    directory: dir.path,
  );
  
  // Initialize services
  final databaseService = DatabaseService(isar);
  
  runApp(
    MultiProvider(
      providers: [
        Provider<DatabaseService>(create: (_) => databaseService),
      ],
      child: const BoardGameMoongiApp(),
    ),
  );
}

class BoardGameMoongiApp extends StatelessWidget {
  const BoardGameMoongiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Board Game Moongi',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
