class LecturaModel {
  final int id;
  final double pm25;
  final double co2;
  final double nox;
  final String timestamp;
  final int sensorId;
  final double valor;

  LecturaModel({
    required this.id,
    required this.pm25,
    required this.co2,
    required this.nox,
    required this.timestamp,
    required this.sensorId,
    required this.valor,
  });

  // Constructor para transformar el JSON real de tu lecturas_router
  factory LecturaModel.fromJson(Map<String, dynamic> json) {
    return LecturaModel(
      id: json["id"] ?? 0,
      pm25: (json['pm25'] as num? ?? 0.0).toDouble(),
      co2: (json['co2'] as num? ?? 0.0).toDouble(),
      nox: (json['nox'] as num? ?? 0.0).toDouble(),
      timestamp: json['fecha'] ?? '',
      sensorId: json['id_zona_sensor'] ?? 0,
      valor: json['valor'] ?? 0,
    );
  }
  // Deteccion de la calidad
  String get status {
    if (valor>=60) return 'Crítico';
    if (valor>= 40) return 'Moderado';
    return 'Bueno';
  }
}