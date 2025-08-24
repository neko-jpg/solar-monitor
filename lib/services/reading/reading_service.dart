import '../../core/result.dart';
import '../../models/plant.dart';
import '../../models/reading.dart';
import '../network/default_network_service.dart';

class ReadingService {
  final DefaultNetworkService _net;
  ReadingService(this._net);

  /// Fetches a list of readings for a given plant.
  /// It assumes that authentication (cookie setup) has been handled elsewhere.
  Future<Result<List<Reading>>> fetchReadings(Plant plant) async {
    try {
      final uri = Uri.parse(plant.url);
      // Restore any saved cookies for this host
      await _net.restoreCookies(uri);

      // Make the request
      final response = await _net.getJson<List<dynamic>>(uri);

      // The API returns a list of JSON objects directly.
      final list = response.data?.cast<Map<String, dynamic>>() ?? [];

      final readings = list.map((json) {
        return Reading.fromJson(json);
      }).toList();

      return Ok(readings);
    } catch (e) {
      return Err(e);
    }
  }
}
