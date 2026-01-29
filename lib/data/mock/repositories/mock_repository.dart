import 'package:assistant/data/local/hive_init.dart';
import 'package:assistant/data/mock/models/todo_model.dart';
import 'package:assistant/data/mock/models/inbox_message_model.dart';
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
import 'package:assistant/data/mock/models/screen_time_model.dart';
import 'package:assistant/data/mock/models/meditation_session_model.dart';

class MockRepository {
  static final MockRepository _instance = MockRepository._internal();
  factory MockRepository() => _instance;

  // Weather and ScreenTime remain in-memory (external data sources)
  WeatherForecastModel? _weather;
  final List<ScreenTimeModel> _screenTimeRecords = [];

  int _idCounter = 1;

  MockRepository._internal() {
    _initializeIdCounter();
    _initializeNonPersistedData();
  }

  String _generateId() => '${_idCounter++}';

  void _initializeIdCounter() {
    // Find the highest ID across all boxes to avoid ID collisions
    int maxId = 0;

    for (final item in HiveInit.todosBox.values) {
      final id = int.tryParse(item.id) ?? 0;
      if (id > maxId) maxId = id;
    }
    for (final item in HiveInit.inboxMessagesBox.values) {
      final id = int.tryParse(item.id) ?? 0;
      if (id > maxId) maxId = id;
    }
    for (final item in HiveInit.calendarEventsBox.values) {
      final id = int.tryParse(item.id) ?? 0;
      if (id > maxId) maxId = id;
    }
    for (final item in HiveInit.focusSessionsBox.values) {
      final id = int.tryParse(item.id) ?? 0;
      if (id > maxId) maxId = id;
    }
    for (final item in HiveInit.habitsBox.values) {
      final id = int.tryParse(item.id) ?? 0;
      if (id > maxId) maxId = id;
    }
    for (final item in HiveInit.waterLogsBox.values) {
      final id = int.tryParse(item.id) ?? 0;
      if (id > maxId) maxId = id;
    }
    for (final item in HiveInit.calorieEntriesBox.values) {
      final id = int.tryParse(item.id) ?? 0;
      if (id > maxId) maxId = id;
    }
    for (final item in HiveInit.sleepRecordsBox.values) {
      final id = int.tryParse(item.id) ?? 0;
      if (id > maxId) maxId = id;
    }
    for (final item in HiveInit.stepRecordsBox.values) {
      final id = int.tryParse(item.id) ?? 0;
      if (id > maxId) maxId = id;
    }
    for (final item in HiveInit.workoutSessionsBox.values) {
      final id = int.tryParse(item.id) ?? 0;
      if (id > maxId) maxId = id;
    }
    for (final item in HiveInit.heartRateRecordsBox.values) {
      final id = int.tryParse(item.id) ?? 0;
      if (id > maxId) maxId = id;
    }
    for (final item in HiveInit.moodEntriesBox.values) {
      final id = int.tryParse(item.id) ?? 0;
      if (id > maxId) maxId = id;
    }
    for (final item in HiveInit.meditationSessionsBox.values) {
      final id = int.tryParse(item.id) ?? 0;
      if (id > maxId) maxId = id;
    }

    _idCounter = maxId + 1;

    // If no data exists, seed with initial data
    if (_idCounter == 1) {
      _seedInitialData();
    }
  }

  void _initializeNonPersistedData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Initialize Weather (external API data - stays in memory)
    _weather = WeatherForecastModel(
      location: 'New York',
      currentTemperature: 24,
      currentCondition: WeatherConditionType.sunny,
      high: 28,
      low: 18,
      humidity: 45,
      windSpeed: 12,
      hourlyForecast: List.generate(24, (i) {
        final hour = now.add(Duration(hours: i));
        return HourlyForecast(
          time: hour,
          temperature: 20 + (i % 8),
          condition: i < 6
              ? WeatherConditionType.sunny
              : i < 12
                  ? WeatherConditionType.partlyCloudy
                  : i < 18
                      ? WeatherConditionType.cloudy
                      : WeatherConditionType.sunny,
        );
      }),
      dailyForecast: List.generate(7, (i) {
        final day = today.add(Duration(days: i));
        return DailyForecast(
          date: day,
          high: 26 + (i % 4),
          low: 16 + (i % 3),
          condition: i % 3 == 0
              ? WeatherConditionType.sunny
              : i % 3 == 1
                  ? WeatherConditionType.partlyCloudy
                  : WeatherConditionType.cloudy,
        );
      }),
    );

