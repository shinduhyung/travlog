// lib/models/economy_data_model.dart

class EconomyData {
  final String name; // 국가 전체 이름 필드
  final String isoA3;
  final double gdpNominal;
  final double gdpPpp;
  final double population;
  final String developmentStatus;
  final String? continent;

  EconomyData({
    required this.name, // 생성자에 추가
    required this.isoA3,
    required this.gdpNominal,
    required this.gdpPpp,
    required this.population,
    required this.developmentStatus,
    this.continent,
  });

  factory EconomyData.fromJson(Map<String, dynamic> json) {
    return EconomyData(
      // JSON에 'name' 필드가 없을 경우를 대비해 isoA3를 기본값으로 사용
      name: json['name'] as String? ?? json['iso_a3'] as String,
      isoA3: json['iso_a3'] as String,
      gdpNominal: (json['gdp_nominal'] as num? ?? 0.0).toDouble(),
      gdpPpp: (json['gdp_ppp'] as num? ?? 0.0).toDouble(),
      population: (json['population'] as num? ?? 0.0).toDouble(),
      developmentStatus: json['development_status'] as String? ?? 'N/A',
      continent: json['continent'] as String?,
    );
  }
}