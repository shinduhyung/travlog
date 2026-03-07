// lib/models/country_info_model.dart

class MajorCityInfo {
  final String name;
  final String population;
  final String description;

  MajorCityInfo({required this.name, required this.population, required this.description});

  factory MajorCityInfo.fromJson(Map<String, dynamic> json) {
    return MajorCityInfo(
      name: json['name'] as String? ?? 'N/A',
      population: json['population'] as String? ?? 'N/A',
      description: json['description'] as String? ?? 'N/A',
    );
  }
}

class CountryInfo {
  final String capital;
  final String officialLanguage;
  final String currency;
  final List<MajorCityInfo> majorCities;
  final List<String> topAttractions;
  final List<String> history; // Country History
  final List<String> cultureHighlights;
  final List<String> transportation;
  final List<String> goodToKnow;
  final int safetyLevel;

  CountryInfo({
    required this.capital,
    required this.officialLanguage,
    required this.currency,
    required this.majorCities,
    required this.topAttractions,
    required this.history,
    required this.cultureHighlights,
    required this.transportation,
    required this.goodToKnow,
    required this.safetyLevel,
  });

  factory CountryInfo.fromJson(Map<String, dynamic> json) {
    return CountryInfo(
      capital: json['capital'] as String? ?? 'N/A',
      officialLanguage: json['officialLanguage'] as String? ?? 'N/A',
      currency: json['currency'] as String? ?? 'N/A',
      majorCities: (json['majorCities'] as List<dynamic>?)
          ?.map((e) => MajorCityInfo.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      topAttractions: List<String>.from(json['topAttractions'] as List<dynamic>? ?? []),
      history: List<String>.from(json['history'] as List<dynamic>? ?? []),
      cultureHighlights: List<String>.from(json['cultureHighlights'] as List<dynamic>? ?? []),
      transportation: List<String>.from(json['transportation'] as List<dynamic>? ?? []),
      goodToKnow: List<String>.from(json['goodToKnow'] as List<dynamic>? ?? []),
      safetyLevel: json['safetyLevel'] as int? ?? 0, // 0: Unknown
    );
  }
}