import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/utils/aggregation.dart';
import 'package:flutter_application_1/models/reading.dart';

void main(){
  test('totalEnergyKwh integrates power by trapezoid when energy is null', (){
    final t = DateTime(2025,1,1,0,0,0);
    final list = [
      Reading(timestamp: t, power: 0),
      Reading(timestamp: t.add(const Duration(hours:1)), power: 2),
      Reading(timestamp: t.add(const Duration(hours:2)), power: 2),
    ];
    expect(totalEnergyKwh(list), closeTo(3.0, 1e-6));
  });
}
