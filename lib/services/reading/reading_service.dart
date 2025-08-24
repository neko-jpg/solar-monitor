import '../../core/exceptions.dart';
import '../../core/result.dart';
import '../../models/plant.dart';
import '../../models/reading.dart';
import '../network/default_network_service.dart';

class ReadingService {
  final DefaultNetworkService _net;
  ReadingService(this._net);

  /// Attempts to log in using the plant's credentials.
  Future<Result<void>> login(Plant plant) async {
    try {
      final uri = Uri.parse(plant.url);
      await _net.login(uri, plant.username, plant.password);
      return const Ok(null); // Return Ok on success
    } on AppException catch (e) {
      return Err(e);
    }
  }

  /// Fetches a list of readings for a given plant.
  /// It now uses the simpler `get` method from the network service.
  Future<Result<List<Reading>>> fetchReadings(Plant plant) async {
    try {
      final uri = Uri.parse(plant.url);
      final response = await _net.get<List<dynamic>>(uri);

      final list = response.data?.cast<Map<String, dynamic>>() ?? [];
      final readings = list.map((json) => Reading.fromJson(json)).toList();

      return Ok(readings);
    } on AppException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ParseException('Failed to parse readings data.'));
    }
  }
}