    // Initialize Screen Time (OS-level API data - stays in memory)
    _screenTimeRecords.addAll([
      ScreenTimeModel(
        id: 'st_1',
        date: today,
        totalMinutes: 225,
        pickups: 45,
        appUsage: [
          AppUsageModel(appName: 'Social Media', category: 'Social', minutesUsed: 65, iconName: 'people'),
          AppUsageModel(appName: 'Email', category: 'Productivity', minutesUsed: 45, iconName: 'email'),
          AppUsageModel(appName: 'Browser', category: 'Productivity', minutesUsed: 55, iconName: 'language'),
          AppUsageModel(appName: 'Games', category: 'Entertainment', minutesUsed: 30, iconName: 'games'),
          AppUsageModel(appName: 'Other', category: 'Other', minutesUsed: 30, iconName: 'apps'),
        ],
      ),
      ScreenTimeModel(
        id: 'st_2',
        date: today.subtract(const Duration(days: 1)),
        totalMinutes: 260,
        pickups: 52,
        appUsage: [
          AppUsageModel(appName: 'Social Media', category: 'Social', minutesUsed: 80, iconName: 'people'),
          AppUsageModel(appName: 'Email', category: 'Productivity', minutesUsed: 50, iconName: 'email'),
          AppUsageModel(appName: 'Browser', category: 'Productivity', minutesUsed: 60, iconName: 'language'),
          AppUsageModel(appName: 'Games', category: 'Entertainment', minutesUsed: 40, iconName: 'games'),
          AppUsageModel(appName: 'Other', category: 'Other', minutesUsed: 30, iconName: 'apps'),
        ],
      ),
    ]);
  }

  void _seedInitialData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Seed Todos
    final todos = [
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
    ];
    for (final todo in todos) {
      HiveInit.todosBox.put(todo.id, todo);
    }

    // Seed Messages
    final messages = [
      InboxMessageModel(
        id: _generateId(),
        service: 'Gmail',
        sender: 'John Smith',
        subject: 'Project Update',
        preview: 'Hey, just wanted to give you a quick update on...',
        receivedAt: now.subtract(const Duration(minutes: 15)),
      ),
      InboxMessageModel(
        id: _generateId(),
        service: 'Gmail',
        sender: 'Sarah Johnson',
        subject: 'Meeting Tomorrow',
        preview: 'Don\'t forget about our meeting at 2 PM...',
        receivedAt: now.subtract(const Duration(hours: 1)),
        isStarred: true,
      ),
      InboxMessageModel(
        id: _generateId(),
        service: 'Slack',
        sender: 'Dev Team',
        subject: 'New deployment ready',
        preview: 'The staging environment has been updated...',
        receivedAt: now.subtract(const Duration(hours: 2)),
        isRead: true,
      ),
      InboxMessageModel(
        id: _generateId(),
        service: 'Slack',
        sender: 'Mike Chen',
        subject: 'Bug report #123',
        preview: 'Found an issue with the login flow...',
        receivedAt: now.subtract(const Duration(hours: 3)),
      ),
      InboxMessageModel(
        id: _generateId(),
        service: 'Gmail',
        sender: 'HR Department',
        subject: 'Company Update',
        preview: 'Please review the attached policy changes...',
        receivedAt: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ];
    for (final msg in messages) {
      HiveInit.inboxMessagesBox.put(msg.id, msg);
    }

    // Seed Calendar Events
    final events = [
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
    ];
    for (final event in events) {
      HiveInit.calendarEventsBox.put(event.id, event);
    }

    // Seed Focus Sessions
    final focusSessions = [
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
    ];
    for (final session in focusSessions) {
      HiveInit.focusSessionsBox.put(session.id, session);
    }

    // Seed Habits
    final habits = [
      HabitModel(
        id: _generateId(),
        name: 'Morning Exercise',
        icon: 'fitness_center',
        streak: 7,
        isCompletedToday: true,
        completedDates: List.generate(7, (i) => today.subtract(Duration(days: i))),
      ),
      HabitModel(
        id: _generateId(),
        name: 'Read 30 mins',
        icon: 'menu_book',
        streak: 5,
        isCompletedToday: true,
        completedDates: List.generate(5, (i) => today.subtract(Duration(days: i))),
      ),
      HabitModel(
        id: _generateId(),
        name: 'Meditate',
        icon: 'self_improvement',
        streak: 3,
        isCompletedToday: true,
        completedDates: List.generate(3, (i) => today.subtract(Duration(days: i))),
      ),
      HabitModel(
        id: _generateId(),
        name: 'Journal',
        icon: 'edit_note',
        streak: 0,
        isCompletedToday: false,
      ),
      HabitModel(
        id: _generateId(),
        name: 'No Social Media',
        icon: 'phone_disabled',
        streak: 2,
        isCompletedToday: false,
        completedDates: [today.subtract(const Duration(days: 1)), today.subtract(const Duration(days: 2))],
      ),
    ];
    for (final habit in habits) {
      HiveInit.habitsBox.put(habit.id, habit);
    }

    // Seed Water Logs
    final waterLogs = [
      WaterLogModel(id: _generateId(), amountMl: 250, loggedAt: today.add(const Duration(hours: 8))),
      WaterLogModel(id: _generateId(), amountMl: 500, loggedAt: today.add(const Duration(hours: 10))),
      WaterLogModel(id: _generateId(), amountMl: 250, loggedAt: today.add(const Duration(hours: 12))),
    ];
    for (final log in waterLogs) {
      HiveInit.waterLogsBox.put(log.id, log);
    }

    // Seed Calorie Entries
    final calorieEntries = [
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
    ];
    for (final entry in calorieEntries) {
      HiveInit.calorieEntriesBox.put(entry.id, entry);
    }

    // Seed Sleep Records
    final sleepRecords = [
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
    ];
    for (final record in sleepRecords) {
      HiveInit.sleepRecordsBox.put(record.id, record);
    }

    // Seed Step Records
    final stepRecords = [
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
    ];
    for (final record in stepRecords) {
      HiveInit.stepRecordsBox.put(record.id, record);
    }

    // Seed Workout Sessions
    final workoutSessions = [
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
    ];
    for (final session in workoutSessions) {
      HiveInit.workoutSessionsBox.put(session.id, session);
    }

    // Seed Heart Rate Records
    final heartRateRecords = [
      HeartRateRecordModel(id: _generateId(), bpm: 72, recordedAt: now),
      HeartRateRecordModel(id: _generateId(), bpm: 68, recordedAt: now.subtract(const Duration(hours: 1))),
      HeartRateRecordModel(id: _generateId(), bpm: 85, recordedAt: now.subtract(const Duration(hours: 2))),
      HeartRateRecordModel(id: _generateId(), bpm: 120, recordedAt: now.subtract(const Duration(hours: 3))),
      HeartRateRecordModel(id: _generateId(), bpm: 65, recordedAt: now.subtract(const Duration(hours: 6))),
    ];
    for (final record in heartRateRecords) {
      HiveInit.heartRateRecordsBox.put(record.id, record);
    }

    // Seed Mood Entries
    final moodEntries = [
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
    ];
    for (final entry in moodEntries) {
      HiveInit.moodEntriesBox.put(entry.id, entry);
    }

    // Seed Meditation Sessions
    final meditationSessions = [
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
    ];
    for (final session in meditationSessions) {
      HiveInit.meditationSessionsBox.put(session.id, session);
    }
  }

  // ==================== TODOS ====================
  List<TodoModel> get todos => HiveInit.todosBox.values.toList();

  int get completedTodosCount => todos.where((t) => t.isCompleted).length;

  void addTodo(TodoModel todo) {
    final newTodo = todo.copyWith(id: _generateId());
    HiveInit.todosBox.put(newTodo.id, newTodo);
  }

  void updateTodo(TodoModel todo) {
    HiveInit.todosBox.put(todo.id, todo);
  }

  void deleteTodo(String id) {
    HiveInit.todosBox.delete(id);
  }

  void toggleTodoComplete(String id) {
    final todo = HiveInit.todosBox.get(id);
    if (todo != null) {
      final updated = todo.copyWith(isCompleted: !todo.isCompleted);
      HiveInit.todosBox.put(id, updated);
    }
  }

  // ==================== MESSAGES ====================
  List<InboxMessageModel> get messages => HiveInit.inboxMessagesBox.values.toList();

  int get unreadMessagesCount => messages.where((m) => !m.isRead).length;

  Set<String> get messageServices => messages.map((m) => m.service).toSet();

  void markMessageAsRead(String id) {
    final msg = HiveInit.inboxMessagesBox.get(id);
    if (msg != null) {
      final updated = msg.copyWith(isRead: true);
      HiveInit.inboxMessagesBox.put(id, updated);
    }
  }

  void toggleMessageStar(String id) {
    final msg = HiveInit.inboxMessagesBox.get(id);
    if (msg != null) {
      final updated = msg.copyWith(isStarred: !msg.isStarred);
      HiveInit.inboxMessagesBox.put(id, updated);
    }
  }

  void deleteMessage(String id) {
    HiveInit.inboxMessagesBox.delete(id);
  }

  // ==================== CALENDAR EVENTS ====================
  List<CalendarEventModel> get events => HiveInit.calendarEventsBox.values.toList();

  List<CalendarEventModel> getEventsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return events.where((e) {
      return e.startTime.isAfter(startOfDay.subtract(const Duration(seconds: 1))) && e.startTime.isBefore(endOfDay);
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  int get todayEventsCount {
    final today = DateTime.now();
    return getEventsForDate(today).length;
  }

  CalendarEventModel? get nextEvent {
    final now = DateTime.now();
    final upcoming = events.where((e) => e.startTime.isAfter(now)).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    return upcoming.isNotEmpty ? upcoming.first : null;
  }

  void addEvent(CalendarEventModel event) {
    final newEvent = event.copyWith(id: _generateId());
    HiveInit.calendarEventsBox.put(newEvent.id, newEvent);
  }

  void updateEvent(CalendarEventModel event) {
    HiveInit.calendarEventsBox.put(event.id, event);
  }

  void deleteEvent(String id) {
    HiveInit.calendarEventsBox.delete(id);
  }

  // ==================== FOCUS SESSIONS ====================
  List<FocusSessionModel> get focusSessions => HiveInit.focusSessionsBox.values.toList();

  int get todayCompletedSessions {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    return focusSessions.where((s) => s.isCompleted && s.startTime.isAfter(startOfDay)).length;
  }

  void addFocusSession(FocusSessionModel session) {
    final newSession = session.copyWith(id: _generateId());
    HiveInit.focusSessionsBox.put(newSession.id, newSession);
  }

  void completeFocusSession(String id) {
    final session = HiveInit.focusSessionsBox.get(id);
    if (session != null) {
      final updated = session.copyWith(
        isCompleted: true,
        endTime: DateTime.now(),
      );
      HiveInit.focusSessionsBox.put(id, updated);
    }
  }

  // ==================== HABITS ====================
  List<HabitModel> get habits => HiveInit.habitsBox.values.toList();

  int get completedHabitsToday => habits.where((h) => h.isCompletedToday).length;

  int get maxStreak => habits.isEmpty ? 0 : habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b);

  void addHabit(HabitModel habit) {
    final newHabit = habit.copyWith(id: _generateId());
    HiveInit.habitsBox.put(newHabit.id, newHabit);
  }

  void toggleHabitComplete(String id) {
    final habit = HiveInit.habitsBox.get(id);
    if (habit != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      HabitModel updated;
      if (habit.isCompletedToday) {
        // Un-complete
        final newCompletedDates = habit.completedDates.where((d) {
          final date = DateTime(d.year, d.month, d.day);
          return date != today;
        }).toList();
        updated = habit.copyWith(
          isCompletedToday: false,
          streak: habit.streak > 0 ? habit.streak - 1 : 0,
          completedDates: newCompletedDates,
        );
      } else {
        // Complete
        updated = habit.copyWith(
          isCompletedToday: true,
          streak: habit.streak + 1,
          completedDates: [...habit.completedDates, today],
        );
      }
      HiveInit.habitsBox.put(id, updated);
    }
  }

  void deleteHabit(String id) {
    HiveInit.habitsBox.delete(id);
  }

  // ==================== WEATHER ====================
  WeatherForecastModel? get weather => _weather;

  // ==================== WATER LOGS ====================
  List<WaterLogModel> get waterLogs => HiveInit.waterLogsBox.values.toList();

  int get todayWaterIntake {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    return waterLogs.where((l) => l.loggedAt.isAfter(startOfDay)).fold(0, (sum, l) => sum + l.amountMl);
  }

  void addWaterLog(int amountMl) {
    final log = WaterLogModel(
      id: _generateId(),
      amountMl: amountMl,
      loggedAt: DateTime.now(),
    );
    HiveInit.waterLogsBox.put(log.id, log);
  }

  void deleteWaterLog(String id) {
    HiveInit.waterLogsBox.delete(id);
  }

  // ==================== CALORIE ENTRIES ====================
  List<CalorieEntryModel> get calorieEntries => HiveInit.calorieEntriesBox.values.toList();

  int get todayCalories {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    return calorieEntries.where((e) => e.loggedAt.isAfter(startOfDay)).fold(0, (sum, e) => sum + e.calories);
  }

  List<CalorieEntryModel> get todayCalorieEntries {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    return calorieEntries.where((e) => e.loggedAt.isAfter(startOfDay)).toList();
  }

  void addCalorieEntry(CalorieEntryModel entry) {
    final newEntry = entry.copyWith(id: _generateId());
    HiveInit.calorieEntriesBox.put(newEntry.id, newEntry);
  }

  void deleteCalorieEntry(String id) {
    HiveInit.calorieEntriesBox.delete(id);
  }

  // ==================== SLEEP RECORDS ====================
  List<SleepRecordModel> get sleepRecords => HiveInit.sleepRecordsBox.values.toList();

  SleepRecordModel? get lastNightSleep {
    final records = sleepRecords;
    if (records.isEmpty) return null;
    return records.reduce((a, b) => a.wakeTime.isAfter(b.wakeTime) ? a : b);
  }

  void addSleepRecord(SleepRecordModel record) {
    final newRecord = record.copyWith(id: _generateId());
    HiveInit.sleepRecordsBox.put(newRecord.id, newRecord);
  }

  void deleteSleepRecord(String id) {
    HiveInit.sleepRecordsBox.delete(id);
  }

  // ==================== STEP RECORDS ====================
  List<StepRecordModel> get stepRecords => HiveInit.stepRecordsBox.values.toList();

  StepRecordModel? get todaySteps {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    try {
      return stepRecords.firstWhere(
        (r) => DateTime(r.date.year, r.date.month, r.date.day) == todayDate,
      );
    } catch (_) {
      return null;
    }
  }

  void updateTodaySteps(int steps) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final existing = stepRecords.where((r) => DateTime(r.date.year, r.date.month, r.date.day) == todayDate).toList();

    if (existing.isNotEmpty) {
      final updated = existing.first.copyWith(steps: steps);
      HiveInit.stepRecordsBox.put(existing.first.id, updated);
    } else {
      final newRecord = StepRecordModel(
        id: _generateId(),
        date: todayDate,
        steps: steps,
      );
      HiveInit.stepRecordsBox.put(newRecord.id, newRecord);
    }
  }

  // ==================== WORKOUT SESSIONS ====================
  List<WorkoutSessionModel> get workoutSessions => HiveInit.workoutSessionsBox.values.toList();

  int get todayWorkoutMinutes {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    return workoutSessions.where((w) => w.startTime.isAfter(startOfDay)).fold(0, (sum, w) => sum + w.durationMinutes);
  }

  int get todayWorkoutSessions {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    return workoutSessions.where((w) => w.startTime.isAfter(startOfDay)).length;
  }

  void addWorkoutSession(WorkoutSessionModel session) {
    final newSession = session.copyWith(id: _generateId());
    HiveInit.workoutSessionsBox.put(newSession.id, newSession);
  }

  void deleteWorkoutSession(String id) {
    HiveInit.workoutSessionsBox.delete(id);
  }

  // ==================== HEART RATE RECORDS ====================
  List<HeartRateRecordModel> get heartRateRecords => HiveInit.heartRateRecordsBox.values.toList();

  HeartRateRecordModel? get latestHeartRate {
    final records = heartRateRecords;
    if (records.isEmpty) return null;
    return records.reduce((a, b) => a.recordedAt.isAfter(b.recordedAt) ? a : b);
  }

  int get restingHeartRate {
    final restingRecords = heartRateRecords.where((r) => r.zone == HeartRateZone.resting);
    if (restingRecords.isEmpty) return 65;
    return (restingRecords.map((r) => r.bpm).reduce((a, b) => a + b) / restingRecords.length).round();
  }

  void addHeartRateRecord(int bpm) {
    final record = HeartRateRecordModel(
      id: _generateId(),
      bpm: bpm,
      recordedAt: DateTime.now(),
    );
    HiveInit.heartRateRecordsBox.put(record.id, record);
  }

  // ==================== MOOD ENTRIES ====================
  List<MoodEntryModel> get moodEntries => HiveInit.moodEntriesBox.values.toList();

  MoodEntryModel? get todayMood {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final todayEntries = moodEntries.where((m) => m.recordedAt.isAfter(startOfDay)).toList();
    if (todayEntries.isEmpty) return null;
    return todayEntries.reduce((a, b) => a.recordedAt.isAfter(b.recordedAt) ? a : b);
  }

  int get moodStreak {
    final entries = moodEntries;
    if (entries.isEmpty) return 0;
    final sorted = entries.toList()..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
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
      } else {
        break;
      }
    }
    return streak;
  }

  void addMoodEntry(MoodEntryModel entry) {
    final newEntry = entry.copyWith(id: _generateId());
    HiveInit.moodEntriesBox.put(newEntry.id, newEntry);
  }

  // ==================== SCREEN TIME ====================
  List<ScreenTimeModel> get screenTimeRecords => List.unmodifiable(_screenTimeRecords);

  ScreenTimeModel? get todayScreenTime {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    try {
      return _screenTimeRecords.firstWhere(
        (r) => DateTime(r.date.year, r.date.month, r.date.day) == todayDate,
      );
    } catch (_) {
      return null;
    }
  }

  ScreenTimeModel? get yesterdayScreenTime {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
    try {
      return _screenTimeRecords.firstWhere(
        (r) => DateTime(r.date.year, r.date.month, r.date.day) == yesterdayDate,
      );
    } catch (_) {
      return null;
    }
  }

  // ==================== MEDITATION SESSIONS ====================
  List<MeditationSessionModel> get meditationSessions => HiveInit.meditationSessionsBox.values.toList();

  int get todayMeditationMinutes {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    return meditationSessions
        .where((m) => m.startTime.isAfter(startOfDay) && m.isCompleted)
        .fold(0, (sum, m) => sum + m.durationMinutes);
  }

  int get meditationStreak {
    final sessions = meditationSessions;
    if (sessions.isEmpty) return 0;
    final completedSessions = sessions.where((m) => m.isCompleted).toList();
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

  void addMeditationSession(MeditationSessionModel session) {
    final newSession = session.copyWith(id: _generateId());
    HiveInit.meditationSessionsBox.put(newSession.id, newSession);
  }

  void completeMeditationSession(String id) {
    final session = HiveInit.meditationSessionsBox.get(id);
    if (session != null) {
      final updated = session.copyWith(isCompleted: true);
      HiveInit.meditationSessionsBox.put(id, updated);
    }
  }
}
