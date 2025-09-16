import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:board_game_moongi/src/core/services/database_service.dart';
import 'package:board_game_moongi/src/core/routing/app_router.dart';
import 'package:board_game_moongi/src/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize services
  final databaseService = DatabaseService();
  
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
