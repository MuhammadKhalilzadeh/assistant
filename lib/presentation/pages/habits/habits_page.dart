import 'dart:async';

import 'package:assistant/data/mock/models/habit_model.dart';
import 'package:assistant/data/errors/app_errors.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:assistant/presentation/pages/habits/widgets/add_habit_sheet.dart';
import 'package:assistant/presentation/pages/habits/widgets/habit_app_bar.dart';
import 'package:assistant/presentation/pages/habits/widgets/habit_category_chip.dart';
import 'package:assistant/presentation/pages/habits/widgets/habit_detail_sheet.dart';
import 'package:assistant/presentation/pages/habits/widgets/habit_empty_state.dart';
import 'package:assistant/presentation/pages/habits/widgets/habit_filters.dart';
import 'package:assistant/presentation/pages/habits/widgets/habit_item.dart';
import 'package:assistant/presentation/pages/habits/widgets/habit_summary_card.dart';
import 'package:assistant/providers/habit_provider.dart';
import 'package:assistant/providers/connectivity_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HabitsPage extends ConsumerStatefulWidget {
  const HabitsPage({super.key});

  @override
  ConsumerState<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends ConsumerState<HabitsPage>
    with SingleTickerProviderStateMixin {
  // State variables
  bool _isSearching = false;

  // Animation controller for list animations
  late AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    super.dispose();
  }

  String _getUserFriendlyErrorMessage(Object error) {
    if (error is AppError) {
      return error.userMessage;
    }
    return 'Something went wrong. Please try again.';
  }

  void _onSearchToggle() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        ref.read(habitSearchQueryProvider.notifier).state = '';
      }
    });
  }

  void _onSearchChanged(String query) {
    ref.read(habitSearchQueryProvider.notifier).state = query;
  }

  void _onFilterChanged(HabitFilter filter) {
    ref.read(habitFilterProvider.notifier).state = filter;
  }

  void _onCategoryChanged(HabitCategory? category) {
    ref.read(habitCategoryFilterProvider.notifier).state = category;
  }

  void _showAddHabitSheet({HabitModel? habit}) {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot add or edit habits while offline'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    AddHabitSheet.show(
      context: context,
      editingHabit: habit,
      onSave: (newHabit) async {
        try {
          if (habit != null) {
            await ref.read(habitListProvider.notifier).updateHabit(newHabit);
          } else {
            await ref.read(habitListProvider.notifier).addHabit(newHabit);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_getUserFriendlyErrorMessage(e))),
            );
          }
        }
      },
      onDelete: habit != null
          ? () async {
              try {
                await ref.read(habitListProvider.notifier).deleteHabit(habit.id);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_getUserFriendlyErrorMessage(e))),
                  );
                }
              }
            }
          : null,
    );
  }

  void _showHabitDetail(HabitModel habit) {
    final statsAsync = ref.read(habitStatsProvider);
    final weeklyRate = statsAsync.valueOrNull?.weeklyCompletionRate ?? 0.0;

    HabitDetailSheet.show(
      context: context,
      habit: habit,
      weeklyRate: weeklyRate,
      onEdit: () {
        _showAddHabitSheet(habit: habit);
      },
      onDelete: () async {
        await _deleteHabit(habit);
      },
      onToggleToday: () async {
        await _toggleHabitComplete(habit);
      },
    );
  }

  Future<void> _toggleHabitComplete(HabitModel habit) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot update habits while offline'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await ref.read(habitListProvider.notifier).toggleComplete(habit.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_getUserFriendlyErrorMessage(e))),
        );
      }
    }
  }

  Future<void> _deleteHabit(HabitModel habit) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete habits while offline'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await ref.read(habitListProvider.notifier).deleteHabit(habit.id);
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Habit deleted'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                try {
                  await ref.read(habitListProvider.notifier).restoreHabit(habit);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_getUserFriendlyErrorMessage(e))),
                    );
                  }
                }
              },
            ),
          ),
        );
        // Manually dismiss the snackbar after 3 seconds
        Timer(const Duration(seconds: 3), () {
          if (mounted) {
            messenger.hideCurrentSnackBar();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_getUserFriendlyErrorMessage(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.04).clamp(16.0, 24.0);

    final currentFilter = ref.watch(habitFilterProvider);
    final searchQuery = ref.watch(habitSearchQueryProvider);
    final categoryFilter = ref.watch(habitCategoryFilterProvider);
    final filterCounts = ref.watch(habitFilterCountsProvider);
    final filteredHabitsAsync = ref.watch(filteredHabitsProvider);
    final statsAsync = ref.watch(habitStatsProvider);
    final habitsAsync = ref.watch(habitListProvider);
    final isOffline = ref.watch(isOfflineProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Offline banner
            if (isOffline) _buildOfflineBanner(),
            // App bar
            HabitAppBar(
              isSearching: _isSearching,
              searchQuery: searchQuery,
              currentStreak: statsAsync.valueOrNull?.maxStreak ?? 0,
              onSearchToggle: _onSearchToggle,
              onSearchChanged: _onSearchChanged,
            ),
            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await ref.read(habitListProvider.notifier).refresh();
                  ref.invalidate(habitStatsProvider);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary card
                        statsAsync.when(
                          data: (stats) => HabitSummaryCard(
                            completedToday: stats.completedToday,
                            totalToday: stats.totalForToday,
                            currentStreak: stats.maxStreak,
                            bestStreak: stats.maxBestStreak,
                            weeklyRate: stats.weeklyCompletionRate,
                          ),
                          loading: () => const HabitSummaryCard(
                            completedToday: 0,
                            totalToday: 0,
                            currentStreak: 0,
                            bestStreak: 0,
                            weeklyRate: 0.0,
                          ),
                          error: (e, s) => const HabitSummaryCard(
                            completedToday: 0,
                            totalToday: 0,
                            currentStreak: 0,
                            bestStreak: 0,
                            weeklyRate: 0.0,
                          ),
                        ),
                        SizedBox(height: padding),
                        // Filters
                        HabitFilters(
                          selected: currentFilter,
                          onChanged: _onFilterChanged,
                          counts: filterCounts,
                        ),
                        SizedBox(height: padding * 0.5),
                        // Category selector
                        HabitCategorySelector(
                          selected: categoryFilter,
                          onChanged: _onCategoryChanged,
                        ),
                        SizedBox(height: padding),
                        // Habits list or empty/error state
                        filteredHabitsAsync.when(
                          data: (habits) {
                            if (habits.isEmpty) {
                              return HabitEmptyState(
                                currentFilter: currentFilter,
                                hasAnyHabits: habitsAsync.valueOrNull?.isNotEmpty ?? false,
                                searchQuery: searchQuery.isNotEmpty ? searchQuery : null,
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Habits list header
                                _buildListHeader(habits.length, currentFilter, categoryFilter),
                                SizedBox(height: padding * 0.5),
                                // Habits list
                                _buildHabitsList(habits),
                              ],
                            );
                          },
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          error: (error, _) => _buildErrorState(error),
                        ),
                        // Bottom padding for FAB
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHabitSheet(),
        backgroundColor: isOffline ? Colors.grey : AppTheme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.orange.shade700,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text(
            'You are offline - viewing cached data',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    final isNetworkError = error is NetworkError;
    final message = _getUserFriendlyErrorMessage(error);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              isNetworkError ? Icons.cloud_off : Icons.error_outline,
              size: 48,
              color: isNetworkError ? Colors.orange : AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              isNetworkError ? 'No Connection' : 'Failed to load habits',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(habitListProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListHeader(int count, HabitFilter currentFilter, HabitCategory? selectedCategory) {
    String title;
    switch (currentFilter) {
      case HabitFilter.all:
        title = 'All Habits';
        break;
      case HabitFilter.completed:
        title = 'Completed Today';
        break;
      case HabitFilter.inProgress:
        title = 'Pending Today';
        break;
      case HabitFilter.streaks:
        title = 'Active Streaks';
        break;
    }

    if (selectedCategory != null) {
      title = '${selectedCategory.label} $title';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count ${count == 1 ? 'habit' : 'habits'}',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHabitsList(List<HabitModel> habits) {
    return AnimatedBuilder(
      animation: _listAnimationController,
      builder: (context, child) {
        return Column(
          children: List.generate(habits.length, (index) {
            final habit = habits[index];

            // Staggered animation delay
            final delay = index * 0.1;
            final animationValue = Curves.easeOutCubic.transform(
              ((_listAnimationController.value - delay) / (1 - delay))
                  .clamp(0.0, 1.0),
            );

            return Opacity(
              opacity: animationValue,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - animationValue)),
                child: HabitItem(
                  habit: habit,
                  index: index,
                  onToggle: () => _toggleHabitComplete(habit),
                  onDelete: () => _deleteHabit(habit),
                  onEdit: () => _showAddHabitSheet(habit: habit),
                  onTap: () => _showHabitDetail(habit),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
