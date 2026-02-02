import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Provider for connectivity state.
/// Emits initial connectivity state immediately, then listens for changes.
/// This fixes the issue where onConnectivityChanged only fires on changes,
/// leaving the provider in AsyncLoading state indefinitely on app startup.
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) async* {
  final connectivity = Connectivity();

  // Emit current connectivity state immediately
  final initial = await connectivity.checkConnectivity();
  yield initial;

  // Then listen for changes
  await for (final result in connectivity.onConnectivityChanged) {
    yield result;
  }
});

/// Provider that returns true if the device is currently offline
final isOfflineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);

  return connectivity.when(
    data: (results) => results.isEmpty || results.every((r) => r == ConnectivityResult.none),
    loading: () => false, // Assume online while loading
    error: (e, st) => false, // Assume online on error
  );
});

/// Provider for checking connectivity on demand
final connectivityCheckProvider = FutureProvider<bool>((ref) async {
  final results = await Connectivity().checkConnectivity();
  return results.isNotEmpty && results.any((r) => r != ConnectivityResult.none);
});
