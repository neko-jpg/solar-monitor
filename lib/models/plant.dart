class Plant {
  final String id; // uuid
  final String name;
  final Uri url; // 旧 endpoint→url に統一
  final int color; // ARGB int
  const Plant({required this.id, required this.name, required this.url, required this.color});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'url': url.toString(),
    'color': color,
  };
  static Plant fromJson(Map<String, dynamic> json) => Plant(
    id: json['id'] as String,
    name: json['name'] as String,
    url: Uri.parse(json['url'] as String),
    color: json['color'] as int,
  );
}
