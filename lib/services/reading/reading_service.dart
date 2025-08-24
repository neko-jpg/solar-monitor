import 'dart:convert';
import '../../core/exceptions.dart';
import '../../core/result.dart';
import '../../models/reading.dart';
import '../network/network_service.dart';

abstract class IReadingService {
  Future<Result<List<Reading>>> fetchFromJson(Uri endpoint);
  Future<Result<List<Reading>>> fetchFromCsv(Uri endpoint);
}

class ReadingService implements IReadingService {
  final NetworkService _net;
  ReadingService(this._net);

  @override
  Future<Result<List<Reading>>> fetchFromJson(Uri endpoint) async {
    try {
      final res = await _net.getText<String>(endpoint);
      final body = res.data as String; // JSON text
      final jsonMap = jsonDecode(body) as Map<String, dynamic>;
      final list = (jsonMap['readings'] as List?) ?? const [];
      final readings = <Reading>[];
      for (final e in list) {
        final m = (e as Map<String, dynamic>);
        final ts = DateTime.parse((m['timestamp'] ?? m['time'] ?? m['at']) as String).toLocal();
        final power = (m['power'] ?? m['power_kw'] ?? m['kw']) as num;
        final energy = (m['energyKwh'] ?? m['energy_kwh']);
        readings.add(Reading(
          timestamp: ts,
          power: power.toDouble(),
          energyKwh: energy == null ? null : (energy as num).toDouble(),
        ));
      }
      readings.sort((a,b)=>a.timestamp.compareTo(b.timestamp));
      // NaN/負値の除去
      final cleaned = readings.where((r) => r.power.isFinite && r.power >= 0).toList();
      return Ok(cleaned);
    } on AppException { rethrow; }
      catch (e) { return Err(AppException(AppExceptionKind.parse, 'Failed to parse JSON readings.', e)); }
  }

  @override
  Future<Result<List<Reading>>> fetchFromCsv(Uri endpoint) async {
    // 将来実装。MVPは JSON を前提。
    return Err(AppException(AppExceptionKind.unknown, 'CSV parsing not implemented yet.'));
  }
}
