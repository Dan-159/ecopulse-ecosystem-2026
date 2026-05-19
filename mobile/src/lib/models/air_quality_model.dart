class AirQualityModel {
  
  final int totaLecturas;
  final double pm25;
  final double co2;
  final double nox;

  AirQualityModel({
    required this.totaLecturas,
    required this.pm25,
    required this.co2,
    required this.nox,
  });

  factory AirQualityModel.fromJson(Map<String, dynamic> json) {
    return AirQualityModel(
      totaLecturas: (json['total_lecturas'] ?? 0).toInt(),
      co2: (json['promedio_co2'] ?? 0).toDouble(),
      nox: (json['promedio_nox'] ?? 0).toDouble(),
      pm25: (json['promedio_pm25'] ?? 0).toDouble(),
      );
  }

  // Lógica simple para determinar el estado general
  String get status {
    if (pm25 > 50 || co2 > 1000 || nox > 100) return 'Crítico';
    if (pm25 > 25 || co2 > 800 || nox > 50) return 'Moderado';
    return 'Bueno';
  }
}
