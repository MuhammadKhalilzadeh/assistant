import 'package:assistant/config/app_config.dart';
import 'package:assistant/data/cache/heart_rate_cache.dart';
import 'package:assistant/data/cache/steps_cache.dart';
import 'package:assistant/data/cache/mood_cache.dart';
import 'package:assistant/data/cache/sleep_cache.dart';
import 'package:assistant/data/cache/meditation_cache.dart';
import 'package:assistant/data/cache/workout_cache.dart';
import 'package:assistant/data/cache/calories_cache.dart';
import 'package:assistant/data/cache/habit_cache.dart';
import 'package:assistant/data/cache/todo_cache.dart';
import 'package:assistant/data/cache/water_cache.dart';
import 'package:assistant/data/cache/focus_timer_cache.dart';
import 'package:assistant/data/cache/calendar_cache.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:assistant/presentation/pages/splash/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local caching
  await Hive.initFlutter();

  // Initialize app configuration
  AppConfig.initialize(Environment.dev);

  // Initialize health feature caches
  await Future.wait([
    HeartRateCache().init(),
    StepsCache().init(),
    MoodCache().init(),
    SleepCache().init(),
    MeditationCache().init(),
    WorkoutCache().init(),
    CaloriesCache().init(),
    HabitCache().init(),
    TodoCache().init(),
    WaterCache().init(),
    CalendarCache().init(),
    FocusTimerCache().init(),
  ]);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jarvis Assistant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashPage(),
    );
  }
}
