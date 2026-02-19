import 'package:assistant/data/mock/models/todo_model.dart';
import 'package:assistant/data/mock/models/calendar_event_model.dart';
import 'package:assistant/data/mock/models/focus_session_model.dart';
import 'package:assistant/data/mock/models/habit_model.dart';
import 'package:assistant/data/mock/models/weather_forecast_model.dart';
import 'package:assistant/data/mock/models/water_log_model.dart';
import 'package:assistant/data/mock/models/calorie_entry_model.dart';
import 'package:assistant/data/mock/models/sleep_record_model.dart';
import 'package:assistant/data/mock/models/step_record_model.dart';
import 'package:assistant/data/mock/models/workout_session_model.dart';
import 'package:assistant/data/mock/models/heart_rate_record_model.dart';
import 'package:assistant/data/mock/models/mood_entry_model.dart';
import 'package:assistant/data/mock/models/meditation_session_model.dart';

class MockRepository {
  static final MockRepository _instance = MockRepository._internal();
  factory MockRepository() => _instance;
  MockRepository._internal() {
    _initializeData();
  }

  // Data storage
  final List<TodoModel> _todos = [];
  final List<CalendarEventModel> _events = [];
  final List<FocusSessionModel> _focusSessions = [];
  final List<HabitModel> _habits = [];
  WeatherForecastModel? _weather;
  final List<WaterLogModel> _waterLogs = [];
  final List<CalorieEntryModel> _calorieEntries = [];
  final List<SleepRecordModel> _sleepRecords = [];
  final List<StepRecordModel> _stepRecords = [];
  final List<WorkoutSessionModel> _workoutSessions = [];
  final List<HeartRateRecordModel> _heartRateRecords = [];
  final List<MoodEntryModel> _moodEntries = [];
  final List<MeditationSessionModel> _meditationSessions = [];

  int _idCounter = 1;
  String _generateId() => '${_idCounter++}';

  void _initializeData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Initialize Todos
    _todos.addAll([
      TodoModel(
        id: _generateId(),
        title: 'Review project proposal',
        description: 'Go through the Q2 project proposal and provide feedback',
        createdAt: now.subtract(const Duration(days: 2)),
        dueDate: today.add(const Duration(days: 1)),
        priority: 1,
      ),
      TodoModel(
        id: _generateId(),
        title: 'Schedule team meeting',
        createdAt: now.subtract(const Duration(days: 1)),
        priority: 2,
      ),
      TodoModel(
        id: _generateId(),
        title: 'Update documentation',
        createdAt: now.subtract(const Duration(hours: 5)),
        priority: 3,
        isCompleted: true,
      ),
      TodoModel(
        id: _generateId(),
        title: 'Code review for PR #42',
        createdAt: now.subtract(const Duration(hours: 2)),
        priority: 1,
      ),
      TodoModel(
        id: _generateId(),
        title: 'Prepare presentation slides',
        description: 'For the upcoming client meeting',
        createdAt: now,
        dueDate: today.add(const Duration(days: 3)),
        priority: 2,
        isCompleted: true,
      ),
    ]);

    // Initialize Calendar Events
    _events.addAll([
      CalendarEventModel(
        id: _generateId(),
        title: 'Team Meeting',
        description: 'Weekly team sync',
        startTime: today.add(const Duration(hours: 14)),
        endTime: today.add(const Duration(hours: 15)),
        location: 'Conference Room A',
        color: '#6366F1',
      ),
      CalendarEventModel(
        id: _generateId(),
        title: 'Client Call',
        startTime: today.add(const Duration(hours: 16)),
        endTime: today.add(const Duration(hours: 17)),
        color: '#EC4899',
      ),
      CalendarEventModel(
        id: _generateId(),
        title: 'Lunch with Alex',
        startTime: today.add(const Duration(hours: 12)),
        endTime: today.add(const Duration(hours: 13)),
        location: 'Downtown Cafe',
        color: '#10B981',
      ),
      CalendarEventModel(
        id: _generateId(),
        title: 'Project Deadline',
        startTime: today.add(const Duration(days: 2)),
        endTime: today.add(const Duration(days: 2)),
        isAllDay: true,
        color: '#EF4444',
      ),
    ]);

    // Initialize Focus Sessions
    _focusSessions.addAll([
      FocusSessionModel(
        id: _generateId(),
        startTime: now.subtract(const Duration(hours: 3)),
        endTime: now.subtract(const Duration(hours: 2, minutes: 35)),
        durationMinutes: 25,
        isCompleted: true,
        task: 'Code review',
      ),
      FocusSessionModel(
        id: _generateId(),
        startTime: now.subtract(const Duration(hours: 5)),
        endTime: now.subtract(const Duration(hours: 4, minutes: 35)),
        durationMinutes: 25,
        isCompleted: true,
        task: 'Documentation',
      ),
    ]);

    // Initialize Habits
    _habits.addAll([
      HabitModel(
        id: _generateId(),
        name: 'Morning Exercise',
        description: 'Start the day with 30 minutes of cardio',
        icon: 'fitness_center',
        streak: 7,
        bestStreak: 14,
        isCompletedToday: true,
        completedDates: List.generate(7, (i) => today.subtract(Duration(days: i))),
        category: HabitCategory.fitness,
        frequency: HabitFrequency.daily,
        createdAt: today.subtract(const Duration(days: 30)),
      ),
      HabitModel(
        id: _generateId(),
        name: 'Read 30 mins',
        description: 'Read at least 30 minutes of non-fiction',
        icon: 'menu_book',
        streak: 5,
        bestStreak: 12,
        isCompletedToday: true,
        completedDates: List.generate(5, (i) => today.subtract(Duration(days: i))),
        category: HabitCategory.learning,
        frequency: HabitFrequency.daily,
        createdAt: today.subtract(const Duration(days: 20)),
      ),
      HabitModel(
        id: _generateId(),
        name: 'Meditate',
        description: 'Practice mindfulness meditation',
        icon: 'self_improvement',
        streak: 3,
        bestStreak: 21,
        isCompletedToday: true,
        completedDates: List.generate(3, (i) => today.subtract(Duration(days: i))),
        category: HabitCategory.mindfulness,
        frequency: HabitFrequency.daily,
        createdAt: today.subtract(const Duration(days: 45)),
      ),
      HabitModel(
        id: _generateId(),
        name: 'Journal',
        description: 'Write daily reflections and gratitude',
        icon: 'edit_note',
        streak: 0,
        bestStreak: 7,
        isCompletedToday: false,
        category: HabitCategory.mindfulness,
        frequency: HabitFrequency.daily,
        createdAt: today.subtract(const Duration(days: 15)),
      ),
      HabitModel(
        id: _generateId(),
        name: 'No Social Media',
        description: 'Avoid social media during work hours',
        icon: 'phone_disabled',
        streak: 2,
        bestStreak: 5,
        isCompletedToday: false,
        completedDates: [today.subtract(const Duration(days: 1)), today.subtract(const Duration(days: 2))],
        category: HabitCategory.productivity,
        frequency: HabitFrequency.weekdays,
        targetDays: [0, 1, 2, 3, 4], // Mon-Fri
        createdAt: today.subtract(const Duration(days: 10)),
      ),
      HabitModel(
        id: _generateId(),
        name: 'Drink 8 glasses of water',
        description: 'Stay hydrated throughout the day',
        icon: 'water_drop',
        streak: 4,
        bestStreak: 10,
        isCompletedToday: false,
        completedDates: List.generate(4, (i) => today.subtract(Duration(days: i + 1))),
        category: HabitCategory.health,
        frequency: HabitFrequency.daily,
        createdAt: today.subtract(const Duration(days: 25)),
      ),
      HabitModel(
        id: _generateId(),
        name: 'Call a friend',
        description: 'Stay connected with loved ones',
        icon: 'phone',
        streak: 1,
        bestStreak: 4,
        isCompletedToday: false,
        completedDates: [today.subtract(const Duration(days: 1))],
        category: HabitCategory.social,
        frequency: HabitFrequency.weekends,
        targetDays: [5, 6], // Sat-Sun
        createdAt: today.subtract(const Duration(days: 8)),
      ),
    ]);

