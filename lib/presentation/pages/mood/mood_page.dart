import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:assistant/data/mock/repositories/mock_repository.dart';
import 'package:assistant/data/mock/models/mood_entry_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'widgets/mood_app_bar.dart';
import 'widgets/mood_progress_card.dart';
import 'widgets/mood_selector.dart';
import 'widgets/mood_history_list.dart';
import 'widgets/mood_stats_card.dart';
import 'widgets/mood_tips_card.dart';
import 'widgets/goal_celebration.dart';

/// Main Mood page with mood tracking and mental wellness features
class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> with TickerProviderStateMixin {
  final MockRepository _repository = MockRepository();

  late AnimationController _listAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _listAnimation;

  bool _showCelebration = false;
  int _previousStreakMilestone = 0;
  MoodLevel? _selectedMood;

  @override
  void initState() {
    super.initState();

    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _listAnimation = CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeOutCubic,
    );

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // Check initial goal state (streak-based)
    final streak = _repository.moodStreak;
    const streakGoal = 7; // Celebrate 7-day streaks
    _previousStreakMilestone = (streak ~/ streakGoal) * streakGoal;

    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  void _addMoodEntry(MoodLevel mood, {List<String>? activities, String? notes}) {
    const streakGoal = 7;

    _repository.addMoodEntry(MoodEntryModel(
      id: '',
      mood: mood,
      recordedAt: DateTime.now(),
      activities: activities ?? [],
      notes: notes,
    ));

    final newStreak = _repository.moodStreak;
    final newMilestone = (newStreak ~/ streakGoal) * streakGoal;

    // Check if a new streak milestone was just achieved
    if (newMilestone > _previousStreakMilestone && newMilestone > 0) {
      setState(() {
        _showCelebration = true;
        _previousStreakMilestone = newMilestone;
      });
    } else {
      setState(() {});
    }

    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('😊', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            const Text('Mood logged successfully'),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _deleteMoodEntry(String id) {
    _repository.deleteMoodEntry(id);
    setState(() {});
  }

  void _showLogMoodSheet() {
    MoodLevel? selectedMood = _selectedMood;
    final List<String> selectedActivities = [];
    final TextEditingController notesController = TextEditingController();

    final activities = ['Exercise', 'Work', 'Family', 'Friends', 'Hobbies', 'Rest', 'Nature', 'Reading'];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Log Your Mood',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'How are you feeling right now?',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                // Mood selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: MoodLevel.values.map((mood) {
                    final isSelected = mood == selectedMood;
                    return GestureDetector(
                      onTap: () {
                        setSheetState(() => selectedMood = mood);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _getMoodColor(mood).withValues(alpha: 0.2)
                              : AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? _getMoodColor(mood)
                                : AppTheme.textTertiary.withValues(alpha: 0.3),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _getMoodEmoji(mood),
                              style: TextStyle(fontSize: isSelected ? 32 : 28),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getMoodLabel(mood),
                              style: TextStyle(
                                color: isSelected
                                    ? _getMoodColor(mood)
                                    : AppTheme.textSecondary,
                                fontSize: 10,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                // Activities
                Text(
                  'Activities (optional)',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: activities.map((activity) {
                    final isSelected = selectedActivities.contains(activity);
                    return GestureDetector(
                      onTap: () {
                        setSheetState(() {
                          if (isSelected) {
                            selectedActivities.remove(activity);
                          } else {
                            selectedActivities.add(activity);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryColor.withValues(alpha: 0.1)
                              : AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.textTertiary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          activity,
                          style: TextStyle(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                // Notes
                Text(
                  'Notes (optional)',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'How was your day?',
                    hintStyle: TextStyle(color: AppTheme.textTertiary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.textTertiary.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.textTertiary.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedMood != null
                        ? () {
                            _addMoodEntry(
                              selectedMood!,
                              activities: selectedActivities,
                              notes: notesController.text.isNotEmpty
                                  ? notesController.text
                                  : null,
                            );
                            Navigator.pop(context);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppTheme.primaryColor.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save Mood',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGoalSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _GoalSettingsSheet(
        currentGoal: _repository.moodGoal,
        onGoalChanged: (dailyEntriesGoal, targetMood) {
          _repository.updateMoodGoal(
            dailyEntriesGoal: dailyEntriesGoal,
            targetMood: targetMood,
          );
          setState(() {});
          Navigator.pop(context);
        },
      ),
    );
  }

  void _dismissCelebration() {
    setState(() {
      _showCelebration = false;
    });
  }

  String _getMoodEmoji(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.great:
        return '😄';
      case MoodLevel.good:
        return '🙂';
      case MoodLevel.okay:
        return '😐';
      case MoodLevel.bad:
        return '😔';
      case MoodLevel.awful:
        return '😢';
    }
  }

  String _getMoodLabel(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.great:
        return 'Great';
      case MoodLevel.good:
        return 'Good';
      case MoodLevel.okay:
        return 'Okay';
      case MoodLevel.bad:
        return 'Bad';
      case MoodLevel.awful:
        return 'Awful';
    }
  }

  Color _getMoodColor(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.great:
        return AppTheme.successColor;
      case MoodLevel.good:
        return AppTheme.infoColor;
      case MoodLevel.okay:
        return AppTheme.warningColor;
      case MoodLevel.bad:
        return const Color(0xFFFF9800);
      case MoodLevel.awful:
        return AppTheme.errorColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.04).clamp(16.0, 24.0);
    final todayMood = _repository.todayMood;
    final stats = _repository.getWeeklyMoodStats();
    final streak = _repository.moodStreak;
    final progress = todayMood != null ? 1.0 : 0.0;
    final moodEntries = _repository.moodEntries.toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                MoodAppBar(
                  padding: padding,
                  progress: progress.clamp(0.0, 1.0),
                  onSettingsTap: _showGoalSettings,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: Column(
                        children: [
                          AnimatedBuilder(
                            animation: _progressAnimationController,
                            builder: (context, child) {
                              return MoodProgressCard(
                                todayMood: todayMood,
                                streakDays: streak,
                                weeklyEntries: stats.totalEntries,
                                progress: progress,
                                animationPhase: _progressAnimationController.value,
                                padding: padding,
                                onLogMood: _showLogMoodSheet,
                              );
                            },
                          ),
                          SizedBox(height: padding),

                          MoodSelector(
                            selectedMood: _selectedMood,
                            onMoodSelected: (mood) {
                              setState(() {
                                _selectedMood = mood;
                              });
                              _showLogMoodSheet();
                            },
                            padding: padding,
                            animation: _listAnimation,
                          ),
                          SizedBox(height: padding),

                          MoodTipsCard(
                            padding: padding,
                            animation: _listAnimation,
                          ),
                          SizedBox(height: padding),

                          MoodStatsCard(
                            stats: stats,
                            padding: padding,
                            animation: _listAnimation,
                          ),
                          SizedBox(height: padding),

                          MoodHistoryList(
                            moodEntries: moodEntries,
                            onDelete: _deleteMoodEntry,
                            padding: padding,
                            animation: _listAnimation,
                          ),
                          SizedBox(height: padding * 2),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (_showCelebration)
              GoalCelebration(
                onDismiss: _dismissCelebration,
              ),
          ],
        ),
      ),
    );
  }
}

class _GoalSettingsSheet extends StatefulWidget {
  final MoodGoal currentGoal;
  final Function(int, MoodLevel) onGoalChanged;

  const _GoalSettingsSheet({
    required this.currentGoal,
    required this.onGoalChanged,
  });

  @override
  State<_GoalSettingsSheet> createState() => _GoalSettingsSheetState();
}

class _GoalSettingsSheetState extends State<_GoalSettingsSheet> {
  late int _dailyEntries;
  late MoodLevel _targetMood;

  @override
  void initState() {
    super.initState();
    _dailyEntries = widget.currentGoal.dailyEntriesGoal;
    _targetMood = widget.currentGoal.targetMood;
  }

  String _getMoodEmoji(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.great:
        return '😄';
      case MoodLevel.good:
        return '🙂';
      case MoodLevel.okay:
        return '😐';
      case MoodLevel.bad:
        return '😔';
      case MoodLevel.awful:
        return '😢';
    }
  }

  String _getMoodLabel(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.great:
        return 'Great';
      case MoodLevel.good:
        return 'Good';
      case MoodLevel.okay:
        return 'Okay';
      case MoodLevel.bad:
        return 'Bad';
      case MoodLevel.awful:
        return 'Awful';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood Goals',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set your daily mood tracking goals',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Daily Entries',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  if (_dailyEntries > 1) {
                    setState(() => _dailyEntries--);
                  }
                },
                icon: Icon(Icons.remove_circle_outline, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 16),
              Text(
                '$_dailyEntries',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {
                  if (_dailyEntries < 5) {
                    setState(() => _dailyEntries++);
                  }
                },
                icon: Icon(Icons.add_circle_outline, color: AppTheme.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Target Mood',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: MoodLevel.values.take(3).map((mood) {
              final isSelected = mood == _targetMood;
              return GestureDetector(
                onTap: () {
                  setState(() => _targetMood = mood);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor.withValues(alpha: 0.1)
                        : AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.textTertiary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _getMoodEmoji(mood),
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getMoodLabel(mood),
                        style: TextStyle(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onGoalChanged(_dailyEntries, _targetMood),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Goals',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
