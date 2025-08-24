import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/plant.dart';
import '../models/reading.dart';
import '../services/network/default_network_service.dart';
import '../services/network/network_service.dart';
import '../services/reading/reading_service.dart';
import '../core/result.dart';
import 'plants_provider.dart';

final networkProvider = FutureProvider<NetworkService>((ref) async => DefaultNetworkService.create());
final readingServiceProvider = Provider<ReadingService>((ref) {
  final net = ref.watch(networkProvider).maybeWhen(data: (n) => n, orElse: () => null);
  if (net == null) {
    // ダミー（呼ばれない想定）
    throw StateError('NetworkService not ready');
  }
  return ReadingService(net);
});

final latestReadingProvider = FutureProvider.family<Reading?, Plant>((ref, plant) async {
  final net = await ref.watch(networkProvider.future);
  final svc = ReadingService(net);
  final res = await svc.fetchFromJson(plant.url);
  if (res is Ok<List<Reading>>) return res.value.isEmpty ? null : res.value.last;
  return null;
});

final allReadingsProvider = FutureProvider<Map<String, List<Reading>>>((ref) async {
  final plants = ref.watch(plantsProvider);
  final net = await ref.watch(networkProvider.future);
  final svc = ReadingService(net);
  final out = <String, List<Reading>>{};
  await Future.wait(plants.map((p) async {
    final r = await svc.fetchFromJson(p.url);
    out[p.id] = r is Ok<List<Reading>> ? r.value : const <Reading>[];
  }));
  return out;
});
