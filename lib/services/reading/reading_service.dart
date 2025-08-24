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
      final response = await _net.getJson<Map<String, dynamic>>(endpoint);
      final list = (response.data?['readings'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      final readings = list.map((json) => Reading.fromJson(json)).toList();
      // Ensure readings are sorted by timestamp
      readings.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return Ok(readings);
    } on AppException {
      rethrow;
    } catch (e) {
      // Log the error s
      return Err(AppException(AppExceptionKind.parse, 'Failed to parse JSON readings.', e));
    }
  }

  @override
  Future<Result<List<Reading>>> fetchFromCsv(Uri endpoint) async {
    // TODO: Implement CSV parsing
    await Future.delayed(const Duration(seconds: 1));
    return Err(AppException(AppExceptionKind.unknown, 'CSV parsing not implemented yet.'));
  }
}
