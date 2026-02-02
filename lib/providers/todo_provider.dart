import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/data/mock/models/todo_model.dart';
import 'package:assistant/data/models/category_model.dart';
import 'package:assistant/data/models/todo_stats.dart';
import 'package:assistant/data/services/todo_api_service.dart';
import 'package:assistant/data/cache/todo_cache.dart';
import 'package:assistant/data/errors/app_errors.dart';
import 'package:assistant/providers/connectivity_provider.dart';

// Cache provider
final todoCacheProvider = Provider<TodoCache>((ref) {
  return TodoCache();
});

// API Service provider
final todoApiServiceProvider = Provider<TodoApiService>((ref) {
  return TodoApiService();
});

// Todo list provider
final todoListProvider =
    AsyncNotifierProvider<TodoNotifier, List<TodoModel>>(TodoNotifier.new);

class TodoNotifier extends AsyncNotifier<List<TodoModel>> {
  @override
  Future<List<TodoModel>> build() async {
    return _fetchTodos();
  }

  Future<List<TodoModel>> _fetchTodos() async {
    final api = ref.read(todoApiServiceProvider);
    final cache = ref.read(todoCacheProvider);
    final isOffline = ref.read(isOfflineProvider);

    // If offline, try to return cached data
    if (isOffline) {
      final cachedTodos = await cache.getCachedTodos();
      if (cachedTodos != null) {
        return cachedTodos;
      }
      throw NetworkError('No internet connection and no cached data available');
    }

    try {
      final todos = await api.getTodos();
      // Cache the fresh data
      await cache.cacheTodos(todos);
      return todos;
    } on NetworkError {
      // On network error, try to return cached data
      final cachedTodos = await cache.getCachedTodos();
      if (cachedTodos != null) {
        return cachedTodos;
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchTodos());
  }

  Future<void> addTodo(TodoModel todo) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot add tasks while offline');
    }

    final api = ref.read(todoApiServiceProvider);
    final cache = ref.read(todoCacheProvider);
    final newTodo = await api.createTodo(todo);

    state = state.whenData((todos) => [newTodo, ...todos]);

    // Update cache
    if (state.hasValue) {
      await cache.cacheTodos(state.value!);
    }

    // Invalidate stats
    ref.invalidate(todoStatsProvider);
  }

  Future<void> updateTodo(TodoModel todo) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot update tasks while offline');
    }

    final api = ref.read(todoApiServiceProvider);
    final cache = ref.read(todoCacheProvider);
    final updatedTodo = await api.updateTodo(todo);

    state = state.whenData((todos) {
      final index = todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        final newTodos = [...todos];
        newTodos[index] = updatedTodo;
        return newTodos;
      }
      return todos;
    });

    // Update cache
    if (state.hasValue) {
      await cache.cacheTodos(state.value!);
    }

    // Invalidate stats
    ref.invalidate(todoStatsProvider);
  }

  Future<void> deleteTodo(String id) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot delete tasks while offline');
    }

    final api = ref.read(todoApiServiceProvider);
    final cache = ref.read(todoCacheProvider);
    await api.deleteTodo(id);

    state = state.whenData((todos) => todos.where((t) => t.id != id).toList());

    // Update cache
    if (state.hasValue) {
      await cache.cacheTodos(state.value!);
    }

    // Invalidate stats
    ref.invalidate(todoStatsProvider);
  }

  Future<void> toggleComplete(String id) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot update tasks while offline');
    }

    final api = ref.read(todoApiServiceProvider);
    final cache = ref.read(todoCacheProvider);
    final updatedTodo = await api.toggleComplete(id);

    state = state.whenData((todos) {
      final index = todos.indexWhere((t) => t.id == id);
      if (index != -1) {
        final newTodos = [...todos];
        newTodos[index] = updatedTodo;
        return newTodos;
      }
      return todos;
    });

    // Update cache
    if (state.hasValue) {
      await cache.cacheTodos(state.value!);
    }

    // Invalidate stats
    ref.invalidate(todoStatsProvider);
  }

  // Helper to restore a deleted todo (for undo functionality)
  Future<void> restoreTodo(TodoModel todo) async {
    await addTodo(todo);
  }
}

// Todo stats provider with caching
final todoStatsProvider = FutureProvider<TodoStats>((ref) async {
  final api = ref.read(todoApiServiceProvider);
  final cache = ref.read(todoCacheProvider);
  final isOffline = ref.read(isOfflineProvider);

  if (isOffline) {
    final cachedStats = await cache.getCachedStats();
    if (cachedStats != null) {
      return TodoStats.fromJson(cachedStats);
    }
    throw NetworkError('No internet connection and no cached stats available');
  }

  try {
    final stats = await api.getStats();
    // Cache the stats
    await cache.cacheStats(stats.toJson());
    return stats;
  } on NetworkError {
    final cachedStats = await cache.getCachedStats();
    if (cachedStats != null) {
      return TodoStats.fromJson(cachedStats);
    }
    rethrow;
  }
});

// Categories provider
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final api = ref.read(todoApiServiceProvider);
  return api.getCategories();
});

// Filter state
enum TodoFilter { all, active, completed, today, upcoming }

final todoFilterProvider = StateProvider<TodoFilter>((ref) => TodoFilter.all);

// Search query state
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filtered and sorted todos
final filteredTodosProvider = Provider<AsyncValue<List<TodoModel>>>((ref) {
  final todosAsync = ref.watch(todoListProvider);
  final filter = ref.watch(todoFilterProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  return todosAsync.whenData((todos) {
    var filtered = [...todos];

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((todo) {
        return todo.title.toLowerCase().contains(query) ||
            (todo.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply category filter
    switch (filter) {
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
  });
});

// Helper functions
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

// Filter counts provider
final filterCountsProvider = Provider<Map<TodoFilter, int>>((ref) {
  final todosAsync = ref.watch(todoListProvider);

  return todosAsync.when(
    data: (todos) => {
      TodoFilter.all: todos.length,
      TodoFilter.active: todos.where((t) => !t.isCompleted).length,
      TodoFilter.completed: todos.where((t) => t.isCompleted).length,
      TodoFilter.today: todos.where(_isDueToday).length,
      TodoFilter.upcoming: todos.where(_isUpcoming).length,
    },
    loading: () => {
      TodoFilter.all: 0,
      TodoFilter.active: 0,
      TodoFilter.completed: 0,
      TodoFilter.today: 0,
      TodoFilter.upcoming: 0,
    },
    error: (e, s) => {
      TodoFilter.all: 0,
      TodoFilter.active: 0,
      TodoFilter.completed: 0,
      TodoFilter.today: 0,
      TodoFilter.upcoming: 0,
    },
  );
});
