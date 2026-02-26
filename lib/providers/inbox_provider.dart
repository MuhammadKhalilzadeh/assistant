import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistant/data/models/inbox_message_model.dart';
import 'package:assistant/data/services/inbox_api_service.dart';
import 'package:assistant/data/cache/inbox_cache.dart';
import 'package:assistant/data/errors/app_errors.dart';
import 'package:assistant/providers/connectivity_provider.dart';

// Cache provider
final inboxCacheProvider = Provider<InboxCache>((ref) {
  return InboxCache();
});

// API Service provider
final inboxApiServiceProvider = Provider<InboxApiService>((ref) {
  return InboxApiService();
});

// Inbox messages provider
final inboxMessagesProvider =
    AsyncNotifierProvider<InboxMessagesNotifier, List<InboxMessage>>(
        InboxMessagesNotifier.new);

class InboxMessagesNotifier extends AsyncNotifier<List<InboxMessage>> {
  @override
  Future<List<InboxMessage>> build() async {
    return _fetchMessages();
  }

  Future<List<InboxMessage>> _fetchMessages() async {
    final api = ref.read(inboxApiServiceProvider);
    final cache = ref.read(inboxCacheProvider);
    final isOffline = ref.read(isOfflineProvider);

    if (isOffline) {
      final cachedMessages = await cache.getCachedMessages();
      if (cachedMessages != null) return cachedMessages;
      throw NetworkError('No internet connection and no cached data available');
    }

    try {
      final messages = await api.getMessages();
      await cache.cacheMessages(messages);
      return messages;
    } on NetworkError {
      final cachedMessages = await cache.getCachedMessages();
      if (cachedMessages != null) return cachedMessages;
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchMessages());
  }

  Future<void> addMessage(InboxMessage message) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot add messages while offline');
    }

    final api = ref.read(inboxApiServiceProvider);
    final cache = ref.read(inboxCacheProvider);
    final newMessage = await api.createMessage(message);

    state = state.whenData((messages) => [newMessage, ...messages]);

    if (state.hasValue) {
      await cache.cacheMessages(state.value!);
    }

    ref.invalidate(inboxStatsProvider);
  }

  Future<void> markAsRead(String id) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot mark messages while offline');
    }

    final api = ref.read(inboxApiServiceProvider);
    final cache = ref.read(inboxCacheProvider);
    final updated = await api.markAsRead(id);

    state = state.whenData((messages) {
      final index = messages.indexWhere((m) => m.id == id);
      if (index != -1) {
        final newMessages = [...messages];
        newMessages[index] = updated;
        return newMessages;
      }
      return messages;
    });

    if (state.hasValue) {
      await cache.cacheMessages(state.value!);
    }

    ref.invalidate(inboxStatsProvider);
  }

  Future<void> toggleStar(String id) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot star messages while offline');
    }

    final api = ref.read(inboxApiServiceProvider);
    final cache = ref.read(inboxCacheProvider);
    final updated = await api.toggleStar(id);

    state = state.whenData((messages) {
      final index = messages.indexWhere((m) => m.id == id);
      if (index != -1) {
        final newMessages = [...messages];
        newMessages[index] = updated;
        return newMessages;
      }
      return messages;
    });

    if (state.hasValue) {
      await cache.cacheMessages(state.value!);
    }

    ref.invalidate(inboxStatsProvider);
  }

  Future<void> syncGmail() async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot sync Gmail while offline');
    }

    final api = ref.read(inboxApiServiceProvider);
    await api.syncGmail();

    // Refresh messages and stats after sync
    await refresh();
    ref.invalidate(inboxStatsProvider);
  }

  Future<String> getMessageBody(String id) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot fetch message body while offline');
    }

    final api = ref.read(inboxApiServiceProvider);
    return await api.getMessageBody(id);
  }

  Future<void> deleteMessage(String id) async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      throw OfflineError('Cannot delete messages while offline');
    }

    final api = ref.read(inboxApiServiceProvider);
    final cache = ref.read(inboxCacheProvider);
    await api.deleteMessage(id);

    state = state.whenData((messages) => messages.where((m) => m.id != id).toList());

    if (state.hasValue) {
      await cache.cacheMessages(state.value!);
    }

    ref.invalidate(inboxStatsProvider);
  }
}

// Inbox stats provider
final inboxStatsProvider = FutureProvider<InboxStats>((ref) async {
  final api = ref.read(inboxApiServiceProvider);
  final cache = ref.read(inboxCacheProvider);
  final isOffline = ref.read(isOfflineProvider);

  if (isOffline) {
    final cachedStats = await cache.getCachedStats();
    if (cachedStats != null) {
      return InboxStats.fromJson(cachedStats);
    }
    throw NetworkError('No internet connection and no cached stats available');
  }

  try {
    final stats = await api.getStats();
    await cache.cacheStats(stats.toJson());
    return stats;
  } on NetworkError {
    final cachedStats = await cache.getCachedStats();
    if (cachedStats != null) {
      return InboxStats.fromJson(cachedStats);
    }
    rethrow;
  }
});
