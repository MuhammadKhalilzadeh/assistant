import 'package:assistant/data/mock/models/habit_model.dart';
import 'package:assistant/data/mock/models/todo_model.dart';
import 'package:assistant/data/models/calendar_event.dart';
import 'package:assistant/data/models/calorie_entry_model.dart';
import 'package:assistant/data/models/focus_session_model.dart';
import 'package:assistant/data/models/heart_rate_model.dart';
import 'package:assistant/data/models/meditation_session_model.dart';
import 'package:assistant/data/models/mood_entry_model.dart';
import 'package:assistant/data/models/screen_time_model.dart';
import 'package:assistant/data/models/sleep_record_model.dart';
import 'package:assistant/data/models/water_log_model.dart';
import 'package:assistant/data/models/workout_session_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:assistant/presentation/pages/jarvis/widgets/chat_bubble.dart';
import 'package:assistant/presentation/pages/jarvis/widgets/chat_input.dart';
import 'package:assistant/presentation/pages/jarvis/widgets/daily_briefing.dart';
import 'package:assistant/presentation/pages/jarvis/widgets/typing_indicator.dart';
import 'package:assistant/presentation/pages/settings/settings_page.dart';
import 'package:assistant/presentation/utils/navigation_utils.dart';
import 'package:assistant/providers/calendar_provider.dart';
import 'package:assistant/providers/calories_provider.dart';
import 'package:assistant/providers/focus_timer_provider.dart';
import 'package:assistant/providers/habit_provider.dart';
import 'package:assistant/providers/heart_rate_provider.dart';
import 'package:assistant/providers/inbox_provider.dart';
import 'package:assistant/providers/jarvis_provider.dart';
import 'package:assistant/providers/meditation_provider.dart';
import 'package:assistant/providers/mood_provider.dart';
import 'package:assistant/providers/screen_time_provider.dart';
import 'package:assistant/providers/sleep_provider.dart';
import 'package:assistant/providers/steps_provider.dart';
import 'package:assistant/providers/todo_provider.dart';
import 'package:assistant/providers/insights_provider.dart';
import 'package:assistant/providers/water_provider.dart';
import 'package:assistant/providers/workout_provider.dart';
import 'package:assistant/presentation/pages/jarvis/widgets/nudge_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JarvisChatPage extends ConsumerStatefulWidget {
  const JarvisChatPage({super.key});

  @override
  ConsumerState<JarvisChatPage> createState() => _JarvisChatPageState();
}

