import 'dart:async';

import 'package:assistant/data/mock/models/todo_model.dart';
import 'package:assistant/data/errors/app_errors.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:assistant/presentation/pages/todos/widgets/add_todo_sheet.dart';
import 'package:assistant/presentation/pages/todos/widgets/todo_app_bar.dart';
import 'package:assistant/presentation/pages/todos/widgets/todo_empty_state.dart';
import 'package:assistant/presentation/pages/todos/widgets/todo_filters.dart';
import 'package:assistant/presentation/pages/todos/widgets/todo_item.dart';
import 'package:assistant/presentation/pages/todos/widgets/todo_summary_card.dart';
import 'package:assistant/providers/todo_provider.dart';
import 'package:assistant/providers/connectivity_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TodosPage extends ConsumerStatefulWidget {
  const TodosPage({super.key});

  @override
  ConsumerState<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends ConsumerState<TodosPage>
    with TickerProviderStateMixin {
  bool _isSearching = false;

  late AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
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

  void _showAddSheet() {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot add tasks while offline'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final categories = ref.read(categoriesProvider).valueOrNull ?? [];
    AddTodoSheet.show(
      context: context,
      categories: categories,
      onSave: (todo) async {
        try {
          await ref.read(todoListProvider.notifier).addTodo(todo);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_getUserFriendlyErrorMessage(e))),
            );
          }
        }
      },
    );
  }

  void _showEditSheet(TodoModel todo) {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot edit tasks while offline'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final categories = ref.read(categoriesProvider).valueOrNull ?? [];
    AddTodoSheet.show(
      context: context,
      categories: categories,
      editingTodo: todo,
      onSave: (updatedTodo) async {
        try {
          await ref.read(todoListProvider.notifier).updateTodo(updatedTodo);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_getUserFriendlyErrorMessage(e))),
            );
          }
        }
      },
      onDelete: () async {
        try {
          await ref.read(todoListProvider.notifier).deleteTodo(todo.id);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_getUserFriendlyErrorMessage(e))),
            );
          }
        }
      },
    );
  }

  void _deleteTodo(TodoModel todo) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete tasks while offline'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await ref.read(todoListProvider.notifier).deleteTodo(todo.id);
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Task deleted'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                try {
                  await ref.read(todoListProvider.notifier).restoreTodo(todo);
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
        // Manually dismiss the snackbar after 3 seconds since duration is ignored when action is present
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

  void _toggleComplete(TodoModel todo) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot update tasks while offline'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await ref.read(todoListProvider.notifier).toggleComplete(todo.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_getUserFriendlyErrorMessage(e))),
        );
      }
    }
  }

  String _getSectionTitle() {
    final searchQuery = ref.read(searchQueryProvider);
    final currentFilter = ref.read(todoFilterProvider);

    if (searchQuery.isNotEmpty) {
      return 'Search Results';
    }
    switch (currentFilter) {
      case TodoFilter.all:
        return 'All Tasks';
      case TodoFilter.active:
        return 'Active Tasks';
      case TodoFilter.completed:
        return 'Completed Tasks';
      case TodoFilter.today:
        return 'Due Today';
      case TodoFilter.upcoming:
        return 'Upcoming Tasks';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.04).clamp(16.0, 24.0);

    final currentFilter = ref.watch(todoFilterProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final filterCounts = ref.watch(filterCountsProvider);
    final filteredTodosAsync = ref.watch(filteredTodosProvider);
    final statsAsync = ref.watch(todoStatsProvider);
    final isOffline = ref.watch(isOfflineProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Offline banner
            if (isOffline) _buildOfflineBanner(),
            // App bar
            TodoAppBar(
              isSearching: _isSearching,
              searchQuery: searchQuery,
              onSearchToggle: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    ref.read(searchQueryProvider.notifier).state = '';
                  }
                });
              },
              onSearchChanged: (query) {
                ref.read(searchQueryProvider.notifier).state = query;
              },
            ),
            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await ref.read(todoListProvider.notifier).refresh();
                  ref.invalidate(todoStatsProvider);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary card
                        statsAsync.when(
                          data: (stats) => TodoSummaryCard(
                            total: stats.total,
                            completed: stats.completed,
                            todayCount: stats.todayCount,
                            overdueCount: stats.overdueCount,
                          ),
                          loading: () => const TodoSummaryCard(
                            total: 0,
                            completed: 0,
                            todayCount: 0,
                            overdueCount: 0,
                          ),
                          error: (e, s) => const TodoSummaryCard(
                            total: 0,
                            completed: 0,
                            todayCount: 0,
                            overdueCount: 0,
                          ),
                        ),
                        SizedBox(height: padding),
                        // Filters
                        TodoFilters(
                          selected: currentFilter,
                          onChanged: (filter) {
                            ref.read(todoFilterProvider.notifier).state =
                                filter;
                          },
                          counts: filterCounts,
                        ),
                        SizedBox(height: padding),
                        // Todos list or empty state
                        filteredTodosAsync.when(
                          data: (filteredTodos) {
                            if (filteredTodos.isEmpty) {
                              // Calculate available height for proper centering
                              final availableHeight =
                                  MediaQuery.of(context).size.height * 0.45;
                              return SizedBox(
                                height: availableHeight,
                                child: Center(
                                  child: TodoEmptyState(
                                      currentFilter: currentFilter),
                                ),
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Section title
                                Text(
                                  _getSectionTitle(),
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Animated list
                                _buildAnimatedList(filteredTodos),
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
                        SizedBox(height: padding),
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
        onPressed: _showAddSheet,
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
              isNetworkError ? 'No Connection' : 'Failed to load tasks',
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
                ref.invalidate(todoListProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedList(List<TodoModel> todos) {
    return Column(
      children: List.generate(todos.length, (index) {
        final todo = todos[index];
        return TweenAnimationBuilder<double>(
          key: ValueKey(todo.id),
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: TodoItem(
            todo: todo,
            index: index,
            onToggle: () => _toggleComplete(todo),
            onDelete: () => _deleteTodo(todo),
            onEdit: () => _showEditSheet(todo),
          ),
        );
      }),
    );
  }
}
