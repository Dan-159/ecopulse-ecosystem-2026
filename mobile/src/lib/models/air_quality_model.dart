class AirQualityModel {
  final double pm25;
  final double co2;
  final double nox;
  final String location;

  AirQualityModel({
    required this.pm25,
    required this.co2,
    required this.nox,
    required this.location,
  });

  // Este método convierte el JSON de la nube a nuestro objeto Dart
  factory AirQualityModel.fromJson(Map<String, dynamic> json) {
    return AirQualityModel(
      pm25: (json['pm25'] ?? 0).toDouble(),
      co2: (json['co2'] ?? 0).toDouble(),
      nox: (json['nox'] ?? 0).toDouble(),
      location: json['location'] ?? 'Desconocida',
    );
  }

  // Lógica simple para determinar el estado general
  String get status {
    if (pm25 > 50 || co2 > 1000 || nox > 100) return 'Crítico';
    if (pm25 > 25 || co2 > 800 || nox > 50) return 'Moderado';
    return 'Bueno';
  }
}
