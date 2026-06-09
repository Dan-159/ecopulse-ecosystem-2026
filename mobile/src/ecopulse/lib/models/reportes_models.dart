class ReportePromedioGeneral {
  final int totalLecturas;
  final double promedioCo2;
  final double promedioNox;
  final double promedioPm25;
  final double indiceGlobal;

  ReportePromedioGeneral({
    required this.totalLecturas,
    required this.promedioCo2,
    required this.promedioNox,
    required this.promedioPm25,
    required this.indiceGlobal,
  });

  factory ReportePromedioGeneral.fromJson(Map<String, dynamic> json) {
    return ReportePromedioGeneral(
      totalLecturas: json['total_lecturas'] ?? 0,
      promedioCo2: (json['promedio_co2'] ?? 0.0).toDouble(),
      promedioNox: (json['promedio_nox'] ?? 0.0).toDouble(),
      promedioPm25: (json['promedio_pm25'] ?? 0.0).toDouble(),
      indiceGlobal: (json['indice_global'] ?? 0.0).toDouble(),
    );
  }
}

class ZonaMasContaminada {
  final int idZona;
  final String nombre;
  final double indice;

  ZonaMasContaminada({required this.idZona, required this.nombre, required this.indice});

  factory ZonaMasContaminada.fromJson(Map<String, dynamic> json) {
    return ZonaMasContaminada(
      idZona: json['id_zona'] ?? 'Sin ID',
      nombre: json['nombre_zona'] ?? 'Sin nombre',
      indice: (json['indice'] ?? 0.0).toDouble(),
    );
  }
}