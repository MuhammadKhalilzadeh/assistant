import 'dart:math';

import 'package:assistant/data/services/steps_api_service.dart';
import 'package:assistant/data/services/heart_rate_api_service.dart';
import 'package:assistant/data/services/sleep_api_service.dart';
import 'package:assistant/data/services/workout_api_service.dart';
import 'package:assistant/data/services/water_api_service.dart';
import 'package:assistant/data/services/calories_api_service.dart';
import 'package:assistant/data/services/mood_api_service.dart';
import 'package:assistant/data/services/meditation_api_service.dart';
import 'package:assistant/data/services/habit_api_service.dart';
import 'package:assistant/data/services/todo_api_service.dart';
import 'package:assistant/data/services/screen_time_api_service.dart';
import 'package:assistant/data/services/focus_timer_api_service.dart';

import 'package:assistant/data/models/step_record_model.dart';
import 'package:assistant/data/models/heart_rate_model.dart';
import 'package:assistant/data/models/sleep_record_model.dart';
import 'package:assistant/data/models/workout_session_model.dart';
import 'package:assistant/data/models/water_log_model.dart';
import 'package:assistant/data/models/calorie_entry_model.dart';
import 'package:assistant/data/models/mood_entry_model.dart';
import 'package:assistant/data/models/meditation_session_model.dart';
import 'package:assistant/data/mock/models/habit_model.dart';
import 'package:assistant/data/mock/models/todo_model.dart';
import 'package:assistant/data/models/screen_time_model.dart';
import 'package:assistant/data/models/focus_session_model.dart';

class DemoDataService {
  final _random = Random();
  final _stepsApi = StepsApiService();
  final _heartRateApi = HeartRateApiService();
  final _sleepApi = SleepApiService();
  final _workoutApi = WorkoutApiService();
  final _waterApi = WaterApiService();
  final _caloriesApi = CaloriesApiService();
  final _moodApi = MoodApiService();
  final _meditationApi = MeditationApiService();
  final _habitApi = HabitApiService();
  final _todoApi = TodoApiService();
  final _screenTimeApi = ScreenTimeApiService();
  final _focusTimerApi = FocusTimerApiService();

  int _randBetween(int min, int max) => min + _random.nextInt(max - min + 1);

  /// Callback signature: (moduleName, currentIndex, totalModules)
  Future<List<String>> createDemoData({
    void Function(String module, int current, int total)? onProgress,
  }) async {
    const totalModules = 12;
    var current = 0;
    final errors = <String>[];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final modules = <(String, Future<void> Function())>[
      ('Steps', () => _createStepsData(today)),
      ('Heart Rate', () => _createHeartRateData(today)),
      ('Sleep', () => _createSleepData(today)),
      ('Workout', () => _createWorkoutData(today)),
      ('Water', () => _createWaterData(today)),
      ('Calories', () => _createCaloriesData(today)),
      ('Mood', () => _createMoodData(today)),
      ('Meditation', () => _createMeditationData(today)),
      ('Habits', () => _createHabitsData()),
      ('Todos', () => _createTodosData(today)),
      ('Screen Time', () => _createScreenTimeData(today)),
      ('Focus Timer', () => _createFocusTimerData(today)),
    ];

    for (final (name, action) in modules) {
      onProgress?.call(name, ++current, totalModules);
      try {
        await action();
      } catch (e) {
        errors.add(name);
      }
    }

    return errors;
  }

