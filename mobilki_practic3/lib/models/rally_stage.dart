class RallyStage {
  const RallyStage({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });
  final String id, name;
  final double latitude, longitude;
  static double? coordinate(String text, {required bool latitude}) {
    final n = double.tryParse(text.trim().replaceAll(',', '.'));
    return n != null && n.isFinite && n.abs() <= (latitude ? 90 : 180)
        ? n
        : null;
  }

  static bool validName(String text) => text.trim().isNotEmpty;
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'lat': latitude,
    'lon': longitude,
  };
  factory RallyStage.fromJson(Map<String, dynamic> j) {
    final lat = coordinate('${j['lat']}', latitude: true),
        lon = coordinate('${j['lon']}', latitude: false);
    if (j['id'] is! String ||
        j['name'] is! String ||
        !validName(j['name']) ||
        lat == null ||
        lon == null) {
      throw const FormatException('Некорректный участок');
    }
    return RallyStage(
      id: j['id'],
      name: j['name'],
      latitude: lat,
      longitude: lon,
    );
  }
  String get coordinates =>
      '${latitude.toStringAsFixed(4)}°, ${longitude.toStringAsFixed(4)}°';
  String get cacheKey => '$latitude,$longitude';
}
