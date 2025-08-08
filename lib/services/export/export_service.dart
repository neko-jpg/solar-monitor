import '../../models/plant.dart';

abstract class ExportService {
  /// 返り値：保存したファイルの絶対パス
  Future<String> exportPlantsToCsv(List<Plant> plants);
}