  Future<void> deleteDemoData({
    void Function(String module, int current, int total)? onProgress,
  }) async {
    const totalModules = 12;
    var current = 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 1. Steps
    onProgress?.call('Steps', ++current, totalModules);
    for (var i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      try {
        final record = await _stepsApi.getRecordForDate(date: date);
        if (record != null) await _stepsApi.deleteRecord(record.id);
      } catch (_) {}
    }

    // 2. Heart Rate
    onProgress?.call('Heart Rate', ++current, totalModules);
    for (var i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      try {
        final records = await _heartRateApi.getRecordsForDate(date: date);
        for (final r in records) {
          await _heartRateApi.deleteRecord(r.id);
        }
      } catch (_) {}
    }

    // 3. Sleep
    onProgress?.call('Sleep', ++current, totalModules);
    for (var i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      try {
        final records = await _sleepApi.getRecordsForDate(date: date);
        for (final r in records) {
          await _sleepApi.deleteRecord(r.id);
        }
      } catch (_) {}
    }

    // 4. Workout
    onProgress?.call('Workout', ++current, totalModules);
    for (var i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      try {
        final sessions = await _workoutApi.getSessionsForDate(date: date);
        for (final s in sessions) {
          await _workoutApi.deleteSession(s.id);
        }
      } catch (_) {}
    }

    // 5. Water
    onProgress?.call('Water', ++current, totalModules);
    for (var i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      try {
        final logs = await _waterApi.getLogsForDate(date: date);
        for (final l in logs) {
          await _waterApi.deleteLog(l.id);
        }
      } catch (_) {}
    }

    // 6. Calories
    onProgress?.call('Calories', ++current, totalModules);
    for (var i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      try {
        final entries = await _caloriesApi.getEntriesForDate(date: date);
        for (final e in entries) {
          await _caloriesApi.deleteEntry(e.id);
        }
      } catch (_) {}
    }

    // 7. Mood
    onProgress?.call('Mood', ++current, totalModules);
    for (var i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      try {
        final entries = await _moodApi.getEntriesForDate(date: date);
        for (final e in entries) {
          await _moodApi.deleteEntry(e.id);
        }
      } catch (_) {}
    }

    // 8. Meditation
    onProgress?.call('Meditation', ++current, totalModules);
    for (var i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      try {
        final sessions = await _meditationApi.getSessionsForDate(date: date);
        for (final s in sessions) {
          await _meditationApi.deleteSession(s.id);
        }
      } catch (_) {}
    }

    // 9. Habits
    onProgress?.call('Habits', ++current, totalModules);
    try {
      final habits = await _habitApi.getHabits();
      for (final h in habits) {
        await _habitApi.deleteHabit(h.id);
      }
    } catch (_) {}

    // 10. Todos
    onProgress?.call('Todos', ++current, totalModules);
    try {
      final todos = await _todoApi.getTodos();
      for (final t in todos) {
        await _todoApi.deleteTodo(t.id);
      }
    } catch (_) {}

    // 11. Screen Time
    onProgress?.call('Screen Time', ++current, totalModules);
    for (var i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      try {
        final record = await _screenTimeApi.getByDate(date: date);
        if (record != null) await _screenTimeApi.deleteRecord(record.id);
      } catch (_) {}
    }

    // 12. Focus Timer
    onProgress?.call('Focus Timer', ++current, totalModules);
    for (var i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      try {
        final sessions = await _focusTimerApi.getSessionsForDate(date: date);
        for (final s in sessions) {
          await _focusTimerApi.deleteSession(s.id);
        }
      } catch (_) {}
    }
  }

  // ─── Steps ──────────────────────────────────────────────────────────

  Future<void> _createStepsData(DateTime today) async {
    for (var i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final steps = _randBetween(5000, 12000);
      await _stepsApi.createRecord(StepRecordModel(
        id: '',
        date: date,
        steps: steps,
        goal: 10000,
        distanceKm: steps * 0.0008,
        caloriesBurned: (steps * 0.04).round(),
      ));
    }
  }

  // ─── Heart Rate ─────────────────────────────────────────────────────

  Future<void> _createHeartRateData(DateTime today) async {
    for (var i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      // Morning, afternoon, evening readings
      for (final hour in [8, 14, 20]) {
        await _heartRateApi.createRecord(HeartRateRecordModel(
          id: '',
          bpm: _randBetween(60, 100),
          recordedAt: date.add(Duration(hours: hour, minutes: _randBetween(0, 30))),
        ));
      }
    }
  }

  // ─── Sleep ──────────────────────────────────────────────────────────

