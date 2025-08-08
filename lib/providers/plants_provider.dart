// 追加時
void add({ required String name, required String siteUrl, Color theme = const Color(0xFF1E88E5), }) {
  final now = DateTime.now();
  final r = Random();
  final latest = 100 + r.nextInt(300);
  final maxToday = latest + r.nextInt(120);
  final p = Plant(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    name: name,
    siteUrl: siteUrl,
    theme: theme,                 // ← ここを Color のまま
    latestKw: latest.toDouble(),
    todayMaxKw: maxToday.toDouble(),
    updatedAt: now,
  );
  state = [...state, p];
}

// モック
return List.generate(6, (i) {
  final latest = 120 + rnd.nextInt(220);
  final maxToday = latest + rnd.nextInt(120);
  return Plant(
    id: 'plant_$i',
    name: 'Plant ${i + 1}',
    siteUrl: 'https://example.com/plant/${i + 1}',
    theme: colors[i % colors.length],   // ← 文字列ではなく Color
    latestKw: latest.toDouble(),
    todayMaxKw: maxToday.toDouble(),
    updatedAt: now.subtract(Duration(minutes: rnd.nextInt(120))),
  );
});
