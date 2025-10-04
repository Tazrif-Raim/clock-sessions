import 'package:clock_sessions/db/database.dart';
import 'package:clock_sessions/db/db_service.dart';
import 'package:clock_sessions/services/notification_service.dart';
import 'package:clock_sessions/services/stopwatch_service.dart';
import 'package:clock_sessions/ui/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Providers
final notificationServiceProvider = Provider((ref) => NotificationService());
final appDatabaseProvider = Provider((ref) => AppDatabase());
final dbServiceProvider = Provider((ref) => DbService(ref.watch(appDatabaseProvider)));
final stopwatchServiceProvider = ChangeNotifierProvider((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return StopwatchService(notificationService);
});

final monthlyEarningsProvider = FutureProvider<double>((ref) async {
  final dbService = ref.watch(dbServiceProvider);
  final sessions = await dbService.getAllSessions();
  final now = DateTime.now();
  final currentMonthSessions = sessions.where((s) => s.date.month == now.month && s.date.year == now.year);
  final daysWithMoreThan5Hours = currentMonthSessions.where((s) => s.durationInSeconds >= 5 * 3600).length;
  return (daysWithMoreThan5Hours * 150).toDouble();
});

final monthlyDaysProvider = FutureProvider<int>((ref) async {
  final dbService = ref.watch(dbServiceProvider);
  final sessions = await dbService.getAllSessions();
  final now = DateTime.now();
  final currentMonthSessions = sessions.where((s) => s.date.month == now.month && s.date.year == now.year);
  return currentMonthSessions.where((s) => s.durationInSeconds >= 5 * 3600).length;
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  await container.read(notificationServiceProvider).init();

  runApp(
    ProviderScope(
      overrides: [
        notificationServiceProvider.overrideWithValue(container.read(notificationServiceProvider)),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clock Sessions',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}