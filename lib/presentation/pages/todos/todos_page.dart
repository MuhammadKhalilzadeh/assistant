import 'package:assistant/data/mock/models/todo_model.dart';
import 'package:assistant/data/mock/repositories/mock_repository.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:assistant/presentation/pages/todos/widgets/add_todo_sheet.dart';
import 'package:assistant/presentation/pages/todos/widgets/todo_app_bar.dart';
import 'package:assistant/presentation/pages/todos/widgets/todo_empty_state.dart';
import 'package:assistant/presentation/pages/todos/widgets/todo_filters.dart';
import 'package:assistant/presentation/pages/todos/widgets/todo_item.dart';
import 'package:assistant/presentation/pages/todos/widgets/todo_summary_card.dart';
import 'package:flutter/material.dart';

class TodosPage extends StatefulWidget {
  const TodosPage({super.key});

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> with TickerProviderStateMixin {
  final MockRepository _repository = MockRepository();
  String _searchQuery = '';
  TodoFilter _currentFilter = TodoFilter.all;
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

  List<TodoModel> _filterTodos(List<TodoModel> todos) {
    var filtered = [...todos];

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((todo) {
        return todo.title.toLowerCase().contains(query) ||
            (todo.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply category filter
    switch (_currentFilter) {
      case TodoFilter.all:
        break;
      case TodoFilter.active:
        filtered = filtered.where((t) => !t.isCompleted).toList();
        break;
      case TodoFilter.completed:
        filtered = filtered.where((t) => t.isCompleted).toList();
        break;
      case TodoFilter.today:
        filtered = filtered.where(_isDueToday).toList();
        break;
      case TodoFilter.upcoming:
        filtered = filtered.where(_isUpcoming).toList();
        break;
    }

    // Sort: incomplete first, then by priority, then by due date
    filtered.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      if (a.priority != b.priority) {
        return a.priority.compareTo(b.priority);
      }
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      if (a.dueDate != null) return -1;
      if (b.dueDate != null) return 1;
      return 0;
    });

    return filtered;
  }

  bool _isDueToday(TodoModel todo) {
    if (todo.dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(
      todo.dueDate!.year,
      todo.dueDate!.month,
      todo.dueDate!.day,
    );
    return dueDate == today;
  }

  bool _isUpcoming(TodoModel todo) {
    if (todo.dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(
      todo.dueDate!.year,
      todo.dueDate!.month,
      todo.dueDate!.day,
    );
    return dueDate.isAfter(today);
  }

  bool _isOverdue(TodoModel todo) {
    if (todo.dueDate == null || todo.isCompleted) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(
      todo.dueDate!.year,
      todo.dueDate!.month,
      todo.dueDate!.day,
    );
    return dueDate.isBefore(today);
  }

  Map<TodoFilter, int> _getFilterCounts(List<TodoModel> todos) {
    return {
      TodoFilter.all: todos.length,
      TodoFilter.active: todos.where((t) => !t.isCompleted).length,
      TodoFilter.completed: todos.where((t) => t.isCompleted).length,
      TodoFilter.today: todos.where(_isDueToday).length,
      TodoFilter.upcoming: todos.where(_isUpcoming).length,
    };
  }

  void _showAddSheet() {
    AddTodoSheet.show(
      context: context,
      onSave: (todo) {
        _repository.addTodo(todo);
        setState(() {});
      },
    );
  }

  void _showEditSheet(TodoModel todo) {
    AddTodoSheet.show(
      context: context,
      editingTodo: todo,
      onSave: (updatedTodo) {
        _repository.updateTodo(updatedTodo);
        setState(() {});
      },
      onDelete: () {
        _repository.deleteTodo(todo.id);
        setState(() {});
      },
    );
  }

  void _deleteTodo(TodoModel todo) {
    _repository.deleteTodo(todo.id);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Task deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            _repository.addTodo(todo);
            setState(() {});
          },
        ),
      ),
    );
  }

  void _toggleComplete(TodoModel todo) {
    _repository.toggleTodoComplete(todo.id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.04).clamp(16.0, 24.0);
    final todos = _repository.todos;
    final filteredTodos = _filterTodos(todos);
    final filterCounts = _getFilterCounts(todos);
    final completedCount = _repository.completedTodosCount;
    final todayCount = todos.where(_isDueToday).length;
    final overdueCount = todos.where(_isOverdue).length;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
          child: Column(
            children: [
              // App bar
              TodoAppBar(
                isSearching: _isSearching,
                searchQuery: _searchQuery,
                onSearchToggle: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchQuery = '';
                    }
                  });
                },
                onSearchChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary card
                        TodoSummaryCard(
                          total: todos.length,
                          completed: completedCount,
                          todayCount: todayCount,
                          overdueCount: overdueCount,
                        ),
                        SizedBox(height: padding),
                        // Filters
                        TodoFilters(
                          selected: _currentFilter,
                          onChanged: (filter) {
                            setState(() {
                              _currentFilter = filter;
                            });
                          },
                          counts: filterCounts,
                        ),
                        SizedBox(height: padding),
                        // Section title
                        if (filteredTodos.isNotEmpty) ...[
                          Text(
                            _getSectionTitle(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        // Todos list or empty state
                        if (filteredTodos.isEmpty)
                          TodoEmptyState(currentFilter: _currentFilter)
                        else
                          _buildAnimatedList(filteredTodos),
                        SizedBox(height: padding),
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
        onPressed: _showAddSheet,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getSectionTitle() {
    if (_searchQuery.isNotEmpty) {
      return 'Search Results';
    }
    switch (_currentFilter) {
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
