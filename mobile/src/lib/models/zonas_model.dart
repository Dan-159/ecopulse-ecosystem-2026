class Zona {
  final String zona;
  final double promedioGeneral;

  Zona({required this.zona, required this.promedioGeneral});

  factory Zona.fromJson(Map<String, dynamic> json) {
    return Zona(
      zona: json['zona'],
      promedioGeneral: (json['promedio_general'] as num).toDouble(),
    );
  }
}
