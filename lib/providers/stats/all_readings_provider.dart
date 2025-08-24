import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/reading.dart';
import '../plants_provider.dart';
import '../reading_provider.dart';

/// A provider that fetches readings for all plants and groups them by plant ID.
final allReadingsProvider = FutureProvider<Map<String, List<Reading>>>((ref) async {
  final plants = ref.watch(plantsProvider);
  if (plants.isEmpty) {
    return {};
  }

  final Map<String, List<Reading>> allReadings = {};

  // Fetch all readings in parallel.
  final futures = plants.map((p) => ref.watch(readingsProvider(p).future));
  final results = await Future.wait(futures);

  for (int i = 0; i < plants.length; i++) {
    allReadings[plants[i].id] = results[i];
  }

  return allReadings;
});
