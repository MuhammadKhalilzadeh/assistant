import 'package:assistant/data/mock/models/habit_model.dart';
import 'package:assistant/data/mock/repositories/mock_repository.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:assistant/presentation/pages/habits/widgets/add_habit_sheet.dart';
import 'package:assistant/presentation/pages/habits/widgets/habit_app_bar.dart';
import 'package:assistant/presentation/pages/habits/widgets/habit_category_chip.dart';
import 'package:assistant/presentation/pages/habits/widgets/habit_detail_sheet.dart';
import 'package:assistant/presentation/pages/habits/widgets/habit_empty_state.dart';
import 'package:assistant/presentation/pages/habits/widgets/habit_filters.dart';
import 'package:assistant/presentation/pages/habits/widgets/habit_item.dart';
import 'package:assistant/presentation/pages/habits/widgets/habit_summary_card.dart';
import 'package:flutter/material.dart';

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage>
    with SingleTickerProviderStateMixin {
  final MockRepository _repository = MockRepository();

  // State variables
  String _searchQuery = '';
  bool _isSearching = false;
  HabitFilter _currentFilter = HabitFilter.all;
  HabitCategory? _selectedCategory;

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

  List<HabitModel> get _filteredHabits {
    var habits = _repository.habits.toList();

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      habits = habits.where((h) =>
        h.name.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Apply category filter
    if (_selectedCategory != null) {
      habits = habits.where((h) => h.category == _selectedCategory).toList();
    }

    // Apply main filter
    switch (_currentFilter) {
      case HabitFilter.all:
        break;
      case HabitFilter.completed:
        habits = habits.where((h) => h.isCompletedToday).toList();
        break;
      case HabitFilter.inProgress:
        habits = habits.where((h) => !h.isCompletedToday && h.isTodayTargetDay).toList();
        break;
      case HabitFilter.streaks:
        habits = habits.where((h) => h.streak > 0).toList();
        break;
    }

    return habits;
  }

  Map<HabitFilter, int> get _filterCounts {
    final allHabits = _repository.habits;
    return {
      HabitFilter.all: allHabits.length,
      HabitFilter.completed: allHabits.where((h) => h.isCompletedToday).length,
      HabitFilter.inProgress: allHabits.where((h) => !h.isCompletedToday && h.isTodayTargetDay).length,
      HabitFilter.streaks: allHabits.where((h) => h.streak > 0).length,
    };
  }

  void _onSearchToggle() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onFilterChanged(HabitFilter filter) {
    setState(() {
      _currentFilter = filter;
    });
  }

  void _onCategoryChanged(HabitCategory? category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _showAddHabitSheet({HabitModel? habit}) {
    AddHabitSheet.show(
      context: context,
      editingHabit: habit,
      onSave: (newHabit) {
        setState(() {
          if (habit != null) {
            _repository.updateHabit(newHabit);
          } else {
            _repository.addHabit(newHabit);
          }
        });
      },
      onDelete: habit != null
          ? () {
              setState(() {
                _repository.deleteHabit(habit.id);
              });
            }
          : null,
    );
  }

  void _showHabitDetail(HabitModel habit) {
    HabitDetailSheet.show(
      context: context,
      habit: habit,
      weeklyRate: _repository.getWeeklyCompletionRate(),
      onEdit: () {
        _showAddHabitSheet(habit: habit);
      },
      onDelete: () {
        setState(() {
          _repository.deleteHabit(habit.id);
        });
      },
      onToggleToday: () {
        setState(() {
          _repository.toggleHabitComplete(habit.id);
        });
      },
    );
  }

  void _toggleHabitComplete(String id) {
    setState(() {
      _repository.toggleHabitComplete(id);
    });
  }

  void _deleteHabit(String id) {
    setState(() {
      _repository.deleteHabit(id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Habit deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Note: In a real app, we'd restore from a backup
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.04).clamp(16.0, 24.0);
    final habits = _filteredHabits;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
          child: Column(
            children: [
              // App bar
              HabitAppBar(
                isSearching: _isSearching,
                searchQuery: _searchQuery,
                currentStreak: _repository.maxStreak,
                onSearchToggle: _onSearchToggle,
                onSearchChanged: _onSearchChanged,
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary card
                        HabitSummaryCard(
                          completedToday: _repository.completedHabitsToday,
                          totalToday: _repository.totalHabitsForToday,
                          currentStreak: _repository.maxStreak,
                          bestStreak: _repository.maxBestStreak,
                          weeklyRate: _repository.getWeeklyCompletionRate(),
                        ),
                        SizedBox(height: padding),
                        // Filters
                        HabitFilters(
                          selected: _currentFilter,
                          onChanged: _onFilterChanged,
                          counts: _filterCounts,
                        ),
                        SizedBox(height: padding * 0.5),
                        // Category selector
                        HabitCategorySelector(
                          selected: _selectedCategory,
                          onChanged: _onCategoryChanged,
                        ),
                        SizedBox(height: padding),
                        // Habits list header
                        _buildListHeader(habits.length),
                        SizedBox(height: padding * 0.5),
                        // Habits list or empty state
                        if (habits.isEmpty)
                          HabitEmptyState(
                            currentFilter: _currentFilter,
                            hasAnyHabits: _repository.habits.isNotEmpty,
                            searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
                          )
                        else
                          _buildHabitsList(habits),
                        // Bottom padding for FAB
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHabitSheet(),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildListHeader(int count) {
    String title;
    switch (_currentFilter) {
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

    if (_selectedCategory != null) {
      title = '${_selectedCategory!.label} $title';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count ${count == 1 ? 'habit' : 'habits'}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
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
                  onToggle: () => _toggleHabitComplete(habit.id),
                  onDelete: () => _deleteHabit(habit.id),
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
