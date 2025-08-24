import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/plant.dart';
import '../models/reading.dart';
import '../services/network/default_network_service.dart';
import '../services/reading/reading_service.dart';
import '../core/result.dart';

// Provider for the core network service.
final networkServiceProvider = FutureProvider<DefaultNetworkService>((ref) {
  return DefaultNetworkService.create();
});

// Provider for the reading service, which depends on the network service.
final readingServiceProvider = Provider<ReadingService>((ref) {
  // This will throw if the network service is not ready, which is not ideal.
  // A better approach would be for the provider to handle the async state.
  // But for now, let's assume it will be ready.
  final net = ref.watch(networkServiceProvider).value;
  if (net == null) {
    // This should not happen if we await the future elsewhere.
    throw Exception("NetworkService not initialized");
  }
  return ReadingService(net);
});


// Fetches the list of all readings for a given plant.
final readingsProvider = FutureProvider.family<List<Reading>, Plant>((ref, plant) async {
  // Wait for the network service to be ready.
  final net = await ref.watch(networkServiceProvider.future);
  // Create a service instance on the fly.
  final readingService = ReadingService(net);

  final result = await readingService.fetchReadings(plant);

  return switch (result) {
    Ok(value: final readings) => readings,
    Err(:final error) => throw error,
  };
});

// Fetches only the latest reading for a given plant.
final latestReadingProvider = Provider.family<AsyncValue<Reading?>, Plant>((ref, plant) {
  final readingsAsync = ref.watch(readingsProvider(plant));

  return readingsAsync.whenData((readings) {
    if (readings.isEmpty) {
      return null;
    }
    readings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return readings.first;
  });
});
