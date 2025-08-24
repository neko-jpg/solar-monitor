import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/plant.dart';
import '../models/reading.dart';
import '../services/network/default_network_service.dart';
import '../services/network/network_service.dart';
import '../services/reading/reading_service.dart';
import '../core/result.dart';
import 'plants_provider.dart';

// Using the name from the design doc
final networkProvider = FutureProvider<NetworkService>((ref) {
  return DefaultNetworkService.create();
});

final readingServiceProvider = Provider<ReadingService>((ref) {
  final net = ref.watch(networkProvider).value;
  if (net == null) {
    throw Exception("NetworkService not initialized");
  }
  return ReadingService(net);
});

// 1) Fetches only the latest reading for a given plant.
final latestReadingProvider = FutureProvider.family<Reading?, Plant>((ref, plant) async {
  final readingService = ref.watch(readingServiceProvider);
  final result = await readingService.fetchFromJson(plant.url);
  return switch (result) {
    Ok(value: final readings) => readings.isNotEmpty ? readings.last : null,
    Err(:final error) => throw error,
  };
});

// 2) Fetches all readings for all plants.
final allReadingsProvider = FutureProvider<Map<String, List<Reading>>>((ref) async {
  final plants = ref.watch(plantsProvider);
  final readingService = ref.watch(readingServiceProvider);

  final allReadings = <String, List<Reading>>{};

  // Fetch readings for all plants in parallel.
  await Future.wait(plants.map((plant) async {
    final result = await readingService.fetchFromJson(plant.url);
    if (result.isOk) {
      allReadings[plant.id] = (result as Ok<List<Reading>>).value;
    } else {
      // Handle or log the error for the specific plant
      allReadings[plant.id] = [];
    }
  }));

  return allReadings;
});
