class LecturaModel {
  final int id;
  final int idZona;
  final double co2;
  final double nox;
  final double pm25;
  final String timestamp;

  LecturaModel({
    required this.id,
    required this.idZona,
    required this.co2,
    required this.nox,
    required this.pm25,
    required this.timestamp,
  });

  factory LecturaModel.fromJson(Map<String, dynamic> json) {
    return LecturaModel(
      id: json['id'] ?? 0,
      idZona: json['id_zona'] ?? 0,
      co2: (json['lectura_de_co2'] as num? ?? 0).toDouble(),
      nox: (json['lectura_de_nox'] as num? ?? 0).toDouble(),
      pm25: (json['lectura_de_pm25'] as num? ?? 0).toDouble(),
      timestamp: json['fecha'] ?? '',
    );
  }
}