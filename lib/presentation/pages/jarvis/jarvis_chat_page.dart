import 'package:assistant/data/mock/models/todo_model.dart';
import 'package:assistant/data/models/calorie_entry_model.dart';
import 'package:assistant/data/models/mood_entry_model.dart';
import 'package:assistant/data/models/water_log_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:assistant/presentation/pages/jarvis/widgets/chat_bubble.dart';
import 'package:assistant/presentation/pages/jarvis/widgets/chat_input.dart';
import 'package:assistant/presentation/pages/jarvis/widgets/typing_indicator.dart';
import 'package:assistant/presentation/pages/settings/settings_page.dart';
import 'package:assistant/presentation/utils/navigation_utils.dart';
import 'package:assistant/providers/calories_provider.dart';
import 'package:assistant/providers/jarvis_provider.dart';
import 'package:assistant/providers/mood_provider.dart';
import 'package:assistant/providers/todo_provider.dart';
import 'package:assistant/providers/water_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JarvisChatPage extends ConsumerStatefulWidget {
  const JarvisChatPage({super.key});

  @override
  ConsumerState<JarvisChatPage> createState() => _JarvisChatPageState();
}

class _JarvisChatPageState extends ConsumerState<JarvisChatPage> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

    return Container(
      color: AppTheme.backgroundColor,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            if (hasNoApiKey) _buildNoApiKeyBanner(context),
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
