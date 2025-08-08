import 'package:flutter/material.dart';

class NotificationSettingScreen extends StatefulWidget {
  const NotificationSettingScreen({super.key});

  @override
  State<NotificationSettingScreen> createState() => _NotificationSettingScreenState();
}

class _NotificationSettingScreenState extends State<NotificationSettingScreen> {
  bool dailySummary = false;
  List<TimeOfDay> summaryTimes = [];
  bool abnormalAlert = false;
  double threshold = 0;
  bool maxUpdate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Daily summary'),
            value: dailySummary,
            onChanged: (v) => setState(() => dailySummary = v),
          ),
          if (dailySummary)
            Column(
              children: [
                for (var t in summaryTimes)
                  ListTile(
                    title: Text(t.format(context)),
                  ),
                TextButton(
                  onPressed: () async {
                    final now = TimeOfDay.now();
                    final picked = await showTimePicker(context: context, initialTime: now);
                    if (picked != null) {
                      setState(() => summaryTimes.add(picked));
                    }
                  },
                  child: const Text('Add time'),
                ),
              ],
            ),
          const Divider(),
          SwitchListTile(
            title: const Text('Abnormal output alert'),
            value: abnormalAlert,
            onChanged: (v) => setState(() => abnormalAlert = v),
          ),
          if (abnormalAlert)
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Threshold kW'),
              onChanged: (v) => threshold = double.tryParse(v) ?? 0,
            ),
          const Divider(),
          SwitchListTile(
            title: const Text('All-time max update'),
            value: maxUpdate,
            onChanged: (v) => setState(() => maxUpdate = v),
          ),
        ],
      ),
    );
  }
}
