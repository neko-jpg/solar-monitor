import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/plants_provider.dart';
import '../../models/plant.dart';
import '../../models/reading.dart';
import '../../core/constants.dart';

import '../../services/network/default_network_service.dart';
import '../../services/network/network_service.dart';

import 'widgets/step_url_input.dart';
import 'widgets/step_credentials.dart';
import 'widgets/step_theme_icon.dart';

class PlantAddEditScreen extends ConsumerStatefulWidget {
  // 編集モード：plantIdを渡す
  const PlantAddEditScreen({super.key, this.plantId});
  final String? plantId;

  @override
  ConsumerState<PlantAddEditScreen> createState() => _PlantAddEditScreenState();
}

class _PlantAddEditScreenState extends ConsumerState<PlantAddEditScreen> {
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  int step = 0;

  final urlC = TextEditingController();
  final userC = TextEditingController();
  final passC = TextEditingController();
  final nameC = TextEditingController();

  Color themeColor = AppTok.blue;
  IconData icon = Icons.wb_sunny_rounded;

  bool testing = false;
  String? testMessage;
  final NetworkService net = DefaultNetworkService();

  bool get isEdit => widget.plantId != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final p = ref.read(plantsProvider.notifier).find(widget.plantId!)!;
      urlC.text = p.url;
      userC.text = p.username;
      passC.text = p.password;
      nameC.text = p.name;
      themeColor = p.themeColor;
      icon = IconData(
        int.tryParse(p.icon) ?? Icons.wb_sunny_rounded.codePoint,
        fontFamily: 'MaterialIcons',
      );
    }
  }

  @override
  void dispose() {
    urlC.dispose();
    userC.dispose();
    passC.dispose();
    nameC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plants = ref.watch(plantsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Plant' : 'Add Plant')),
      backgroundColor: const Color(0xFFF6F7FB),
      body: Stepper(
        currentStep: step,
        controlsBuilder: (c, details) {
          final isLast = step == 2;
          final canNext = switch (step) {
            0 => _formKey1.currentState?.validate() ?? false,
            1 => _formKey2.currentState?.validate() ?? false,
            _ => true,
          };
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: canNext ? details.onStepContinue : null,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(isLast ? (isEdit ? 'Save' : 'Register') : 'Next'),
                ),
                const SizedBox(width: 8),
                if (step > 0)
                  OutlinedButton(
                    onPressed: details.onStepCancel,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Back'),
                  ),
                if (step == 2) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: testing ? null : _testConnection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTok.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        testing
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text('Test Connection'),
                  ),
                ],
              ],
            ),
          );
        },
        onStepContinue: () async {
          if (step < 2) {
            setState(() => step++);
          } else {
            await _save(plants);
          }
        },
        onStepCancel: () => setState(() => step--),
        steps: [
          Step(
            title: const Text('Step 1'),
            subtitle: const Text('Enter plant URL'),
            isActive: step >= 0,
            state: step > 0 ? StepState.complete : StepState.indexed,
            content: Form(
              key: _formKey1,
              child: StepUrlInput(
                controller: urlC,
                validator: (v) {
                  final url = v?.trim() ?? '';
                  final ok =
                      Uri.tryParse(url)?.hasAbsolutePath == true &&
                      (url.startsWith('http://') || url.startsWith('https://'));
                  if (!ok) return 'Enter valid URL (http/https)';
                  return null;
                },
              ),
            ),
          ),
          Step(
            title: const Text('Step 2'),
            subtitle: const Text('Enter login information'),
            isActive: step >= 1,
            state: step > 1 ? StepState.complete : StepState.indexed,
            content: Form(
              key: _formKey2,
              child: StepCredentials(
                userC: userC,
                passC: passC,
                userValidator:
                    (v) => (v == null || v.isEmpty) ? 'Required' : null,
                passValidator:
                    (v) =>
                        (v == null || v.isEmpty)
                            ? 'Required'
                            : (v.length < 4 ? 'Too short' : null),
              ),
            ),
          ),
          Step(
            title: const Text('Step 3'),
            subtitle: const Text('Enter name/theme'),
            isActive: step >= 2,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StepThemeIcon(
                  nameC: nameC,
                  initialColor: themeColor,
                  initialIcon: icon,
                  onChanged:
                      (c, i) => setState(() {
                        themeColor = c;
                        icon = i;
                      }),
                ),
                const SizedBox(height: 8),
                if (testMessage != null)
                  Text(
                    testMessage!,
                    style: TextStyle(
                      color:
                          testMessage!.contains('OK')
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _testConnection() async {
    setState(() {
      testing = true;
      testMessage = null;
    });
    final ok = await net.testConnection(
      url: urlC.text.trim(),
      username: userC.text.trim(),
      password: passC.text,
    );
    setState(() {
      testing = false;
      testMessage = ok ? 'Connection OK' : 'Connection failed';
    });
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(testMessage!)));
  }

  Future<void> _save(List<Plant> all) async {
    final name = (nameC.text.trim().isEmpty) ? 'New Plant' : nameC.text.trim();
    // 名前重複チェック（同一IDは除外）
    final dup = all.any((p) => p.name == name && p.id != widget.plantId);
    if (dup) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name already exists.')));
      return;
    }

    final p = Plant(
      id: widget.plantId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      url: urlC.text.trim(),
      username: userC.text.trim(),
      password: passC.text,
      themeColor: themeColor,
      icon: icon.codePoint.toString(),
      readings:
          isEdit
              ? ref
                  .read(plantsProvider)
                  .firstWhere((x) => x.id == widget.plantId)
                  .readings
              : [Reading(timestamp: DateTime.now(), power: 0)],
    );

    final n = ref.read(plantsProvider.notifier);
    if (isEdit) {
      n.update(p);
    } else {
      n.add(p);
    }
    if (!mounted) return;
    context.goNamed('dashboard');
  }
}
