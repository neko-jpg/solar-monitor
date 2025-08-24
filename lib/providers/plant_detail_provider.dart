import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/plant.dart';

final selectedPlantProvider = StateProvider<Plant?>((_) => null);