  Future<void> _createSleepData(DateTime today) async {
    const qualities = SleepQuality.values;
    for (var i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final bedHour = _randBetween(22, 23);
      final sleepHours = _randBetween(6, 8);
      final bedTime = date.subtract(const Duration(days: 1)).add(Duration(hours: bedHour, minutes: _randBetween(0, 45)));
      final wakeTime = bedTime.add(Duration(hours: sleepHours, minutes: _randBetween(0, 30)));
      await _sleepApi.createRecord(SleepRecordModel(
        id: '',
        bedTime: bedTime,
        wakeTime: wakeTime,
        quality: qualities[_randBetween(1, 3)], // fair, good, excellent
      ));
    }
  }

  // ─── Workout ────────────────────────────────────────────────────────

  Future<void> _createWorkoutData(DateTime today) async {
    const types = [WorkoutType.running, WorkoutType.cycling, WorkoutType.yoga, WorkoutType.strength];
    for (var i = 0; i < 7; i += 2) {
      final date = today.subtract(Duration(days: i));
      final type = types[i ~/ 2 % types.length];
      final duration = _randBetween(20, 60);
      final startTime = date.add(Duration(hours: _randBetween(6, 18)));
      await _workoutApi.createSession(WorkoutSessionModel(
        id: '',
        type: type,
        startTime: startTime,
        endTime: startTime.add(Duration(minutes: duration)),
        durationMinutes: duration,
        caloriesBurned: _randBetween(150, 500),
      ));
    }
  }

  // ─── Water ──────────────────────────────────────────────────────────

  Future<void> _createWaterData(DateTime today) async {
    for (var i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final logCount = _randBetween(4, 6);
      for (var j = 0; j < logCount; j++) {
        await _waterApi.createLog(WaterLogModel(
          id: '',
          amountMl: _randBetween(200, 400),
          loggedAt: date.add(Duration(hours: 8 + j * 2, minutes: _randBetween(0, 30))),
          beverageType: BeverageType.water,
        ));
      }
    }
  }

  // ─── Calories ───────────────────────────────────────────────────────

  Future<void> _createCaloriesData(DateTime today) async {
    const meals = [
      (MealType.breakfast, 'Oatmeal with berries', 350, 12, 55, 8, FoodCategory.grains),
      (MealType.lunch, 'Grilled chicken salad', 480, 35, 20, 18, FoodCategory.protein),
      (MealType.dinner, 'Salmon with vegetables', 550, 40, 25, 22, FoodCategory.protein),
      (MealType.snack, 'Greek yogurt', 150, 15, 12, 4, FoodCategory.dairy),
    ];

    for (var i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      for (var j = 0; j < meals.length; j++) {
        final (mealType, name, cal, protein, carbs, fat, category) = meals[j];
        final hour = [8, 12, 19, 15][j];
        final calorieVariation = _randBetween(-50, 50);
        await _caloriesApi.createEntry(CalorieEntryModel(
          id: '',
          foodName: name,
          calories: cal + calorieVariation,
          mealType: mealType,
          loggedAt: date.add(Duration(hours: hour, minutes: _randBetween(0, 30))),
          protein: protein,
          carbs: carbs,
          fat: fat,
          foodCategory: category,
        ));
      }
    }
  }

  // ─── Mood ───────────────────────────────────────────────────────────

  Future<void> _createMoodData(DateTime today) async {
    const moods = [MoodLevel.great, MoodLevel.good, MoodLevel.good, MoodLevel.okay, MoodLevel.good, MoodLevel.great, MoodLevel.okay];
    const activitySets = [
      ['Exercise', 'Reading'],
      ['Work', 'Socializing'],
      ['Meditation', 'Walking'],
      ['Cooking', 'Music'],
      ['Exercise', 'Gaming'],
      ['Socializing', 'Travel'],
      ['Reading', 'Rest'],
    ];
    for (var i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      await _moodApi.createEntry(MoodEntryModel(
        id: '',
        mood: moods[i],
        recordedAt: date.add(Duration(hours: _randBetween(18, 21))),
        activities: activitySets[i],
        notes: null,
      ));
    }
  }

  // ─── Meditation ─────────────────────────────────────────────────────

