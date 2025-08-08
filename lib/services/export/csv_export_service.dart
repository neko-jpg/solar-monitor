import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../models/plant.dart';
import 'export_service.dart';

class CsvExportService implements ExportService {
  @override
  Future<String> exportPlantsToCsv(List<Plant> plants) async {
    final headers = 'plant_id,plant_name,timestamp,power_kW\n';
    final buffer = StringBuffer(headers);

    for (final p in plants) {
      for (final r in p.readings) {
        buffer.writeln(
          '${p.id},${_escape(p.name)},${r.timestamp.toIso8601String()},${r.power}',
        );
      }
    }

    final dir = await getTemporaryDirectory(); // 端末の一時領域
    final file = File('${dir.path}/solar_monitor_export.csv');
    await file.writeAsString(buffer.toString(), flush: true);
    return file.path;
  }

  String _escape(String s) {
    if (s.contains(',') || s.contains('"')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }
}
