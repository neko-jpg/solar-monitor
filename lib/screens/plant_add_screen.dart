import '../providers/plants_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/plant.dart';
import '../models/reading.dart';

class PlantAddScreen extends ConsumerStatefulWidget {
  const PlantAddScreen({super.key});

  @override
  ConsumerState<PlantAddScreen> createState() => _PlantAddScreenState();
}

class _PlantAddScreenState extends ConsumerState<PlantAddScreen> {
  int _step = 0;
  final _urlCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  Color _color = Colors.green;
  IconData _icon = Icons.solar_power;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Plant')),
      body: Stepper(
        currentStep: _step,
        onStepContinue: () {
          if (_step < 2) {
            setState(() => _step++);
          } else {
            _save();
          }
        },
        onStepCancel: () {
          if (_step > 0) setState(() => _step--);
        },
        steps: [
          Step(
            title: const Text('Plant URL'),
            content: TextField(
              controller: _urlCtrl,
              decoration: const InputDecoration(labelText: 'URL'),
            ),
          ),
          Step(
            title: const Text('Credentials'),
            content: Column(
              children: [
                TextField(
                  controller: _userCtrl,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: _passCtrl,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Details'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 8),
                Wrap(
                  children:
                      Colors.primaries.map((c) {
                        return GestureDetector(
                          onTap: () => setState(() => _color = c),
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border:
                                  _color == c
                                      ? Border.all(
                                        color: Colors.black,
                                        width: 2,
                                      )
                                      : null,
                            ),
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 8),
                Wrap(
                  children:
                      [Icons.solar_power, Icons.sunny, Icons.bolt].map((ic) {
                        return IconButton(
                          icon: Icon(
                            ic,
                            color: _icon == ic ? _color : Colors.grey,
                          ),
                          onPressed: () => setState(() => _icon = ic),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _testConnection,
                  child: const Text('Test Connection'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _testConnection() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Connection OK (mock)')));
  }

  void _save() {
    final plant = Plant(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text,
      url: _urlCtrl.text,
      username: _userCtrl.text,
      password: _passCtrl.text,
      themeColor: _color,
      icon: _icon.codePoint.toString(),
      readings: [Reading(timestamp: DateTime.now(), power: 0)],
    );
    ref.read(plantsProvider.notifier).addPlant(plant);
    context.goNamed('dashboard');
  }
}
