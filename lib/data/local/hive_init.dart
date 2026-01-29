import 'package:hive_flutter/hive_flutter.dart';

// Import all models and their generated adapters
import 'package:assistant/data/mock/models/water_log_model.dart';
import 'package:assistant/data/mock/models/mood_entry_model.dart';
import 'package:assistant/data/mock/models/sleep_record_model.dart';
import 'package:assistant/data/mock/models/heart_rate_record_model.dart';
import 'package:assistant/data/mock/models/todo_model.dart';
import 'package:assistant/data/mock/models/focus_session_model.dart';
import 'package:assistant/data/mock/models/meditation_session_model.dart';
import 'package:assistant/data/mock/models/step_record_model.dart';
import 'package:assistant/data/mock/models/calorie_entry_model.dart';
import 'package:assistant/data/mock/models/habit_model.dart';
import 'package:assistant/data/mock/models/calendar_event_model.dart';
import 'package:assistant/data/mock/models/workout_session_model.dart';
import 'package:assistant/data/mock/models/inbox_message_model.dart';

class HiveInit {
  static Future<void> init() async {
    // Initialize Hive for Flutter
    await Hive.initFlutter();

    // Register all type adapters
    _registerAdapters();

    // Open all boxes
    await _openBoxes();
  }

  static void _registerAdapters() {
    // Tier 1: Simplest models
    Hive.registerAdapter(WaterLogModelAdapter());
    Hive.registerAdapter(MoodLevelAdapter());
    Hive.registerAdapter(MoodEntryModelAdapter());
    Hive.registerAdapter(SleepQualityAdapter());
    Hive.registerAdapter(SleepRecordModelAdapter());
    Hive.registerAdapter(HeartRateZoneAdapter());
    Hive.registerAdapter(HeartRateRecordModelAdapter());

    // Tier 2: Moderate complexity
    Hive.registerAdapter(TodoModelAdapter());
    Hive.registerAdapter(FocusSessionModelAdapter());
    Hive.registerAdapter(MeditationTypeAdapter());
    Hive.registerAdapter(MeditationSessionModelAdapter());
    Hive.registerAdapter(StepRecordModelAdapter());

    // Tier 3: Medium complexity
    Hive.registerAdapter(MealTypeAdapter());
    Hive.registerAdapter(CalorieEntryModelAdapter());
    Hive.registerAdapter(HabitModelAdapter());
    Hive.registerAdapter(CalendarEventModelAdapter());

    // Tier 4: Complex models
    Hive.registerAdapter(WorkoutTypeAdapter());
    Hive.registerAdapter(ExerciseModelAdapter());
    Hive.registerAdapter(WorkoutSessionModelAdapter());
    Hive.registerAdapter(InboxMessageModelAdapter());
  }

  static Future<void> _openBoxes() async {
    // Open boxes for all model types
    await Future.wait([
      Hive.openBox<WaterLogModel>('waterLogs'),
      Hive.openBox<MoodEntryModel>('moodEntries'),
      Hive.openBox<SleepRecordModel>('sleepRecords'),
      Hive.openBox<HeartRateRecordModel>('heartRateRecords'),
      Hive.openBox<TodoModel>('todos'),
      Hive.openBox<FocusSessionModel>('focusSessions'),
      Hive.openBox<MeditationSessionModel>('meditationSessions'),
      Hive.openBox<StepRecordModel>('stepRecords'),
      Hive.openBox<CalorieEntryModel>('calorieEntries'),
      Hive.openBox<HabitModel>('habits'),
      Hive.openBox<CalendarEventModel>('calendarEvents'),
      Hive.openBox<WorkoutSessionModel>('workoutSessions'),
      Hive.openBox<InboxMessageModel>('inboxMessages'),
    ]);
  }

  // Box accessors for easy access throughout the app
  static Box<WaterLogModel> get waterLogsBox => Hive.box<WaterLogModel>('waterLogs');
  static Box<MoodEntryModel> get moodEntriesBox => Hive.box<MoodEntryModel>('moodEntries');
  static Box<SleepRecordModel> get sleepRecordsBox => Hive.box<SleepRecordModel>('sleepRecords');
  static Box<HeartRateRecordModel> get heartRateRecordsBox => Hive.box<HeartRateRecordModel>('heartRateRecords');
  static Box<TodoModel> get todosBox => Hive.box<TodoModel>('todos');
  static Box<FocusSessionModel> get focusSessionsBox => Hive.box<FocusSessionModel>('focusSessions');
  static Box<MeditationSessionModel> get meditationSessionsBox => Hive.box<MeditationSessionModel>('meditationSessions');
  static Box<StepRecordModel> get stepRecordsBox => Hive.box<StepRecordModel>('stepRecords');
  static Box<CalorieEntryModel> get calorieEntriesBox => Hive.box<CalorieEntryModel>('calorieEntries');
  static Box<HabitModel> get habitsBox => Hive.box<HabitModel>('habits');
  static Box<CalendarEventModel> get calendarEventsBox => Hive.box<CalendarEventModel>('calendarEvents');
  static Box<WorkoutSessionModel> get workoutSessionsBox => Hive.box<WorkoutSessionModel>('workoutSessions');
  static Box<InboxMessageModel> get inboxMessagesBox => Hive.box<InboxMessageModel>('inboxMessages');
}