    // Initialize Weather
    final sunrise = DateTime(now.year, now.month, now.day, 6, 32);
    final sunset = DateTime(now.year, now.month, now.day, 19, 48);

    final conditions = [
      WeatherConditionType.sunny,
      WeatherConditionType.partlyCloudy,
      WeatherConditionType.cloudy,
      WeatherConditionType.rainy,
      WeatherConditionType.sunny,
      WeatherConditionType.partlyCloudy,
      WeatherConditionType.stormy,
    ];

    final precipChances = [0, 10, 30, 75, 5, 15, 85];
    final uvIndices = [8, 6, 4, 2, 9, 5, 1];

    _weather = WeatherForecastModel(
      location: 'New York',
      currentTemperature: 24,
      currentCondition: WeatherConditionType.sunny,
      high: 28,
      low: 18,
      humidity: 45,
      windSpeed: 12,
      feelsLike: 26,
      uvIndex: 7,
      pressure: 1015,
      visibility: 16,
      precipChance: 10,
      windDirection: 'NE',
      sunrise: sunrise,
      sunset: sunset,
      dewPoint: 14,
      alerts: [
        WeatherAlert(
          id: _generateId(),
          type: 'heat',
          title: 'Heat Advisory',
          description: 'High temperatures expected this afternoon. Stay hydrated and avoid prolonged sun exposure.',
          startTime: today.add(const Duration(hours: 12)),
          endTime: today.add(const Duration(hours: 18)),
          severity: AlertSeverity.moderate,
        ),
      ],
      hourlyForecast: List.generate(48, (i) {
        final hour = now.add(Duration(hours: i));
        final baseTemp = 18 + (8 * (1 - ((hour.hour - 14).abs() / 14))).round();
        final condition = i < 6
            ? WeatherConditionType.sunny
            : i < 12
                ? WeatherConditionType.partlyCloudy
                : i < 18
                    ? WeatherConditionType.cloudy
                    : i < 24
                        ? WeatherConditionType.sunny
                        : conditions[i % conditions.length];
        return HourlyForecast(
          time: hour,
          temperature: baseTemp + (i % 3),
          condition: condition,
          precipChance: condition == WeatherConditionType.rainy
              ? 70 + (i % 20)
              : condition == WeatherConditionType.stormy
                  ? 85 + (i % 10)
                  : condition == WeatherConditionType.cloudy
                      ? 20 + (i % 15)
                      : (i % 10),
          feelsLike: baseTemp + (i % 3) + 2,
        );
      }),
      dailyForecast: List.generate(7, (i) {
        final day = today.add(Duration(days: i));
        final daySunrise = DateTime(day.year, day.month, day.day, 6, 30 + i);
        final daySunset = DateTime(day.year, day.month, day.day, 19, 45 - i);
        return DailyForecast(
          date: day,
          high: 26 + (i % 4),
          low: 16 + (i % 3),
          condition: conditions[i],
          precipChance: precipChances[i],
          uvIndex: uvIndices[i],
          sunrise: daySunrise,
          sunset: daySunset,
        );
      }),
    );

    // Initialize Water Logs
    _waterLogs.addAll([
      WaterLogModel(id: _generateId(), amountMl: 250, loggedAt: today.add(const Duration(hours: 8))),
      WaterLogModel(id: _generateId(), amountMl: 500, loggedAt: today.add(const Duration(hours: 10))),
      WaterLogModel(id: _generateId(), amountMl: 250, loggedAt: today.add(const Duration(hours: 12))),
    ]);

    // Initialize Calorie Entries
    _calorieEntries.addAll([
      CalorieEntryModel(
        id: _generateId(),
        foodName: 'Oatmeal with Berries',
        calories: 350,
        mealType: MealType.breakfast,
        loggedAt: today.add(const Duration(hours: 8)),
        protein: 12,
        carbs: 58,
        fat: 8,
      ),
      CalorieEntryModel(
        id: _generateId(),
        foodName: 'Grilled Chicken Salad',
        calories: 450,
        mealType: MealType.lunch,
        loggedAt: today.add(const Duration(hours: 12, minutes: 30)),
        protein: 35,
        carbs: 20,
        fat: 22,
      ),
      CalorieEntryModel(
        id: _generateId(),
        foodName: 'Apple',
        calories: 95,
        mealType: MealType.snack,
        loggedAt: today.add(const Duration(hours: 15)),
        carbs: 25,
      ),
    ]);

    // Initialize Sleep Records
    _sleepRecords.addAll([
      SleepRecordModel(
        id: _generateId(),
        bedTime: today.subtract(const Duration(hours: 8)),
        wakeTime: today,
        quality: SleepQuality.good,
      ),
      SleepRecordModel(
        id: _generateId(),
        bedTime: today.subtract(const Duration(days: 1, hours: 7)),
        wakeTime: today.subtract(const Duration(days: 1)),
        quality: SleepQuality.excellent,
      ),
      SleepRecordModel(
        id: _generateId(),
        bedTime: today.subtract(const Duration(days: 2, hours: 6)),
        wakeTime: today.subtract(const Duration(days: 2)),
        quality: SleepQuality.fair,
      ),
    ]);

    // Initialize Step Records
    _stepRecords.addAll([
      StepRecordModel(
        id: _generateId(),
        date: today,
        steps: 6543,
        goal: 10000,
        distanceKm: 4.8,
        caloriesBurned: 280,
      ),
      StepRecordModel(
        id: _generateId(),
        date: today.subtract(const Duration(days: 1)),
        steps: 10234,
        goal: 10000,
        distanceKm: 7.5,
        caloriesBurned: 420,
      ),
      StepRecordModel(
        id: _generateId(),
        date: today.subtract(const Duration(days: 2)),
        steps: 8765,
        goal: 10000,
        distanceKm: 6.4,
        caloriesBurned: 360,
      ),
    ]);

    // Initialize Workout Sessions
    _workoutSessions.addAll([
      WorkoutSessionModel(
        id: _generateId(),
        type: WorkoutType.running,
        startTime: today.add(const Duration(hours: 7)),
        endTime: today.add(const Duration(hours: 7, minutes: 30)),
        durationMinutes: 30,
        caloriesBurned: 280,
      ),
      WorkoutSessionModel(
        id: _generateId(),
        type: WorkoutType.strength,
        startTime: today.subtract(const Duration(days: 1, hours: -8)),
        endTime: today.subtract(const Duration(days: 1, hours: -9)),
        durationMinutes: 60,
        caloriesBurned: 350,
        exercises: [
          ExerciseModel(name: 'Bench Press', sets: 3, reps: 10, weight: 60),
          ExerciseModel(name: 'Squats', sets: 3, reps: 12, weight: 80),
          ExerciseModel(name: 'Deadlift', sets: 3, reps: 8, weight: 100),
        ],
      ),
    ]);

    // Initialize Heart Rate Records
    _heartRateRecords.addAll([
      HeartRateRecordModel(id: _generateId(), bpm: 72, recordedAt: now),
      HeartRateRecordModel(id: _generateId(), bpm: 68, recordedAt: now.subtract(const Duration(hours: 1))),
      HeartRateRecordModel(id: _generateId(), bpm: 85, recordedAt: now.subtract(const Duration(hours: 2))),
      HeartRateRecordModel(id: _generateId(), bpm: 120, recordedAt: now.subtract(const Duration(hours: 3))),
      HeartRateRecordModel(id: _generateId(), bpm: 65, recordedAt: now.subtract(const Duration(hours: 6))),
    ]);

