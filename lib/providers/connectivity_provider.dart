import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Provider for connectivity state.
/// In connectivity_plus 6.x, onConnectivityChanged returns a list of results.
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
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
