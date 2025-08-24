import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/reading.dart';

class CsvExportService {
  Future<File> exportPlantReadings({required String plantName, required List<Reading> readings, String? fileName}) async {
    final rows = <List<dynamic>>[['timestamp','power_kw','energy_kwh']];
    for (final r in readings) { rows.add([r.timestamp.toIso8601String(), r.power, r.energyKwh]); }
    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final safe = plantName.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'),'_');
    final name = fileName ?? 'solar_${safe}_${DateTime.now().toIso8601String().substring(0,10)}.csv';
    final file = File('${dir.path}/$name');
    return file.writeAsString(csv);
  }
}
