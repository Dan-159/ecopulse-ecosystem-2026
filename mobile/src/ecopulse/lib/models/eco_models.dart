class ReportePromedio {
  final int totalLecturas;
  final double promedioCo2;
  final double promedioNox;
  final double promedioPm25;

  ReportePromedio({
    required this.totalLecturas,
    required this.promedioCo2,
    required this.promedioNox,
    required this.promedioPm25,
  });

  factory ReportePromedio.fromJson(Map<String, dynamic> json) {
    return ReportePromedio(
      totalLecturas: json['total_lecturas'],
      promedioCo2: json['promedio_co2'].toDouble(),
      promedioNox: json['promedio_nox'].toDouble(),
      promedioPm25: json['promedio_pm25'].toDouble(),
    );
  }
}

class ZonaReporte {
  final String nombre;
  final double promedioGeneral;

  ZonaReporte({required this.nombre, required this.promedioGeneral});

  factory ZonaReporte.fromJson(Map<String, dynamic> json) {
    return ZonaReporte(
      nombre: json['zona'],
      promedioGeneral: json['promedio_general'] ?? json['promedio'] ?? 0.0,
    );
  }
}