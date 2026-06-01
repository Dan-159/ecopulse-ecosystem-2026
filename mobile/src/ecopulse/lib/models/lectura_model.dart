class LecturaModel {
  final int id;
  final double pm25;
  final double co2;
  final double nox;
  final String timestamp;
  final int sensorId;
  final double valor; // Métrica principal utilizada para evaluar el semáforo

  LecturaModel({
    required this.id,
    required this.pm25,
    required this.co2,
    required this.nox,
    required this.timestamp,
    required this.sensorId,
    required this.valor,
  });

  //Extrae los campos de json
  factory LecturaModel.fromJson(Map<String, dynamic> json) {
    final String tipo = (json['tipo_lectura'] ?? '').toString().toLowerCase();
    final double valorNumerico = (json['valor'] as num? ?? 0.0).toDouble();

    return LecturaModel(
      id: json['id'] ?? 0,
      pm25: (tipo == 'pm25' || tipo == 'pm2.5') ? valorNumerico : 0.0,
      co2: (tipo == 'co2') ? valorNumerico : 0.0,
      nox: (tipo == 'nox') ? valorNumerico : 0.0,
      timestamp: json['fecha'] ?? json['timestamp'] ?? '',
      sensorId: json['id_zona_sensor'] ?? json['sensor_id'] ?? 0,
      valor: valorNumerico,
    );
  }
  String get status {
    if (valor >= 60.0) return 'Crítico';
    if (valor >= 40.0) return 'Moderado';
    return 'Bueno';
  }
}