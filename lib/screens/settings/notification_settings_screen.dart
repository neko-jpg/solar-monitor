import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/notification_settings_provider.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: settings.enabled,
            onChanged: notifier.toggle,
          ),
          ListTile(
            title: const Text('Warn if no update for (minutes)'),
            trailing: Text('${settings.staleMinutes}'),
            onTap: () async {
              final v = await _pickInt(context, settings.staleMinutes, 5, 240, step: 5);
              if (v != null) notifier.setStaleMinutes(v);
            },
          ),
          ListTile(
            title: const Text('Low power threshold (kW)'),
            trailing: Text(settings.lowPowerKw.toStringAsFixed(1)),
            onTap: () async {
              final v = await _pickDouble(context, settings.lowPowerKw, 0, 10, step: 0.1);
              if (v != null) notifier.setLowPower(v);
            },
          ),
        ],
      ),
    );
  }

  Future<int?> _pickInt(BuildContext ctx, int init, int min, int max, {int step = 1}) async {
    int cur = init;
    return showDialog<int>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Set minute threshold'),
        content: StatefulBuilder(
          builder: (_, set) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(icon: const Icon(Icons.remove), onPressed: () => set(() => cur = (cur - step).clamp(min, max))),
              Text('$cur', style: Theme.of(ctx).textTheme.titleLarge),
              IconButton(icon: const Icon(Icons.add), onPressed: () => set(() => cur = (cur + step).clamp(min, max))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, cur), child: const Text('OK')),
        ],
      ),
    );
  }

  Future<double?> _pickDouble(BuildContext ctx, double init, double min, double max, {double step = 0.1}) async {
    double cur = init;
    return showDialog<double>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Set kW threshold'),
        content: StatefulBuilder(
          builder: (_, set) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(icon: const Icon(Icons.remove), onPressed: () => set(() => cur = (cur - step).clamp(min, max))),
              Text(cur.toStringAsFixed(1), style: Theme.of(ctx).textTheme.titleLarge),
              IconButton(icon: const Icon(Icons.add), onPressed: () => set(() => cur = (cur + step).clamp(min, max))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, cur), child: const Text('OK')),
        ],
      ),
    );
  }
}
