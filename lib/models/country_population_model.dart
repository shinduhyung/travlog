// lib/models/country_population_model.dart

class CountryPopulation {
  // ✅ 변경: isoA2를 isoA3로 변경
  final String isoA3;
  final int populationEst;

  CountryPopulation({
    // ✅ 변경: isoA2를 isoA3로 변경
    required this.isoA3,
    required this.populationEst,
  });

  factory CountryPopulation.fromJson(Map<String, dynamic> json) {
    return CountryPopulation(
      // ✅ 변경: JSON 필드 'iso_a2'를 'iso_a3'로 변경
      isoA3: json['iso_a3'] as String,
      populationEst: (json['population_est'] as num).toInt(),
    );
  }
}