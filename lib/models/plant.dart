class Plant {
  final String id;
  final String name;
  final Uri url;
  final int color;

  const Plant({
    required this.id,
    required this.name,
    required this.url,
    required this.color,
  });

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
