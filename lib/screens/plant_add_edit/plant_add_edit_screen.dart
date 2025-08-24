// lib/screens/plant_add_edit/plant_add_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Network（接続テスト用）
import '../../services/network/default_network_service.dart';
import '../../services/network/network_service.dart';

// App layers
import '../../providers/plants_provider.dart';
import '../../models/plant.dart';
import '../../models/reading.dart';
import '../../core/constants.dart';

// Step widgets
import 'widgets/step_url_input.dart';
import 'widgets/step_credentials.dart';
import 'widgets/step_theme_icon.dart';

// Discovery
import '../../services/discovery_service.dart';

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

  final NetworkService net = DefaultNetworkService();
  final _discovery = DiscoveryService();

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
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isLast ? (isEdit ? 'Save' : 'Register') : 'Next',
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (step > 0)
                    OutlinedButton(
                      onPressed: details.onStepCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed:
                        conn == _ConnState.testing ? null : _testConnection,
                    icon:
                        conn == _ConnState.testing
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.wifi_tethering),
                    label: const Text('Test Connection'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTok.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
              content: Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Form(
                    key: _formKey1,
                    child: StepUrlInput(
                      controller: urlC,
                      validator: (v) {
                        final raw = (v ?? '').trim();
                        if (raw.isEmpty) return 'URL is required';
                        final hasScheme =
                            raw.startsWith('http://') ||
                            raw.startsWith('https://');
                        final test = hasScheme ? raw : 'https://$raw';
                        final ok = Uri.tryParse(test)?.hasAbsolutePath == true;
                        if (!ok) return 'Enter valid URL';
                        return null;
                      },
                    ),
                  ),
                ),
              ),
            ),
            Step(
              title: const Text('Step 2'),
              subtitle: const Text('Enter login information'),
              isActive: step >= 1,
              state: step > 1 ? StepState.complete : StepState.indexed,
              content: Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Form(
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
              ),
            ),
            Step(
              title: const Text('Step 3'),
              subtitle: const Text('Enter name/theme'),
              isActive: step >= 2,
              content: Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
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
        label: Text('Connected'),
      ),
      _ConnState.ng => const Chip(
        avatar: Icon(Icons.error_outline, color: Colors.red),
        label: Text('Failed'),
      ),
      _ => const SizedBox.shrink(),
    };
  }

  Future<void> _testConnection() async {
    FocusScope.of(context).unfocus();
    var raw = urlC.text.trim();
    if (raw.isEmpty) {
      _toast('URL is required');
      return;
    }
    if (!(raw.startsWith('http://') || raw.startsWith('https://')))
      raw = 'https://$raw';
    final parsed = Uri.tryParse(raw);
    if (parsed == null || !parsed.hasAbsolutePath) {
      _toast('Enter valid URL');
      return;
    }

    setState(() {
      conn = _ConnState.testing;
      connMsg = null;
    });

    try {
      final ok = await net.testConnection(
        url: raw,
        username: userC.text.trim(),
        password: passC.text,
      );
      setState(() {
        conn = ok ? _ConnState.ok : _ConnState.ng;
        connMsg = ok ? 'Connection OK' : 'Connection failed';
      });
      _toast(connMsg!);
    } catch (e) {
      setState(() {
        conn = _ConnState.ng;
        connMsg = 'Connection failed: $e';
      });
      _toast(connMsg!);
    }
  }

  Future<void> _save(List<Plant> all) async {
    FocusScope.of(context).unfocus();
    final name = (nameC.text.trim().isEmpty) ? 'New Plant' : nameC.text.trim();

    // 重複チェック
    final dup = all.any((p) => p.name == name && p.id != widget.plantId);
    if (dup) {
      _toast('Name already exists.');
      return;
    }

    final normalizedUrl = () {
      var raw = urlC.text.trim();
      if (!(raw.startsWith('http://') || raw.startsWith('https://')))
        raw = 'https://$raw';
      return raw;
    }();

    final p = Plant(
      id: widget.plantId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      url: normalizedUrl,
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
    try {
      if (isEdit) {
        n.update(p);
      } else {
        n.add(p);
      }
      _toast('Saved');

      // ★ ここで自動探索を実行 → 成功した取り方を保存
      final res = await _discovery.discoverAndSave(
        plantId: p.id,
        baseUrl: p.url,
        username: p.username,
        password: p.password,
      );
      _toast(res.message);

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
