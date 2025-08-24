import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// App layers
import '../../providers/plants_provider.dart';
import '../../models/plant.dart';
import '../../core/constants.dart';
import '../../core/result.dart';
import '../../providers/reading_provider.dart';


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
        urlC.text = p.url.toString();
        // Credentials are not stored in the plant model anymore.
        // The user will have to re-enter them if a session expires.
        nameC.text = p.name;
        themeColor = Color(p.color);
        // icon is not part of the plant model anymore
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
    if (!(_formKey1.currentState?.validate() ?? false) ||
        !(_formKey2.currentState?.validate() ?? false)) {
      _toast('Please fill in all URL and credential fields first.');
      return;
    }

    setState(() => conn = _ConnState.testing);
    try {
      final url = Uri.parse(urlC.text.trim());
      final username = userC.text.trim();
      final password = passC.text;

      final net = await ref.read(networkProvider.future);
      final result = await Result.guard(() => net.login(url, username, password));

      if (!mounted) return;

      setState(() {
        conn = result.isOk ? _ConnState.ok : _ConnState.ng;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.isOk ? '接続に成功しました' : '接続に失敗しました'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => conn = _ConnState.ng);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('接続テスト中にエラーが発生しました')),
      );
    }
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

    final url = Uri.parse(urlC.text.trim());

    // If this is a new plant, we should test the connection and log in
    // to establish a session before saving.
    if (!isEdit) {
      final username = userC.text.trim();
      final password = passC.text;
      final net = await ref.read(networkProvider.future);
      final loginResult = await Result.guard(() => net.login(url, username, password));
      if (loginResult.isErr) {
        _toast('Connection failed. Please check credentials and URL.');
        return;
      }
    }

    final p = Plant(
      id: widget.plantId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      url: url,
      color: themeColor.value,
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