class _JarvisChatPageState extends ConsumerState<JarvisChatPage>
    with WidgetsBindingObserver {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh briefing when app returns to foreground
    if (state == AppLifecycleState.resumed) {
      ref.read(jarvisProvider.notifier).refreshBriefing();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _sendMessage(String content) {
    ref.read(jarvisProvider.notifier).sendMessage(content);
    _scrollToBottom();
  }

  /// Execute parsed actions from the LLM response
  Future<void> _executeActions(List<JarvisAction> actions) async {
    for (final action in actions) {
      try {
        switch (action.type) {
          case 'water':
            await _executeWaterAction(action.data);
          case 'todo':
            await _executeTodoAction(action.data);
          case 'mood':
            await _executeMoodAction(action.data);
          case 'calories':
            await _executeCaloriesAction(action.data);
          case 'sleep':
            await _executeSleepAction(action.data);
          case 'steps':
            await _executeStepsAction(action.data);
          case 'workout':
            await _executeWorkoutAction(action.data);
          case 'heart_rate':
            await _executeHeartRateAction(action.data);
          case 'meditation':
            await _executeMeditationAction(action.data);
          case 'habit':
            await _executeHabitAction(action.data);
          case 'screen_time':
            await _executeScreenTimeAction(action.data);
          case 'focus':
            await _executeFocusAction(action.data);
          case 'calendar':
            await _executeCalendarAction(action.data);
          case 'inbox':
            await _executeInboxAction(action.data);
          default:
            debugPrint('[Jarvis] Unknown action type: ${action.type}');
        }
      } catch (e) {
        debugPrint('[Jarvis] Failed to execute action ${action.type}: $e');
      }
    }
    ref.read(jarvisProvider.notifier).clearPendingActions();
  }

  Future<void> _executeWaterAction(Map<String, dynamic> data) async {
    final amountMl = data['amount_ml'] as int? ?? 250;
    final log = WaterLogModel(
      id: '',
      amountMl: amountMl,
      loggedAt: DateTime.now(),
    );
    await ref.read(waterLogsProvider.notifier).addLog(log);
  }

  Future<void> _executeTodoAction(Map<String, dynamic> data) async {
    final title = data['title'] as String? ?? 'New task';
    final priorityStr = data['priority'] as String? ?? 'medium';
    final priority = switch (priorityStr) {
      'high' => 1,
      'low' => 3,
      _ => 2,
    };
    final todo = TodoModel(
      id: '',
      title: title,
      isCompleted: false,
      createdAt: DateTime.now(),
      priority: priority,
    );
    await ref.read(todoListProvider.notifier).addTodo(todo);
  }

  Future<void> _executeMoodAction(Map<String, dynamic> data) async {
    final score = data['score'] as int? ?? 3;
    final note = data['note'] as String?;
    final mood = switch (score) {
      5 => MoodLevel.great,
      4 => MoodLevel.good,
      2 => MoodLevel.bad,
      1 => MoodLevel.awful,
      _ => MoodLevel.okay,
    };
    final entry = MoodEntryModel(
      id: '',
      mood: mood,
      recordedAt: DateTime.now(),
      notes: note,
    );
    await ref.read(moodEntriesProvider.notifier).addEntry(entry);
  }

  Future<void> _executeCaloriesAction(Map<String, dynamic> data) async {
    final name = data['name'] as String? ?? 'Food';
    final calories = data['calories'] as int? ?? 0;
    final mealTypeStr = data['meal_type'] as String? ?? 'snack';
    final mealType = switch (mealTypeStr) {
      'breakfast' => MealType.breakfast,
      'lunch' => MealType.lunch,
      'dinner' => MealType.dinner,
      _ => MealType.snack,
    };
    final entry = CalorieEntryModel(
      id: '',
      foodName: name,
      calories: calories,
      mealType: mealType,
      loggedAt: DateTime.now(),
    );
    await ref.read(calorieEntriesProvider.notifier).addEntry(entry);
  }

  Future<void> _executeSleepAction(Map<String, dynamic> data) async {
    final bedTimeStr = data['bed_time'] as String? ?? '23:00';
    final wakeTimeStr = data['wake_time'] as String? ?? '07:00';
    final qualityStr = data['quality'] as String? ?? 'good';

    final now = DateTime.now();
    final bedParts = bedTimeStr.split(':');
    final wakeParts = wakeTimeStr.split(':');
    final bedHour = int.tryParse(bedParts[0]) ?? 23;
    final bedMinute = bedParts.length > 1 ? int.tryParse(bedParts[1]) ?? 0 : 0;
    final wakeHour = int.tryParse(wakeParts[0]) ?? 7;
    final wakeMinute = wakeParts.length > 1 ? int.tryParse(wakeParts[1]) ?? 0 : 0;

    // Bed time is yesterday if hour >= 12, wake time is today
    var bedTime = DateTime(now.year, now.month, now.day, bedHour, bedMinute);
    if (bedHour >= 12) bedTime = bedTime.subtract(const Duration(days: 1));
    final wakeTime = DateTime(now.year, now.month, now.day, wakeHour, wakeMinute);

    final quality = switch (qualityStr) {
      'poor' => SleepQuality.poor,
      'fair' => SleepQuality.fair,
      'excellent' => SleepQuality.excellent,
      _ => SleepQuality.good,
    };

    final record = SleepRecordModel(
      id: '',
      bedTime: bedTime,
      wakeTime: wakeTime,
      quality: quality,
    );
    await ref.read(sleepRecordsProvider.notifier).addRecord(record);
  }

  Future<void> _executeStepsAction(Map<String, dynamic> data) async {
    final steps = data['steps'] as int? ?? 0;
    await ref.read(stepRecordsProvider.notifier).addSteps(steps);
  }

  Future<void> _executeWorkoutAction(Map<String, dynamic> data) async {
    final typeStr = data['type'] as String? ?? 'other';
    final durationMinutes = data['duration_minutes'] as int? ?? 30;
    final calories = data['calories'] as int? ?? 0;

    final type = switch (typeStr) {
      'running' => WorkoutType.running,
      'cycling' => WorkoutType.cycling,
      'strength' => WorkoutType.strength,
      'yoga' => WorkoutType.yoga,
      'swimming' => WorkoutType.swimming,
      'walking' => WorkoutType.walking,
      'hiit' => WorkoutType.hiit,
      _ => WorkoutType.other,
    };

    final session = WorkoutSessionModel(
      id: '',
      type: type,
      startTime: DateTime.now().subtract(Duration(minutes: durationMinutes)),
      endTime: DateTime.now(),
      durationMinutes: durationMinutes,
      caloriesBurned: calories,
    );
    await ref.read(workoutSessionsProvider.notifier).addSession(session);
  }

  Future<void> _executeHeartRateAction(Map<String, dynamic> data) async {
    final bpm = data['bpm'] as int? ?? 72;
    final record = HeartRateRecordModel(
      id: '',
      bpm: bpm,
      recordedAt: DateTime.now(),
    );
    await ref.read(heartRateRecordsProvider.notifier).addRecord(record);
  }

  Future<void> _executeMeditationAction(Map<String, dynamic> data) async {
    final typeStr = data['type'] as String? ?? 'breathing';
    final durationMinutes = data['duration_minutes'] as int? ?? 10;

    final type = switch (typeStr) {
      'guided' => MeditationType.guided,
      'unguided' => MeditationType.unguided,
      'sleep' => MeditationType.sleep,
      'focus' => MeditationType.focus,
      _ => MeditationType.breathing,
    };

    final session = MeditationSessionModel(
      id: '',
      type: type,
      startTime: DateTime.now(),
      durationMinutes: durationMinutes,
      isCompleted: true,
    );
    await ref.read(meditationSessionsProvider.notifier).addSession(session);
  }

  Future<void> _executeHabitAction(Map<String, dynamic> data) async {
    final name = data['name'] as String? ?? 'Habit';
    final action = data['action'] as String? ?? 'complete';

    if (action == 'add') {
      final habit = HabitModel(
        id: '',
        name: name,
        category: HabitCategory.other,
      );
      await ref.read(habitListProvider.notifier).addHabit(habit);
    } else {
      // Toggle complete — find by name
      final habits = ref.read(habitListProvider).valueOrNull ?? [];
      final match = habits.where(
        (h) => h.name.toLowerCase() == name.toLowerCase(),
      );
      if (match.isNotEmpty) {
        await ref.read(habitListProvider.notifier).toggleComplete(match.first.id);
      }
    }
  }

  Future<void> _executeScreenTimeAction(Map<String, dynamic> data) async {
    final totalMinutes = data['total_minutes'] as int? ?? 0;
    final pickups = data['pickups'] as int? ?? 0;

    final record = ScreenTimeRecord(
      id: '',
      date: DateTime.now(),
      totalMinutes: totalMinutes,
      pickups: pickups,
    );
    await ref.read(screenTimeRecordProvider.notifier).syncRecord(record);
  }

  Future<void> _executeFocusAction(Map<String, dynamic> data) async {
    final durationMinutes = data['duration_minutes'] as int? ?? 25;
    final task = data['task'] as String?;

    final session = FocusSessionModel(
      id: '',
      type: FocusSessionType.focus,
      startTime: DateTime.now(),
      durationMinutes: durationMinutes,
      task: task,
    );
    await ref.read(focusTimerSessionsProvider.notifier).addSession(session);
  }

  Future<void> _executeCalendarAction(Map<String, dynamic> data) async {
    final title = data['title'] as String? ?? 'Event';
    final startStr = data['start'] as String?;
    final endStr = data['end'] as String?;

    final start = startStr != null
        ? DateTime.tryParse(startStr) ?? DateTime.now()
        : DateTime.now();
    final end = endStr != null
        ? DateTime.tryParse(endStr) ?? start.add(const Duration(hours: 1))
        : start.add(const Duration(hours: 1));

    final event = CalendarEvent(
      title: title,
      startTime: start,
      endTime: end,
    );
    await ref.read(calendarEventsProvider.notifier).addEvent(event);
  }

  Future<void> _executeInboxAction(Map<String, dynamic> data) async {
    final action = data['action'] as String? ?? 'mark_read';
    final id = data['id'] as String?;

    if (action == 'mark_read' && id != null) {
      await ref.read(inboxMessagesProvider.notifier).markAsRead(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jarvisProvider);
    final hasNoApiKey = state.activeProvider == null;
    final isOnlyWelcome = state.messages.length == 1 && !state.isLoading;

    // Listen for new messages and execute pending actions
    ref.listen<JarvisState>(jarvisProvider, (prev, next) {
      if (prev != null && prev.messages.length != next.messages.length) {
        _scrollToBottom();
      }
      if (next.pendingActions.isNotEmpty) {
        _executeActions(next.pendingActions);
      }
    });

    final hasBriefing =
        state.briefingData != null && state.briefingData!.isNotEmpty;

    return Container(
      color: AppTheme.backgroundColor,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            if (hasNoApiKey) _buildNoApiKeyBanner(context),
            if (hasBriefing && isOnlyWelcome)
              DailyBriefing(
                briefingData: state.briefingData!,
                onRefresh: () =>
                    ref.read(jarvisProvider.notifier).refreshBriefing(),
              ),
            if (isOnlyWelcome) _buildNudges(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                reverse: true,
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                itemCount: state.messages.length +
                    (state.isLoading ? 1 : 0) +
                    (isOnlyWelcome ? 1 : 0),
                itemBuilder: (context, index) {
                  if (state.isLoading && index == 0) {
                    return const TypingIndicator();
                  }

                  final adjustedIndex = index - (state.isLoading ? 1 : 0);

                  if (isOnlyWelcome && adjustedIndex == 0) {
                    return _buildSuggestionChips();
                  }

                  final messageIndex = state.messages.length -
                      1 -
                      (adjustedIndex - (isOnlyWelcome ? 1 : 0));

                  if (messageIndex < 0 ||
                      messageIndex >= state.messages.length) {
                    return const SizedBox.shrink();
                  }

                  return ChatBubble(message: state.messages[messageIndex]);
                },
              ),
            ),
            ChatInput(
              onSend: _sendMessage,
              enabled: !state.isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        border: Border(
          bottom: BorderSide(color: AppTheme.dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 18,
              color: AppTheme.textOnPrimary,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Jarvis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const Spacer(),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: AppTheme.textSecondary,
            ),
            color: AppTheme.cardColor,
            onSelected: (value) {
              if (value == 'clear') {
                ref.read(jarvisProvider.notifier).clearConversation();
              } else if (value == 'settings') {
                NavigationUtils.navigateWithFade(
                  context,
                  const SettingsPage(),
                );
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline,
                        size: 18, color: AppTheme.textSecondary),
                    SizedBox(width: 8),
                    Text('Clear conversation',
                        style: TextStyle(color: AppTheme.textPrimary)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.key_outlined,
                        size: 18, color: AppTheme.textSecondary),
                    SizedBox(width: 8),
                    Text('API Key Settings',
                        style: TextStyle(color: AppTheme.textPrimary)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoApiKeyBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.warningColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.vpn_key_outlined,
              size: 18, color: AppTheme.warningColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Add an API key in Settings to chat with Jarvis',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.warningColor.withValues(alpha: 0.9),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              NavigationUtils.navigateWithFade(
                context,
                const SettingsPage(),
              );
            },
            child: const Text(
              'Settings',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNudges() {
    final insightsState = ref.watch(insightsProvider);
    final nudges = insightsState.activeNudges;
    if (nudges.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: nudges.map((nudge) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: NudgeCard(
              nudge: nudge,
              onDismiss: () =>
                  ref.read(insightsProvider.notifier).dismissNudge(nudge.id),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSuggestionChips() {
    const suggestions = [
      'Log my water intake',
      "What's on my schedule?",
      'Track my mood',
      'Set a focus timer',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: suggestions.map((text) {
          return GestureDetector(
            onTap: () => _sendMessage(text),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
