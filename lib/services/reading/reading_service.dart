import 'dart:convert';
import 'package:csv/csv.dart';
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
      final body = res.data as String;
      final root = jsonDecode(body);
      final list = root is Map<String, dynamic>
          ? (root['readings'] as List? ?? const [])
          : (root as List);
      final out = <Reading>[];
      for (final it in list) {
        final m = (it as Map).cast<String, dynamic>();
        final tsStr = (m['timestamp'] ?? m['time'] ?? m['at']) as String;
        final ts = DateTime.parse(tsStr).toLocal();
        final powerNum = (m['power'] ?? m['power_kw'] ?? m['kw']) as num;
        final energyNum = m['energyKwh'] ?? m['energy_kwh'];
        out.add(Reading(
          timestamp: ts,
          power: powerNum.toDouble(),
          energyKwh: energyNum == null ? null : (energyNum as num).toDouble(),
        ));
      }
      out.sort((a,b)=>a.timestamp.compareTo(b.timestamp));
      return Ok(out.where((r) => r.power.isFinite && r.power >= 0).toList());
    } catch (e) {
      return Err(AppException(AppExceptionKind.parse, 'JSON parse failed', e));
    }
  }

  @override
  Future<Result<List<Reading>>> fetchFromCsv(Uri endpoint) async {
    try {
      final res = await _net.getText<String>(endpoint);
      final csv = res.data as String;
      final rows = const CsvToListConverter().convert(csv, eol: '\n');
      // ヘッダ例: timestamp,power_kw,energy_kwh
      final out = <Reading>[];
      final header = rows.first.map((e) => e.toString().toLowerCase()).toList();
      final iTs = header.indexOf('timestamp');
      final iPower = header.indexOf('power_kw');
      final iEnergy = header.indexOf('energy_kwh');
      for (var i = 1; i < rows.length; i++) {
        final r = rows[i];
        final ts = DateTime.parse(r[iTs].toString()).toLocal();
        final power = (r[iPower] as num).toDouble();
        final energy = iEnergy >= 0 ? (r[iEnergy] as num?)?.toDouble() : null;
        out.add(Reading(timestamp: ts, power: power, energyKwh: energy));
      }
      out.sort((a,b)=>a.timestamp.compareTo(b.timestamp));
      return Ok(out);
    } catch (e) {
      return Err(AppException(AppExceptionKind.parse, 'CSV parse failed', e));
    }
  }
}
