import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// App layers
import '../../providers/plants_provider.dart';
import '../../providers/reading_provider.dart';
import '../../models/plant.dart';
import '../../core/constants.dart';
import '../../core/result.dart';
import '../../services/reading/reading_service.dart';

// Step widgets
import 'widgets/step_url_input.dart';
import 'widgets/step_credentials.dart';
import 'widgets/step_theme_icon.dart';

enum _ConnState { idle, testing, ok, ng }

class PlantAddEditScreen extends ConsumerStatefulWidget {
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

  _ConnState conn = _ConnState.idle;
  String? connMsg;

  bool get isEdit => widget.plantId != null;

  bool _initialized = false;

  @override
  void dispose() {
    urlC.dispose();
    userC.dispose();
    passC.dispose();
    nameC.dispose();
    super.dispose();
  }

  void _initializeFields(WidgetRef ref) {
    if (isEdit && !_initialized) {
      final p = ref.read(plantsProvider.notifier).find(widget.plantId!);
      if (p != null) {
        urlC.text = p.url;
        userC.text = p.username;
        passC.text = p.password;
        nameC.text = p.name;
        themeColor = p.themeColor;
        icon = IconData(
          int.tryParse(p.icon) ?? Icons.wb_sunny_rounded.codePoint,
          fontFamily: 'MaterialIcons',
        );
        _initialized = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _initializeFields(ref);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        appBar: AppBar(
          title: Text(isEdit ? 'Edit Plant' : 'Add Plant'),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _buildConnChip(),
            ),
          ],
        ),
        body: Stepper(
          elevation: 1,
          margin: const EdgeInsets.all(16),
          currentStep: step,
          controlsBuilder: (c, details) {
            final isLast = step == 2;
            final canNext = switch (step) {
              0 => _formKey1.currentState?.validate() ?? false,
              1 => _formKey2.currentState?.validate() ?? false,
              _ => true,
            };

            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  FilledButton(
                    onPressed: canNext ? details.onStepContinue : null,
                    child: Text(isLast ? (isEdit ? 'Save' : 'Register') : 'Next'),
                  ),
                  const SizedBox(width: 8),
                  if (step > 0)
                    OutlinedButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: conn == _ConnState.testing ? null : _testConnection,
                    icon: conn == _ConnState.testing
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.wifi_tethering),
                    label: const Text('Test Connection'),
                  ),
                ],
              ),
            );
          },
          onStepContinue: () async {
            FocusScope.of(context).unfocus();
            if (step < 2) {
              setState(() => step++);
            } else {
              await _save();
            }
          },
          onStepCancel: () => setState(() => step--),
          steps: [
            Step(
              title: const Text('Step 1'),
              subtitle: const Text('Enter plant URL'),
              isActive: step >= 0,
              content: Form(
                key: _formKey1,
                child: StepUrlInput(
                  controller: urlC,
                  validator: (v) {
                    final raw = (v ?? '').trim();
                    if (raw.isEmpty) return 'URL is required';
                    final uri = Uri.tryParse(raw);
                    if (uri == null || !uri.isAbsolute) return 'Enter a valid URL';
                    return null;
                  },
                ),
              ),
            ),
            Step(
              title: const Text('Step 2'),
              subtitle: const Text('Enter login information'),
              isActive: step >= 1,
              content: Form(
                key: _formKey2,
                child: StepCredentials(
                  userC: userC,
                  passC: passC,
                  userValidator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  passValidator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
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
                    onChanged: (c, i) => setState(() {
                      themeColor = c;
                      icon = i;
                    }),
                  ),
                  const SizedBox(height: 8),
                  if (connMsg != null)
                    Text(
                      connMsg!,
                      style: TextStyle(
                        color: switch (conn) {
                          _ConnState.ok => Colors.green,
                          _ConnState.ng => Colors.red,
                          _ => Colors.grey,
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnChip() {
    return switch (conn) {
      _ConnState.testing => const Chip(label: Text('Testing...')),
      _ConnState.ok => const Chip(
          avatar: Icon(Icons.check_circle, color: Colors.green),
          label: Text('Connected')),
      _ConnState.ng => const Chip(
          avatar: Icon(Icons.error_outline, color: Colors.red),
          label: Text('Failed')),
      _ => const SizedBox.shrink(),
    };
  }

  Future<void> _testConnection() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey1.currentState?.validate() ?? false) ||
        !(_formKey2.currentState?.validate() ?? false)) {
      _toast('Please fill in all URL and credential fields first.');
      return;
    }

    setState(() {
      conn = _ConnState.testing;
      connMsg = null;
    });

    final tempPlant = Plant(
      id: 'test', name: 'test',
      url: urlC.text.trim(),
      username: userC.text.trim(),
      password: passC.text,
      themeColor: Colors.transparent, icon: '',
    );

    // Get the network service and create a reading service instance
    final net = await ref.read(networkServiceProvider.future);
    final readingService = ReadingService(net);

    // Use the new login method for the connection test
    final result = await readingService.login(tempPlant);

    if (!mounted) return;

    setState(() {
      conn = result.isOk ? _ConnState.ok : _ConnState.ng;
      connMsg = switch (result) {
        Ok() => 'Login successful!',
        Err(error: final e) => e.toString(),
      };
      _toast(connMsg!);
    });
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final name = (nameC.text.trim().isEmpty) ? 'New Plant' : nameC.text.trim();

    final allPlants = ref.read(plantsProvider);
    final dup = allPlants.any((p) => p.name == name && p.id != widget.plantId);
    if (dup) {
      _toast('A plant with this name already exists.');
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
    );

    final notifier = ref.read(plantsProvider.notifier);
    try {
      if (isEdit) {
        await notifier.update(p);
      } else {
        await notifier.add(p);
      }
      _toast('Saved!');

      if (!mounted) return;
      context.goNamed('dashboard');
    } catch (e) {
      _toast('Failed to save: $e');
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
  }
}