    // Initialize Mood Entries
    _moodEntries.addAll([
      MoodEntryModel(
        id: _generateId(),
        mood: MoodLevel.good,
        recordedAt: today.add(const Duration(hours: 9)),
        notes: 'Feeling productive today!',
        activities: ['work', 'exercise'],
      ),
      MoodEntryModel(
        id: _generateId(),
        mood: MoodLevel.great,
        recordedAt: today.subtract(const Duration(days: 1)).add(const Duration(hours: 20)),
        activities: ['friends', 'relaxation'],
      ),
      MoodEntryModel(
        id: _generateId(),
        mood: MoodLevel.okay,
        recordedAt: today.subtract(const Duration(days: 2)).add(const Duration(hours: 12)),
      ),
    ]);

    // Initialize Meditation Sessions
    _meditationSessions.addAll([
      MeditationSessionModel(
        id: _generateId(),
        type: MeditationType.breathing,
        startTime: today.add(const Duration(hours: 7)),
        durationMinutes: 10,
        isCompleted: true,
      ),
      MeditationSessionModel(
        id: _generateId(),
        type: MeditationType.guided,
        startTime: today.subtract(const Duration(days: 1)).add(const Duration(hours: 22)),
        durationMinutes: 15,
        isCompleted: true,
      ),
      MeditationSessionModel(
        id: _generateId(),
        type: MeditationType.sleep,
        startTime: today.subtract(const Duration(days: 2)).add(const Duration(hours: 21)),
        durationMinutes: 20,
        isCompleted: true,
      ),
    ]);
  }

  // ==================== TODOS ====================
  List<TodoModel> get todos => List.unmodifiable(_todos);

  int get completedTodosCount => _todos.where((t) => t.isCompleted).length;

  void addTodo(TodoModel todo) {
    _todos.add(todo.copyWith(id: _generateId()));
  }

  void updateTodo(TodoModel todo) {
    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) _todos[index] = todo;
  }

  void deleteTodo(String id) {
    _todos.removeWhere((t) => t.id == id);
  }

  void toggleTodoComplete(String id) {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(isCompleted: !_todos[index].isCompleted);
    }
  }

  // ==================== CALENDAR EVENTS ====================
  List<CalendarEventModel> get events => List.unmodifiable(_events);

  List<CalendarEventModel> getEventsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return _events.where((e) {
      return e.startTime.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
             e.startTime.isBefore(endOfDay);
    }).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  int get todayEventsCount {
    final today = DateTime.now();
    return getEventsForDate(today).length;
  }

  CalendarEventModel? get nextEvent {
    final now = DateTime.now();
    final upcoming = _events.where((e) => e.startTime.isAfter(now)).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    return upcoming.isNotEmpty ? upcoming.first : null;
  }

  void addEvent(CalendarEventModel event) {
    _events.add(event.copyWith(id: _generateId()));
  }

  void updateEvent(CalendarEventModel event) {
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) _events[index] = event;
  }

  void deleteEvent(String id) {
    _events.removeWhere((e) => e.id == id);
  }

  // ==================== FOCUS SESSIONS ====================
  List<FocusSessionModel> get focusSessions => List.unmodifiable(_focusSessions);

  int get todayCompletedSessions {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    return _focusSessions.where((s) =>
      s.isCompleted && s.startTime.isAfter(startOfDay)
    ).length;
  }

  void addFocusSession(FocusSessionModel session) {
    _focusSessions.add(session.copyWith(id: _generateId()));
  }

  void completeFocusSession(String id) {
    final index = _focusSessions.indexWhere((s) => s.id == id);
    if (index != -1) {
      _focusSessions[index] = _focusSessions[index].copyWith(
        isCompleted: true,
        endTime: DateTime.now(),
      );
    }
  }

  // ==================== HABITS ====================
  List<HabitModel> get habits => List.unmodifiable(_habits);

  int get completedHabitsToday => _habits.where((h) => h.isCompletedToday).length;

  int get totalHabitsForToday => _habits.where((h) => h.isTodayTargetDay).length;

  int get maxStreak => _habits.isEmpty ? 0 : _habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b);

  int get maxBestStreak => _habits.isEmpty ? 0 : _habits.map((h) => h.bestStreak).reduce((a, b) => a > b ? a : b);

  void addHabit(HabitModel habit) {
    _habits.add(habit.copyWith(id: _generateId()));
  }

  void updateHabit(HabitModel habit) {
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
    }
  }

  List<HabitModel> getHabitsByCategory(HabitCategory category) {
    return _habits.where((h) => h.category == category).toList();
  }

  double getWeeklyCompletionRate() {
    if (_habits.isEmpty) return 0.0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    int totalTargetCompletions = 0;
    int actualCompletions = 0;

    for (final habit in _habits) {
      // Count target days this week up to today
      for (int i = 0; i <= today.difference(weekStart).inDays; i++) {
        final date = weekStart.add(Duration(days: i));
        final dayIndex = date.weekday - 1;
        if (habit.targetDays.contains(dayIndex)) {
          totalTargetCompletions++;
          // Check if completed on this date
          final completed = habit.completedDates.any((d) {
            final completedDate = DateTime(d.year, d.month, d.day);
            return completedDate == date;
          });
          if (completed) {
            actualCompletions++;
          }
        }
      }
    }

    if (totalTargetCompletions == 0) return 0.0;
    return actualCompletions / totalTargetCompletions;
  }

  Map<HabitCategory, int> get habitsByCategory {
    final Map<HabitCategory, int> counts = {};
    for (final habit in _habits) {
      counts[habit.category] = (counts[habit.category] ?? 0) + 1;
    }
    return counts;
  }

  void toggleHabitComplete(String id) {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      final habit = _habits[index];
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (habit.isCompletedToday) {
        // Un-complete
        final newCompletedDates = habit.completedDates.where((d) {
          final date = DateTime(d.year, d.month, d.day);
          return date != today;
        }).toList();
        _habits[index] = habit.copyWith(
          isCompletedToday: false,
          streak: habit.streak > 0 ? habit.streak - 1 : 0,
          completedDates: newCompletedDates,
        );
      } else {
        // Complete
        final newStreak = habit.streak + 1;
        _habits[index] = habit.copyWith(
          isCompletedToday: true,
          streak: newStreak,
          bestStreak: newStreak > habit.bestStreak ? newStreak : habit.bestStreak,
          completedDates: [...habit.completedDates, today],
        );
      }
    }
  }

  void deleteHabit(String id) {
    _habits.removeWhere((h) => h.id == id);
  }

  // ==================== WEATHER ====================
  WeatherForecastModel? get weather => _weather;

  DailyForecast? getWeatherForDate(DateTime date) {
    if (_weather == null) return null;
    final targetDate = DateTime(date.year, date.month, date.day);
    return _weather!.dailyForecast.cast<DailyForecast?>().firstWhere(
          (d) =>
              d != null &&
              DateTime(d.date.year, d.date.month, d.date.day) == targetDate,
          orElse: () => null,
        );
  }

  List<HourlyForecast> getHourlyForDate(DateTime date) {
    if (_weather == null) return [];
    final targetDate = DateTime(date.year, date.month, date.day);
    return _weather!.hourlyForecast.where((h) {
      final hourDate = DateTime(h.time.year, h.time.month, h.time.day);
      return hourDate == targetDate;
    }).toList();
  }

  void updateWeatherLocation(String location) {
    if (_weather == null) return;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final locationData = _getLocationWeatherData(location);

    final conditions = [
      WeatherConditionType.sunny,
      WeatherConditionType.partlyCloudy,
      WeatherConditionType.cloudy,
      WeatherConditionType.rainy,
      WeatherConditionType.sunny,
      WeatherConditionType.partlyCloudy,
      WeatherConditionType.stormy,
    ];

    _weather = WeatherForecastModel(
      location: location,
      currentTemperature: locationData['temp'] as int,
      currentCondition: locationData['condition'] as WeatherConditionType,
      high: locationData['high'] as int,
      low: locationData['low'] as int,
      humidity: locationData['humidity'] as int,
      windSpeed: locationData['windSpeed'] as int,
      feelsLike: locationData['feelsLike'] as int,
      uvIndex: locationData['uvIndex'] as int,
      pressure: locationData['pressure'] as int,
      visibility: locationData['visibility'] as int,
      precipChance: locationData['precipChance'] as int,
      windDirection: locationData['windDirection'] as String,
      sunrise: DateTime(now.year, now.month, now.day, 6, 30),
      sunset: DateTime(now.year, now.month, now.day, 19, 45),
      dewPoint: locationData['dewPoint'] as int,
      alerts: (locationData['alerts'] as List<WeatherAlert>?) ?? [],
      hourlyForecast: List.generate(48, (i) {
        final hour = now.add(Duration(hours: i));
        final baseTemp = (locationData['low'] as int) +
            (((locationData['high'] as int) - (locationData['low'] as int)) *
                    (1 - ((hour.hour - 14).abs() / 14)))
                .round();
        return HourlyForecast(
          time: hour,
          temperature: baseTemp + (i % 3),
          condition: conditions[i % conditions.length],
          precipChance: (i % 10) * 5,
          feelsLike: baseTemp + (i % 3) + 2,
        );
      }),
      dailyForecast: List.generate(7, (i) {
        final day = today.add(Duration(days: i));
        return DailyForecast(
          date: day,
          high: (locationData['high'] as int) + (i % 4) - 2,
          low: (locationData['low'] as int) + (i % 3) - 1,
          condition: conditions[i],
          precipChance: [0, 10, 30, 75, 5, 15, 85][i],
          uvIndex: [8, 6, 4, 2, 9, 5, 1][i],
          sunrise: DateTime(day.year, day.month, day.day, 6, 30 + i),
          sunset: DateTime(day.year, day.month, day.day, 19, 45 - i),
        );
      }),
    );
  }

  Map<String, dynamic> _getLocationWeatherData(String location) {
    final locationLower = location.toLowerCase();
    if (locationLower.contains('london')) {
      return {
        'temp': 18,
        'condition': WeatherConditionType.cloudy,
        'high': 21,
        'low': 14,
        'humidity': 72,
        'windSpeed': 18,
        'feelsLike': 17,
        'uvIndex': 4,
        'pressure': 1008,
        'visibility': 12,
        'precipChance': 45,
        'windDirection': 'W',
        'dewPoint': 12,
        'alerts': <WeatherAlert>[],
      };
    } else if (locationLower.contains('tokyo')) {
      return {
        'temp': 28,
        'condition': WeatherConditionType.partlyCloudy,
        'high': 31,
        'low': 24,
        'humidity': 68,
        'windSpeed': 8,
        'feelsLike': 32,
        'uvIndex': 9,
        'pressure': 1010,
        'visibility': 14,
        'precipChance': 20,
        'windDirection': 'SE',
        'dewPoint': 22,
        'alerts': <WeatherAlert>[],
      };
    } else if (locationLower.contains('sydney')) {
      return {
        'temp': 22,
        'condition': WeatherConditionType.sunny,
        'high': 25,
        'low': 18,
        'humidity': 55,
        'windSpeed': 15,
        'feelsLike': 23,
        'uvIndex': 10,
        'pressure': 1018,
        'visibility': 20,
        'precipChance': 5,
        'windDirection': 'NE',
        'dewPoint': 14,
        'alerts': <WeatherAlert>[],
      };
    } else if (locationLower.contains('paris')) {
      return {
        'temp': 20,
        'condition': WeatherConditionType.partlyCloudy,
        'high': 24,
        'low': 15,
        'humidity': 60,
        'windSpeed': 12,
        'feelsLike': 21,
        'uvIndex': 6,
        'pressure': 1012,
        'visibility': 15,
        'precipChance': 25,
        'windDirection': 'SW',
        'dewPoint': 13,
        'alerts': <WeatherAlert>[],
      };
    }
    // Default: New York
    return {
      'temp': 24,
      'condition': WeatherConditionType.sunny,
      'high': 28,
      'low': 18,
      'humidity': 45,
      'windSpeed': 12,
      'feelsLike': 26,
      'uvIndex': 7,
      'pressure': 1015,
      'visibility': 16,
      'precipChance': 10,
      'windDirection': 'NE',
      'dewPoint': 14,
      'alerts': <WeatherAlert>[
        WeatherAlert(
          id: '999',
          type: 'heat',
          title: 'Heat Advisory',
          description:
              'High temperatures expected. Stay hydrated and avoid prolonged sun exposure.',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 6)),
          severity: AlertSeverity.moderate,
        ),
      ],
    };
  }

  // ==================== WATER LOGS ====================
  List<WaterLogModel> get waterLogs => List.unmodifiable(_waterLogs);

  HydrationGoal _hydrationGoal = const HydrationGoal();

  HydrationGoal get hydrationGoal => _hydrationGoal;

  int get todayWaterIntake {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    return _waterLogs
        .where((l) => l.loggedAt.isAfter(startOfDay))
        .fold(0, (sum, l) => sum + l.amountMl);
  }

  List<WaterLogModel> getWaterLogsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return _waterLogs
        .where((l) => l.loggedAt.isAfter(startOfDay) && l.loggedAt.isBefore(endOfDay))
        .toList()
      ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
  }

  int getIntakeForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return _waterLogs
        .where((l) => l.loggedAt.isAfter(startOfDay) && l.loggedAt.isBefore(endOfDay))
        .fold(0, (sum, l) => sum + l.amountMl);
  }

  HydrationStats getWeeklyStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Calculate weekly average
    int totalIntake = 0;
    int daysWithData = 0;
    int goalMetDays = 0;

    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final intake = getIntakeForDate(date);
      if (intake > 0 || i == 0) {
        totalIntake += intake;
        daysWithData++;
        if (intake >= _hydrationGoal.dailyGoalMl) {
          goalMetDays++;
        }
      }
    }

    final weeklyAverage = daysWithData > 0 ? totalIntake / daysWithData : 0.0;
    final completionRate = daysWithData > 0 ? goalMetDays / daysWithData : 0.0;

    return HydrationStats(
      weeklyAverageMl: weeklyAverage,
      currentStreak: getCurrentStreak(),
      bestStreak: getBestStreak(),
      goalCompletionRate: completionRate,
    );
  }

  Map<String, int> getLast7DaysIntake() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final Map<String, int> result = {};

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dayName = dayNames[date.weekday - 1];
      result[dayName] = getIntakeForDate(date);
    }

    return result;
  }

  int getCurrentStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int streak = 0;

    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final intake = getIntakeForDate(date);

      if (intake >= _hydrationGoal.dailyGoalMl) {
        streak++;
      } else if (i > 0) {
        // Allow today to be incomplete
        break;
      }
    }

    return streak;
  }

  int getBestStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int bestStreak = 0;
    int currentStreak = 0;

    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final intake = getIntakeForDate(date);

      if (intake >= _hydrationGoal.dailyGoalMl) {
        currentStreak++;
        if (currentStreak > bestStreak) {
          bestStreak = currentStreak;
        }
      } else {
        currentStreak = 0;
      }
    }

    return bestStreak;
  }

  void updateDailyGoal(int goalMl) {
    _hydrationGoal = _hydrationGoal.copyWith(dailyGoalMl: goalMl);
  }

  void addWaterLog(int amountMl, {BeverageType type = BeverageType.water, String? note}) {
    _waterLogs.add(WaterLogModel(
      id: _generateId(),
      amountMl: amountMl,
      loggedAt: DateTime.now(),
      beverageType: type,
      note: note,
    ));
  }

  void deleteWaterLog(String id) {
    _waterLogs.removeWhere((l) => l.id == id);
  }

  // ==================== CALORIE ENTRIES ====================
  List<CalorieEntryModel> get calorieEntries => List.unmodifiable(_calorieEntries);

  NutritionGoal _nutritionGoal = const NutritionGoal();

  NutritionGoal get nutritionGoal => _nutritionGoal;

  int get todayCalories {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    return _calorieEntries
        .where((e) => e.loggedAt.isAfter(startOfDay))
        .fold(0, (sum, e) => sum + e.calories);
  }

  List<CalorieEntryModel> get todayCalorieEntries {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    return _calorieEntries.where((e) => e.loggedAt.isAfter(startOfDay)).toList();
  }

  List<CalorieEntryModel> getCalorieEntriesForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return _calorieEntries
        .where((e) => e.loggedAt.isAfter(startOfDay) && e.loggedAt.isBefore(endOfDay))
        .toList()
      ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
  }

  int getCaloriesForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return _calorieEntries
        .where((e) => e.loggedAt.isAfter(startOfDay) && e.loggedAt.isBefore(endOfDay))
        .fold(0, (sum, e) => sum + e.calories);
  }

  Map<String, int> getMacrosForDate(DateTime date) {
    final entries = getCalorieEntriesForDate(date);
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFat = 0;

    for (final entry in entries) {
      totalProtein += entry.protein ?? 0;
      totalCarbs += entry.carbs ?? 0;
      totalFat += entry.fat ?? 0;
    }

    return {
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fat': totalFat,
    };
  }

  NutritionStats getWeeklyNutritionStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int totalCalories = 0;
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFat = 0;
    int daysWithData = 0;
    int goalMetDays = 0;

    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final calories = getCaloriesForDate(date);
      final macros = getMacrosForDate(date);

      if (calories > 0 || i == 0) {
        totalCalories += calories;
        totalProtein += macros['protein'] ?? 0;
        totalCarbs += macros['carbs'] ?? 0;
        totalFat += macros['fat'] ?? 0;
        daysWithData++;

        if (calories >= _nutritionGoal.dailyCalorieGoal * 0.8 &&
            calories <= _nutritionGoal.dailyCalorieGoal) {
          goalMetDays++;
        }
      }
    }

    final weeklyAverage = daysWithData > 0 ? totalCalories / daysWithData : 0.0;
    final completionRate = daysWithData > 0 ? goalMetDays / daysWithData : 0.0;

    return NutritionStats(
      weeklyAverageCalories: weeklyAverage,
      currentStreak: getNutritionStreak(),
      bestStreak: getBestNutritionStreak(),
      goalCompletionRate: completionRate,
      avgProtein: daysWithData > 0 ? totalProtein / daysWithData : 0.0,
      avgCarbs: daysWithData > 0 ? totalCarbs / daysWithData : 0.0,
      avgFat: daysWithData > 0 ? totalFat / daysWithData : 0.0,
    );
  }

  Map<String, int> getLast7DaysCalories() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final Map<String, int> result = {};

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dayName = dayNames[date.weekday - 1];
      result[dayName] = getCaloriesForDate(date);
    }

    return result;
  }

  int getNutritionStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int streak = 0;

    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final calories = getCaloriesForDate(date);

      final withinGoal = calories >= _nutritionGoal.dailyCalorieGoal * 0.8 &&
          calories <= _nutritionGoal.dailyCalorieGoal;

      if (withinGoal) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }

    return streak;
  }

  int getBestNutritionStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int bestStreak = 0;
    int currentStreak = 0;

    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final calories = getCaloriesForDate(date);

      final withinGoal = calories >= _nutritionGoal.dailyCalorieGoal * 0.8 &&
          calories <= _nutritionGoal.dailyCalorieGoal;

      if (withinGoal) {
        currentStreak++;
        if (currentStreak > bestStreak) {
          bestStreak = currentStreak;
        }
      } else {
        currentStreak = 0;
      }
    }

    return bestStreak;
  }

  void updateCalorieGoal(int goalCal) {
    _nutritionGoal = _nutritionGoal.copyWith(dailyCalorieGoal: goalCal);
  }

  void updateMacroGoals(int protein, int carbs, int fat) {
    _nutritionGoal = _nutritionGoal.copyWith(
      proteinGoalGrams: protein,
      carbsGoalGrams: carbs,
      fatGoalGrams: fat,
    );
  }

  void addCalorieEntry(CalorieEntryModel entry) {
    _calorieEntries.add(entry.copyWith(id: _generateId()));
  }

  void deleteCalorieEntry(String id) {
    _calorieEntries.removeWhere((e) => e.id == id);
  }

  // ==================== SLEEP RECORDS ====================
  List<SleepRecordModel> get sleepRecords => List.unmodifiable(_sleepRecords);

  SleepGoal _sleepGoal = const SleepGoal();

  SleepGoal get sleepGoal => _sleepGoal;

  int get sleepGoalMinutes => _sleepGoal.goalMinutes;

  SleepRecordModel? get lastNightSleep {
    if (_sleepRecords.isEmpty) return null;
    return _sleepRecords.reduce((a, b) => a.wakeTime.isAfter(b.wakeTime) ? a : b);
  }

  void addSleepRecord(SleepRecordModel record) {
    _sleepRecords.add(record.copyWith(id: _generateId()));
  }

  void deleteSleepRecord(String id) {
    _sleepRecords.removeWhere((r) => r.id == id);
  }

  void updateSleepGoal(int minutes) {
    _sleepGoal = _sleepGoal.copyWith(goalMinutes: minutes);
  }

  SleepRecordModel? getSleepForDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return _sleepRecords.cast<SleepRecordModel?>().firstWhere(
      (r) {
        if (r == null) return false;
        final wakeDate = DateTime(r.wakeTime.year, r.wakeTime.month, r.wakeTime.day);
        return wakeDate == targetDate;
      },
      orElse: () => null,
    );
  }

  List<SleepRecordModel> getLast7DaysSleep() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<SleepRecordModel> result = [];

    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final record = getSleepForDate(date);
      if (record != null) {
        result.add(record);
      }
    }

    return result;
  }

  Map<String, double> getLast7DaysSleepHours() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final Map<String, double> result = {};

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dayName = dayNames[date.weekday - 1];
      final record = getSleepForDate(date);
      result[dayName] = record?.durationHours ?? 0.0;
    }

    return result;
  }

  double getAverageSleepDuration() {
    final records = getLast7DaysSleep();
    if (records.isEmpty) return 0.0;
    final totalHours = records.fold<double>(0.0, (sum, r) => sum + r.durationHours);
    return totalHours / records.length;
  }

  Map<SleepQuality, int> getQualityDistribution() {
    final records = getLast7DaysSleep();
    final Map<SleepQuality, int> distribution = {
      SleepQuality.poor: 0,
      SleepQuality.fair: 0,
      SleepQuality.good: 0,
      SleepQuality.excellent: 0,
    };

    for (final record in records) {
      distribution[record.quality] = (distribution[record.quality] ?? 0) + 1;
    }

    return distribution;
  }

  int getSleepStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int streak = 0;

    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final record = getSleepForDate(date);

      if (record != null && record.duration.inMinutes >= _sleepGoal.goalMinutes) {
        streak++;
      } else if (i > 0) {
        // Allow today to be incomplete
        break;
      }
    }

    return streak;
  }

  int getBestSleepStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int bestStreak = 0;
    int currentStreak = 0;

    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final record = getSleepForDate(date);

      if (record != null && record.duration.inMinutes >= _sleepGoal.goalMinutes) {
        currentStreak++;
        if (currentStreak > bestStreak) {
          bestStreak = currentStreak;
        }
      } else {
        currentStreak = 0;
      }
    }

    return bestStreak;
  }

  double getWeeklySleepScore() {
    final records = getLast7DaysSleep();
    if (records.isEmpty) return 0.0;

    int goalMetDays = 0;
    for (final record in records) {
      if (record.duration.inMinutes >= _sleepGoal.goalMinutes) {
        goalMetDays++;
      }
    }

    return (goalMetDays / 7) * 100;
  }

  SleepStats getWeeklySleepStats() {
    final records = getLast7DaysSleep();
    final avgDuration = getAverageSleepDuration();
    final qualityDist = getQualityDistribution();

    int daysWithData = records.length;
    int goalMetDays = 0;

    for (final record in records) {
      if (record.duration.inMinutes >= _sleepGoal.goalMinutes) {
        goalMetDays++;
      }
    }

    final completionRate = daysWithData > 0 ? goalMetDays / daysWithData : 0.0;

    return SleepStats(
      weeklyAverageHours: avgDuration,
      currentStreak: getSleepStreak(),
      bestStreak: getBestSleepStreak(),
      goalCompletionRate: completionRate,
      qualityDistribution: qualityDist,
    );
  }

  // ==================== STEP RECORDS ====================
  List<StepRecordModel> get stepRecords => List.unmodifiable(_stepRecords);

  StepsGoal _stepsGoal = const StepsGoal();

  StepsGoal get stepsGoal => _stepsGoal;

  void updateStepsGoal(int dailyGoal) {
    _stepsGoal = _stepsGoal.copyWith(dailyGoal: dailyGoal);
  }

  StepRecordModel? get todaySteps {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return _stepRecords.cast<StepRecordModel?>().firstWhere(
      (r) => r != null && DateTime(r.date.year, r.date.month, r.date.day) == todayDate,
      orElse: () => null,
    );
  }

  StepRecordModel? getStepsForDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return _stepRecords.cast<StepRecordModel?>().firstWhere(
      (r) {
        if (r == null) return false;
        final recordDate = DateTime(r.date.year, r.date.month, r.date.day);
        return recordDate == targetDate;
      },
      orElse: () => null,
    );
  }

  List<StepRecordModel> getLast7DaysSteps() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<StepRecordModel> result = [];

    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final record = getStepsForDate(date);
      if (record != null) {
        result.add(record);
      }
    }

    return result;
  }

  Map<String, int> getLast7DaysStepsMap() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final Map<String, int> result = {};

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dayName = dayNames[date.weekday - 1];
      final record = getStepsForDate(date);
      result[dayName] = record?.steps ?? 0;
    }

    return result;
  }

  double getAverageDailySteps() {
    final records = getLast7DaysSteps();
    if (records.isEmpty) return 0.0;
    final totalSteps = records.fold<int>(0, (sum, r) => sum + r.steps);
    return totalSteps / records.length;
  }

  int getStepsStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int streak = 0;

    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final record = getStepsForDate(date);

      if (record != null && record.steps >= _stepsGoal.dailyGoal) {
        streak++;
      } else if (i > 0) {
        // Allow today to be incomplete
        break;
      }
    }

    return streak;
  }

  int getBestStepsStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int bestStreak = 0;
    int currentStreak = 0;

    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final record = getStepsForDate(date);

      if (record != null && record.steps >= _stepsGoal.dailyGoal) {
        currentStreak++;
        if (currentStreak > bestStreak) {
          bestStreak = currentStreak;
        }
      } else {
        currentStreak = 0;
      }
    }

    return bestStreak;
  }

  double getWeeklyStepsCompletionRate() {
    final records = getLast7DaysSteps();
    if (records.isEmpty) return 0.0;

    int goalMetDays = 0;
    for (final record in records) {
      if (record.steps >= _stepsGoal.dailyGoal) {
        goalMetDays++;
      }
    }

    return goalMetDays / records.length;
  }

  StepsStats getWeeklyStepsStats() {
    final records = getLast7DaysSteps();
    final avgSteps = getAverageDailySteps();
    final currentStreak = getStepsStreak();
    final bestStreak = getBestStepsStreak();
    final completionRate = getWeeklyStepsCompletionRate();

    double totalDistance = 0.0;
    int totalCalories = 0;

    for (final record in records) {
      totalDistance += record.distanceKm;
      totalCalories += record.caloriesBurned;
    }

    return StepsStats(
      weeklyAverageSteps: avgSteps,
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      goalCompletionRate: completionRate,
      totalDistanceKm: totalDistance,
      totalCaloriesBurned: totalCalories,
    );
  }

  void addSteps(int steps) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final index = _stepRecords.indexWhere((r) =>
      DateTime(r.date.year, r.date.month, r.date.day) == todayDate
    );

    // Calculate distance and calories (approximate: 0.0008 km per step, 0.04 cal per step)
    final newDistance = steps * 0.0008;
    final newCalories = (steps * 0.04).round();

    if (index != -1) {
      final current = _stepRecords[index];
      _stepRecords[index] = current.copyWith(
        steps: current.steps + steps,
        distanceKm: current.distanceKm + newDistance,
        caloriesBurned: current.caloriesBurned + newCalories,
        goal: _stepsGoal.dailyGoal,
      );
    } else {
      _stepRecords.add(StepRecordModel(
        id: _generateId(),
        date: todayDate,
        steps: steps,
        goal: _stepsGoal.dailyGoal,
        distanceKm: newDistance,
        caloriesBurned: newCalories,
      ));
    }
  }

  void updateTodaySteps(int steps) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final index = _stepRecords.indexWhere((r) =>
      DateTime(r.date.year, r.date.month, r.date.day) == todayDate
    );

    // Calculate distance and calories
    final distance = steps * 0.0008;
    final calories = (steps * 0.04).round();

    if (index != -1) {
      _stepRecords[index] = _stepRecords[index].copyWith(
        steps: steps,
        distanceKm: distance,
        caloriesBurned: calories,
        goal: _stepsGoal.dailyGoal,
      );
    } else {
      _stepRecords.add(StepRecordModel(
        id: _generateId(),
        date: todayDate,
        steps: steps,
        goal: _stepsGoal.dailyGoal,
        distanceKm: distance,
        caloriesBurned: calories,
      ));
    }
  }

  void deleteStepRecord(String id) {
    _stepRecords.removeWhere((r) => r.id == id);
  }

  // ==================== WORKOUT SESSIONS ====================
  List<WorkoutSessionModel> get workoutSessions => List.unmodifiable(_workoutSessions);

  WorkoutGoal _workoutGoal = const WorkoutGoal();

  WorkoutGoal get workoutGoal => _workoutGoal;

  void updateWorkoutGoal({int? weeklyMinutesGoal, int? weeklySessionsGoal}) {
    _workoutGoal = _workoutGoal.copyWith(
      weeklyMinutesGoal: weeklyMinutesGoal,
      weeklySessionsGoal: weeklySessionsGoal,
    );
  }

  int get todayWorkoutMinutes {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    return _workoutSessions
        .where((w) => w.startTime.isAfter(startOfDay))
        .fold(0, (sum, w) => sum + w.durationMinutes);
  }

  int get todayWorkoutSessions {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    return _workoutSessions.where((w) => w.startTime.isAfter(startOfDay)).length;
  }

  int get todayWorkoutCalories {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    return _workoutSessions
        .where((w) => w.startTime.isAfter(startOfDay))
        .fold(0, (sum, w) => sum + w.caloriesBurned);
  }

  List<WorkoutSessionModel> getWorkoutsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return _workoutSessions
        .where((w) => w.startTime.isAfter(startOfDay) && w.startTime.isBefore(endOfDay))
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  List<WorkoutSessionModel> getLast7DaysWorkouts() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));
    return _workoutSessions
        .where((w) => w.startTime.isAfter(weekAgo))
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  Map<String, int> getLast7DaysWorkoutMinutesMap() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final Map<String, int> result = {};

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dayName = dayNames[date.weekday - 1];
      final dayWorkouts = getWorkoutsForDate(date);
      result[dayName] = dayWorkouts.fold(0, (sum, w) => sum + w.durationMinutes);
    }

    return result;
  }

  int getWorkoutStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int streak = 0;

    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final dayWorkouts = getWorkoutsForDate(date);
      final dayMinutes = dayWorkouts.fold(0, (sum, w) => sum + w.durationMinutes);

      if (dayMinutes > 0) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }

    return streak;
  }

  int getBestWorkoutStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int bestStreak = 0;
    int currentStreak = 0;

    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final dayWorkouts = getWorkoutsForDate(date);
      final dayMinutes = dayWorkouts.fold(0, (sum, w) => sum + w.durationMinutes);

      if (dayMinutes > 0) {
        currentStreak++;
        if (currentStreak > bestStreak) {
          bestStreak = currentStreak;
        }
      } else {
        currentStreak = 0;
      }
    }

    return bestStreak;
  }

  WorkoutStats getWeeklyWorkoutStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));

    final weekWorkouts = _workoutSessions
        .where((w) => w.startTime.isAfter(weekAgo))
        .toList();

    int totalMinutes = 0;
    int totalCalories = 0;
    final Map<WorkoutType, int> byType = {};

    for (final workout in weekWorkouts) {
      totalMinutes += workout.durationMinutes;
      totalCalories += workout.caloriesBurned;
      byType[workout.type] = (byType[workout.type] ?? 0) + 1;
    }

    int daysWithWorkout = 0;
    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final dayWorkouts = getWorkoutsForDate(date);
      if (dayWorkouts.isNotEmpty) {
        daysWithWorkout++;
      }
    }

    final completionRate = daysWithWorkout / 7;

    return WorkoutStats(
      weeklyMinutes: totalMinutes,
      weeklySessions: weekWorkouts.length,
      weeklyCalories: totalCalories,
      currentStreak: getWorkoutStreak(),
      bestStreak: getBestWorkoutStreak(),
      goalCompletionRate: completionRate,
      workoutsByType: byType,
    );
  }

  void addWorkoutSession(WorkoutSessionModel session) {
    _workoutSessions.add(session.copyWith(id: _generateId()));
  }

  void deleteWorkoutSession(String id) {
    _workoutSessions.removeWhere((w) => w.id == id);
  }

  // ==================== HEART RATE RECORDS ====================
  List<HeartRateRecordModel> get heartRateRecords => List.unmodifiable(_heartRateRecords);

  HeartRateGoal _heartRateGoal = const HeartRateGoal();

  HeartRateGoal get heartRateGoal => _heartRateGoal;

  void updateHeartRateGoal({int? targetRestingBpm, int? maxBpm}) {
    _heartRateGoal = _heartRateGoal.copyWith(
      targetRestingBpm: targetRestingBpm,
      maxBpm: maxBpm,
    );
  }

  HeartRateRecordModel? get latestHeartRate {
    if (_heartRateRecords.isEmpty) return null;
    return _heartRateRecords.reduce((a, b) => a.recordedAt.isAfter(b.recordedAt) ? a : b);
  }

  int get restingHeartRate {
    final restingRecords = _heartRateRecords.where((r) => r.zone == HeartRateZone.resting);
    if (restingRecords.isEmpty) return 65;
    return (restingRecords.map((r) => r.bpm).reduce((a, b) => a + b) / restingRecords.length).round();
  }

  List<HeartRateRecordModel> getHeartRatesForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return _heartRateRecords
        .where((r) => r.recordedAt.isAfter(startOfDay) && r.recordedAt.isBefore(endOfDay))
        .toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  }

  List<HeartRateRecordModel> getLast7DaysHeartRates() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));
    return _heartRateRecords
        .where((r) => r.recordedAt.isAfter(weekAgo))
        .toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  }

  Map<String, int> getLast7DaysHeartRateMap() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final Map<String, int> result = {};

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dayName = dayNames[date.weekday - 1];
      final dayRecords = getHeartRatesForDate(date);
      if (dayRecords.isNotEmpty) {
        final avg = dayRecords.fold(0, (sum, r) => sum + r.bpm) / dayRecords.length;
        result[dayName] = avg.round();
      } else {
        result[dayName] = 0;
      }
    }

    return result;
  }

  int getHeartRateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int streak = 0;

    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final dayRecords = getHeartRatesForDate(date);

      if (dayRecords.isNotEmpty) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }

    return streak;
  }

  int getBestHeartRateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int bestStreak = 0;
    int currentStreak = 0;

    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final dayRecords = getHeartRatesForDate(date);

      if (dayRecords.isNotEmpty) {
        currentStreak++;
        if (currentStreak > bestStreak) {
          bestStreak = currentStreak;
        }
      } else {
        currentStreak = 0;
      }
    }

    return bestStreak;
  }

  HeartRateStats getWeeklyHeartRateStats() {
    final weekRecords = getLast7DaysHeartRates();

    if (weekRecords.isEmpty) {
      return const HeartRateStats();
    }

    final restingRecords = weekRecords.where((r) => r.zone == HeartRateZone.resting || r.zone == HeartRateZone.warmUp).toList();
    final activeRecords = weekRecords.where((r) => r.zone == HeartRateZone.fatBurn || r.zone == HeartRateZone.cardio || r.zone == HeartRateZone.peak).toList();

    final avgResting = restingRecords.isNotEmpty
        ? restingRecords.fold(0, (sum, r) => sum + r.bpm) / restingRecords.length
        : 0.0;
    final avgActive = activeRecords.isNotEmpty
        ? activeRecords.fold(0, (sum, r) => sum + r.bpm) / activeRecords.length
        : 0.0;

    final allBpm = weekRecords.map((r) => r.bpm).toList();
    final minBpm = allBpm.reduce((a, b) => a < b ? a : b);
    final maxBpm = allBpm.reduce((a, b) => a > b ? a : b);

    final Map<HeartRateZone, int> zoneDist = {};
    for (final record in weekRecords) {
      zoneDist[record.zone] = (zoneDist[record.zone] ?? 0) + 1;
    }

    return HeartRateStats(
      averageRestingBpm: avgResting,
      averageActiveBpm: avgActive,
      minBpm: minBpm,
      maxBpm: maxBpm,
      currentStreak: getHeartRateStreak(),
      bestStreak: getBestHeartRateStreak(),
      totalReadings: weekRecords.length,
      zoneDistribution: zoneDist,
    );
  }

  void addHeartRateRecord(int bpm) {
    _heartRateRecords.add(HeartRateRecordModel(
      id: _generateId(),
      bpm: bpm,
      recordedAt: DateTime.now(),
    ));
  }

  void deleteHeartRateRecord(String id) {
    _heartRateRecords.removeWhere((r) => r.id == id);
  }

  // ==================== MOOD ENTRIES ====================
  List<MoodEntryModel> get moodEntries => List.unmodifiable(_moodEntries);

  MoodGoal _moodGoal = const MoodGoal();

  MoodGoal get moodGoal => _moodGoal;

  void updateMoodGoal({int? dailyEntriesGoal, MoodLevel? targetMood}) {
    _moodGoal = _moodGoal.copyWith(
      dailyEntriesGoal: dailyEntriesGoal,
      targetMood: targetMood,
    );
  }

  MoodEntryModel? get todayMood {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final todayEntries = _moodEntries.where((m) => m.recordedAt.isAfter(startOfDay)).toList();
    if (todayEntries.isEmpty) return null;
    return todayEntries.reduce((a, b) => a.recordedAt.isAfter(b.recordedAt) ? a : b);
  }

  List<MoodEntryModel> getMoodEntriesForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return _moodEntries
        .where((m) => m.recordedAt.isAfter(startOfDay) && m.recordedAt.isBefore(endOfDay))
        .toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  }

  List<MoodEntryModel> getLast7DaysMoodEntries() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));
    return _moodEntries
        .where((m) => m.recordedAt.isAfter(weekAgo))
        .toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  }

  Map<String, double> getLast7DaysMoodMap() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final Map<String, double> result = {};

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dayName = dayNames[date.weekday - 1];
      final dayEntries = getMoodEntriesForDate(date);
      if (dayEntries.isNotEmpty) {
        final avg = dayEntries.fold(0, (sum, m) => sum + m.mood.index) / dayEntries.length;
        result[dayName] = 4 - avg; // Invert so great=4, awful=0
      } else {
        result[dayName] = -1; // No data
      }
    }

    return result;
  }

  int get moodStreak {
    if (_moodEntries.isEmpty) return 0;
    final sorted = _moodEntries.toList()..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    int streak = 0;
    DateTime? lastDate;
    for (final entry in sorted) {
      final entryDate = DateTime(entry.recordedAt.year, entry.recordedAt.month, entry.recordedAt.day);
      if (lastDate == null) {
        streak = 1;
        lastDate = entryDate;
      } else if (lastDate.difference(entryDate).inDays == 1) {
        streak++;
        lastDate = entryDate;
      } else if (lastDate != entryDate) {
        break;
      }
    }
    return streak;
  }

  int getBestMoodStreak() {
    if (_moodEntries.isEmpty) return 0;
    final sorted = _moodEntries.toList()..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    int bestStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;

    for (final entry in sorted) {
      final entryDate = DateTime(entry.recordedAt.year, entry.recordedAt.month, entry.recordedAt.day);
      if (lastDate == null) {
        currentStreak = 1;
        lastDate = entryDate;
      } else if (lastDate.difference(entryDate).inDays == 1) {
        currentStreak++;
        lastDate = entryDate;
      } else if (lastDate != entryDate) {
        if (currentStreak > bestStreak) {
          bestStreak = currentStreak;
        }
        currentStreak = 1;
        lastDate = entryDate;
      }
    }

    if (currentStreak > bestStreak) {
      bestStreak = currentStreak;
    }

    return bestStreak;
  }

  MoodStats getWeeklyMoodStats() {
    final weekEntries = getLast7DaysMoodEntries();

    if (weekEntries.isEmpty) {
      return const MoodStats();
    }

    // Calculate average mood (0=awful, 4=great -> invert for display)
    final totalMoodValue = weekEntries.fold(0, (sum, m) => sum + (4 - m.mood.index));
    final avgMood = totalMoodValue / weekEntries.length;

    // Mood distribution
    final Map<MoodLevel, int> moodDist = {};
    for (final entry in weekEntries) {
      moodDist[entry.mood] = (moodDist[entry.mood] ?? 0) + 1;
    }

    // Common activities
    final Map<String, int> activities = {};
    for (final entry in weekEntries) {
      for (final activity in entry.activities) {
        activities[activity] = (activities[activity] ?? 0) + 1;
      }
    }

    return MoodStats(
      weeklyAverageMood: avgMood,
      currentStreak: moodStreak,
      bestStreak: getBestMoodStreak(),
      totalEntries: weekEntries.length,
      moodDistribution: moodDist,
      commonActivities: activities,
    );
  }

  void addMoodEntry(MoodEntryModel entry) {
    _moodEntries.add(entry.copyWith(id: _generateId()));
  }

  void deleteMoodEntry(String id) {
    _moodEntries.removeWhere((m) => m.id == id);
  }

  // ==================== MEDITATION SESSIONS ====================
  List<MeditationSessionModel> get meditationSessions => List.unmodifiable(_meditationSessions);

  MeditationGoal _meditationGoal = const MeditationGoal();

  MeditationGoal get meditationGoal => _meditationGoal;

  void updateMeditationGoal({int? dailyMinutesGoal, int? weeklySessionsGoal}) {
    _meditationGoal = _meditationGoal.copyWith(
      dailyMinutesGoal: dailyMinutesGoal,
      weeklySessionsGoal: weeklySessionsGoal,
    );
  }

  int get todayMeditationMinutes {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    return _meditationSessions
        .where((m) => m.startTime.isAfter(startOfDay) && m.isCompleted)
        .fold(0, (sum, m) => sum + m.durationMinutes);
  }

  int get todayMeditationSessions {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    return _meditationSessions
        .where((m) => m.startTime.isAfter(startOfDay) && m.isCompleted)
        .length;
  }

  List<MeditationSessionModel> getMeditationsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return _meditationSessions
        .where((m) => m.startTime.isAfter(startOfDay) && m.startTime.isBefore(endOfDay) && m.isCompleted)
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  List<MeditationSessionModel> getLast7DaysMeditations() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));
    return _meditationSessions
        .where((m) => m.startTime.isAfter(weekAgo) && m.isCompleted)
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  Map<String, int> getLast7DaysMeditationMinutesMap() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final Map<String, int> result = {};

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dayName = dayNames[date.weekday - 1];
      final daySessions = getMeditationsForDate(date);
      result[dayName] = daySessions.fold(0, (sum, m) => sum + m.durationMinutes);
    }

    return result;
  }

  int get meditationStreak {
    if (_meditationSessions.isEmpty) return 0;
    final completedSessions = _meditationSessions.where((m) => m.isCompleted).toList();
    if (completedSessions.isEmpty) return 0;

    completedSessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    int streak = 0;
    DateTime? lastDate;

    for (final session in completedSessions) {
      final sessionDate = DateTime(session.startTime.year, session.startTime.month, session.startTime.day);
      if (lastDate == null) {
        streak = 1;
        lastDate = sessionDate;
      } else if (lastDate.difference(sessionDate).inDays == 1) {
        streak++;
        lastDate = sessionDate;
      } else if (lastDate != sessionDate) {
        break;
      }
    }
    return streak;
  }

  int getBestMeditationStreak() {
    if (_meditationSessions.isEmpty) return 0;
    final completedSessions = _meditationSessions.where((m) => m.isCompleted).toList();
    if (completedSessions.isEmpty) return 0;

    completedSessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    int bestStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;

    for (final session in completedSessions) {
      final sessionDate = DateTime(session.startTime.year, session.startTime.month, session.startTime.day);
      if (lastDate == null) {
        currentStreak = 1;
        lastDate = sessionDate;
      } else if (lastDate.difference(sessionDate).inDays == 1) {
        currentStreak++;
        lastDate = sessionDate;
      } else if (lastDate != sessionDate) {
        if (currentStreak > bestStreak) {
          bestStreak = currentStreak;
        }
        currentStreak = 1;
        lastDate = sessionDate;
      }
    }

    if (currentStreak > bestStreak) {
      bestStreak = currentStreak;
    }

    return bestStreak;
  }

  MeditationStats getWeeklyMeditationStats() {
    final weekSessions = getLast7DaysMeditations();

    if (weekSessions.isEmpty) {
      return const MeditationStats();
    }

    int totalMinutes = 0;
    final Map<MeditationType, int> byType = {};

    for (final session in weekSessions) {
      totalMinutes += session.durationMinutes;
      byType[session.type] = (byType[session.type] ?? 0) + 1;
    }

    // Calculate goal completion rate based on daily minutes goal
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int daysMetGoal = 0;

    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final daySessions = getMeditationsForDate(date);
      final dayMinutes = daySessions.fold(0, (sum, m) => sum + m.durationMinutes);
      if (dayMinutes >= _meditationGoal.dailyMinutesGoal) {
        daysMetGoal++;
      }
    }

    final completionRate = daysMetGoal / 7;

    return MeditationStats(
      weeklyMinutes: totalMinutes,
      weeklySessions: weekSessions.length,
      currentStreak: meditationStreak,
      bestStreak: getBestMeditationStreak(),
      goalCompletionRate: completionRate,
      sessionsByType: byType,
    );
  }

  void addMeditationSession(MeditationSessionModel session) {
    _meditationSessions.add(session.copyWith(id: _generateId()));
  }

  void deleteMeditationSession(String id) {
    _meditationSessions.removeWhere((m) => m.id == id);
  }

  void completeMeditationSession(String id) {
    final index = _meditationSessions.indexWhere((m) => m.id == id);
    if (index != -1) {
      _meditationSessions[index] = _meditationSessions[index].copyWith(isCompleted: true);
    }
  }
}