  Future<void> _createMeditationData(DateTime today) async {
    const types = MeditationType.values;
    for (var i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      await _meditationApi.createSession(MeditationSessionModel(
        id: '',
        type: types[i % types.length],
        startTime: date.add(Duration(hours: 7, minutes: _randBetween(0, 30))),
        durationMinutes: _randBetween(5, 20),
        isCompleted: true,
      ));
    }
  }

  // ─── Habits ─────────────────────────────────────────────────────────

  Future<void> _createHabitsData() async {
    const habits = [
      ('Morning Workout', 'Exercise for 30 minutes', 'fitness_center', HabitCategory.fitness),
      ('Read 20 Pages', 'Read at least 20 pages daily', 'menu_book', HabitCategory.learning),
      ('Drink 2L Water', 'Stay hydrated throughout the day', 'water_drop', HabitCategory.health),
      ('Meditate', '10 minutes of mindfulness', 'self_improvement', HabitCategory.mindfulness),
    ];

    for (final (name, desc, icon, category) in habits) {
      final habit = await _habitApi.createHabit(HabitModel(
        id: '',
        name: name,
        description: desc,
        icon: icon,
        category: category,
        frequency: HabitFrequency.daily,
      ));
      // Toggle some habits as completed today
      if (_random.nextBool()) {
        await _habitApi.toggleComplete(habit.id);
      }
    }
  }

  // ─── Todos ──────────────────────────────────────────────────────────

  Future<void> _createTodosData(DateTime today) async {
    final todos = [
      ('Buy groceries', 'Milk, eggs, bread, fruits', 2, today.add(const Duration(days: 1))),
      ('Schedule dentist appointment', null, 2, today.add(const Duration(days: 3))),
      ('Review project proposal', 'Check budget and timeline sections', 1, today),
      ('Clean the apartment', null, 3, today.add(const Duration(days: 2))),
      ('Call mom', null, 2, today),
      ('Prepare presentation', 'Q2 performance review slides', 1, today.add(const Duration(days: 1))),
    ];

    for (var i = 0; i < todos.length; i++) {
      final (title, desc, priority, dueDate) = todos[i];
      final todo = await _todoApi.createTodo(TodoModel(
        id: '',
        title: title,
        description: desc,
        priority: priority,
        dueDate: dueDate,
        createdAt: today,
      ));
      // Mark first two as completed
      if (i < 2) {
        await _todoApi.toggleComplete(todo.id);
      }
    }
  }

  // ─── Screen Time ────────────────────────────────────────────────────

  Future<void> _createScreenTimeData(DateTime today) async {
    for (var i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      await _screenTimeApi.createRecord(ScreenTimeRecord(
        id: '',
        date: date,
        totalMinutes: _randBetween(120, 300),
        pickups: _randBetween(30, 80),
        appUsage: [
          AppUsageEntry(
            id: '',
            appName: 'Social Media',
            category: 'social',
            minutesUsed: _randBetween(30, 90),
            iconName: 'people',
          ),
          AppUsageEntry(
            id: '',
            appName: 'Productivity',
            category: 'productivity',
            minutesUsed: _randBetween(20, 60),
            iconName: 'work',
          ),
          AppUsageEntry(
            id: '',
            appName: 'Entertainment',
            category: 'entertainment',
            minutesUsed: _randBetween(15, 45),
            iconName: 'movie',
          ),
        ],
      ));
    }
  }

  // ─── Focus Timer ────────────────────────────────────────────────────

  Future<void> _createFocusTimerData(DateTime today) async {
    final tasks = ['Deep work', 'Code review', 'Writing', 'Research', 'Planning', 'Design', 'Study'];
    for (var i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final sessionCount = _randBetween(1, 2);
      for (var j = 0; j < sessionCount; j++) {
        final startHour = 9 + j * 3;
        final startTime = date.add(Duration(hours: startHour));
        await _focusTimerApi.createSession(FocusSessionModel(
          id: '',
          type: FocusSessionType.focus,
          startTime: startTime,
          endTime: startTime.add(const Duration(minutes: 25)),
          durationMinutes: 25,
          isCompleted: true,
          task: tasks[i % tasks.length],
        ));
      }
    }
  }
}
