import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../providers/notification_settings_provider.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(notificationSettingsProvider);
    final n = ref.read(notificationSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      backgroundColor: const Color(0xFFF6F7FB),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _Card(
            title: 'Regular Updates',
            subtitle: 'At a specified time each day',
            trailing: Switch(value: s.dailySummary, onChanged: n.toggleDaily),
            child:
                s.dailySummary
                    ? _TimeChips(
                      times: s.times,
                      onAdd: (t) => n.addTime(t),
                      onRemove: (i) => n.removeTime(i),
                    )
                    : null,
          ),
          _Card(
            title: 'Alert Notifications',
            subtitle: 'When generation is below threshold',
            trailing: Switch(
              value: s.abnormalAlert,
              onChanged: n.toggleAbnormal,
            ),
            child:
                s.abnormalAlert
                    ? _NumberField(
                      hint: '50 kW',
                      initial:
                          s.thresholdKw == 0
                              ? ''
                              : s.thresholdKw.toStringAsFixed(0),
                      onChanged: (v) => n.setThreshold(double.tryParse(v) ?? 0),
                    )
                    : null,
          ),
          _Card(
            title: 'Peak Generation',
            subtitle: 'When new peak value is reached',
            trailing: Switch(value: s.maxUpdate, onChanged: n.toggleMaxUpdate),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? child;
  const _Card({required this.title, this.subtitle, this.trailing, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTok.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          subtitle!,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (child != null)
            Padding(padding: const EdgeInsets.only(top: 12), child: child!),
        ],
      ),
    );
  }
}

class _TimeChips extends StatelessWidget {
  final List<TimeOfDay> times;
  final void Function(TimeOfDay) onAdd;
  final void Function(int) onRemove;
  const _TimeChips({
    required this.times,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (int i = 0; i < times.length; i++)
          Chip(
            label: Text(times[i].format(context)),
            onDeleted: () => onRemove(i),
          ),
        ActionChip(
          label: const Text('Add time'),
          onPressed: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (picked != null) onAdd(picked);
          },
        ),
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  final String hint;
  final String initial;
  final ValueChanged<String> onChanged;
  const _NumberField({
    required this.hint,
    required this.initial,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initial);
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF6F7FB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
