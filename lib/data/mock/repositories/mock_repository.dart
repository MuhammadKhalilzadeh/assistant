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
  MockRepository._internal() {
    _initializeData();
  }

  // Data storage
  final List<TodoModel> _todos = [];
  final List<InboxMessageModel> _messages = [];
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
  final List<ScreenTimeModel> _screenTimeRecords = [];
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

    // Initialize Messages
    _messages.addAll([
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
    ]);

    // Initialize Weather
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
          condition: i < 6 ? WeatherConditionType.sunny :
                    i < 12 ? WeatherConditionType.partlyCloudy :
                    i < 18 ? WeatherConditionType.cloudy : WeatherConditionType.sunny,
        );
      }),
      dailyForecast: List.generate(7, (i) {
        final day = today.add(Duration(days: i));
        return DailyForecast(
          date: day,
          high: 26 + (i % 4),
          low: 16 + (i % 3),
          condition: i % 3 == 0 ? WeatherConditionType.sunny :
                    i % 3 == 1 ? WeatherConditionType.partlyCloudy : WeatherConditionType.cloudy,
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

    // Initialize Screen Time
    _screenTimeRecords.addAll([
      ScreenTimeModel(
        id: _generateId(),
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
        id: _generateId(),
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

  // ==================== MESSAGES ====================
  List<InboxMessageModel> get messages => List.unmodifiable(_messages);

  int get unreadMessagesCount => _messages.where((m) => !m.isRead).length;

  Set<String> get messageServices => _messages.map((m) => m.service).toSet();

  void markMessageAsRead(String id) {
    final index = _messages.indexWhere((m) => m.id == id);
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(isRead: true);
    }
  }

  void toggleMessageStar(String id) {
    final index = _messages.indexWhere((m) => m.id == id);
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(isStarred: !_messages[index].isStarred);
    }
  }

  void deleteMessage(String id) {
    _messages.removeWhere((m) => m.id == id);
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

  int get maxStreak => _habits.isEmpty ? 0 : _habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b);

  void addHabit(HabitModel habit) {
    _habits.add(habit.copyWith(id: _generateId()));
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
        _habits[index] = habit.copyWith(
          isCompletedToday: true,
          streak: habit.streak + 1,
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

  // ==================== WATER LOGS ====================
  List<WaterLogModel> get waterLogs => List.unmodifiable(_waterLogs);

  int get todayWaterIntake {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    return _waterLogs
        .where((l) => l.loggedAt.isAfter(startOfDay))
        .fold(0, (sum, l) => sum + l.amountMl);
  }

  void addWaterLog(int amountMl) {
    _waterLogs.add(WaterLogModel(
      id: _generateId(),
      amountMl: amountMl,
      loggedAt: DateTime.now(),
    ));
  }

  void deleteWaterLog(String id) {
    _waterLogs.removeWhere((l) => l.id == id);
  }

  // ==================== CALORIE ENTRIES ====================
  List<CalorieEntryModel> get calorieEntries => List.unmodifiable(_calorieEntries);

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

  void addCalorieEntry(CalorieEntryModel entry) {
    _calorieEntries.add(entry.copyWith(id: _generateId()));
  }

  void deleteCalorieEntry(String id) {
    _calorieEntries.removeWhere((e) => e.id == id);
  }

  // ==================== SLEEP RECORDS ====================
  List<SleepRecordModel> get sleepRecords => List.unmodifiable(_sleepRecords);

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

  // ==================== STEP RECORDS ====================
  List<StepRecordModel> get stepRecords => List.unmodifiable(_stepRecords);

  StepRecordModel? get todaySteps {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return _stepRecords.cast<StepRecordModel?>().firstWhere(
      (r) => r != null && DateTime(r.date.year, r.date.month, r.date.day) == todayDate,
      orElse: () => null,
    );
  }

  void updateTodaySteps(int steps) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final index = _stepRecords.indexWhere((r) =>
      DateTime(r.date.year, r.date.month, r.date.day) == todayDate
    );

    if (index != -1) {
      _stepRecords[index] = _stepRecords[index].copyWith(steps: steps);
    } else {
      _stepRecords.add(StepRecordModel(
        id: _generateId(),
        date: todayDate,
        steps: steps,
      ));
    }
  }

  // ==================== WORKOUT SESSIONS ====================
  List<WorkoutSessionModel> get workoutSessions => List.unmodifiable(_workoutSessions);

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

  void addWorkoutSession(WorkoutSessionModel session) {
    _workoutSessions.add(session.copyWith(id: _generateId()));
  }

  void deleteWorkoutSession(String id) {
    _workoutSessions.removeWhere((w) => w.id == id);
  }

  // ==================== HEART RATE RECORDS ====================
  List<HeartRateRecordModel> get heartRateRecords => List.unmodifiable(_heartRateRecords);

  HeartRateRecordModel? get latestHeartRate {
    if (_heartRateRecords.isEmpty) return null;
    return _heartRateRecords.reduce((a, b) => a.recordedAt.isAfter(b.recordedAt) ? a : b);
  }

  int get restingHeartRate {
    final restingRecords = _heartRateRecords.where((r) => r.zone == HeartRateZone.resting);
    if (restingRecords.isEmpty) return 65;
    return (restingRecords.map((r) => r.bpm).reduce((a, b) => a + b) / restingRecords.length).round();
  }

  void addHeartRateRecord(int bpm) {
    _heartRateRecords.add(HeartRateRecordModel(
      id: _generateId(),
      bpm: bpm,
      recordedAt: DateTime.now(),
    ));
  }

  // ==================== MOOD ENTRIES ====================
  List<MoodEntryModel> get moodEntries => List.unmodifiable(_moodEntries);

  MoodEntryModel? get todayMood {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final todayEntries = _moodEntries.where((m) => m.recordedAt.isAfter(startOfDay)).toList();
    if (todayEntries.isEmpty) return null;
    return todayEntries.reduce((a, b) => a.recordedAt.isAfter(b.recordedAt) ? a : b);
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
      } else {
        break;
      }
    }
    return streak;
  }

  void addMoodEntry(MoodEntryModel entry) {
    _moodEntries.add(entry.copyWith(id: _generateId()));
  }

  // ==================== SCREEN TIME ====================
  List<ScreenTimeModel> get screenTimeRecords => List.unmodifiable(_screenTimeRecords);

  ScreenTimeModel? get todayScreenTime {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return _screenTimeRecords.cast<ScreenTimeModel?>().firstWhere(
      (r) => r != null && DateTime(r.date.year, r.date.month, r.date.day) == todayDate,
      orElse: () => null,
    );
  }

  ScreenTimeModel? get yesterdayScreenTime {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
    return _screenTimeRecords.cast<ScreenTimeModel?>().firstWhere(
      (r) => r != null && DateTime(r.date.year, r.date.month, r.date.day) == yesterdayDate,
      orElse: () => null,
    );
  }

  // ==================== MEDITATION SESSIONS ====================
  List<MeditationSessionModel> get meditationSessions => List.unmodifiable(_meditationSessions);

  int get todayMeditationMinutes {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    return _meditationSessions
        .where((m) => m.startTime.isAfter(startOfDay) && m.isCompleted)
        .fold(0, (sum, m) => sum + m.durationMinutes);
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

  void addMeditationSession(MeditationSessionModel session) {
    _meditationSessions.add(session.copyWith(id: _generateId()));
  }

  void completeMeditationSession(String id) {
    final index = _meditationSessions.indexWhere((m) => m.id == id);
    if (index != -1) {
      _meditationSessions[index] = _meditationSessions[index].copyWith(isCompleted: true);
    }
  }
}
