import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/stats_data.dart';

final statsProvider = StateProvider<List<StatsPoint>>((_) => const []);
