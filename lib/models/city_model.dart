// lib/models/city_model.dart

// 수도 상태를 나타내는 enum
enum CapitalStatus {
  none,
  capital,
  territory
}

// 헬퍼 함수들
int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

String _parseString(dynamic value) {
  return value?.toString() ?? '';
}

CapitalStatus _parseCapitalStatus(dynamic value) {
  if (value == null) return CapitalStatus.none;
  if (value is bool) {
    return value ? CapitalStatus.capital : CapitalStatus.none;
  }
  if (value is String && value.toLowerCase() == 'territory') {
    return CapitalStatus.territory;
  }
  return CapitalStatus.none;
}

double _parseTrafficTimeToMinutes(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();

  if (value is String) {
    double totalMinutes = 0.0;
    int hours = 0;
    int minutes = 0;
    int seconds = 0;

    RegExp hPattern = RegExp(r'(\d+)\s*h');
    RegExp minPattern = RegExp(r'(\d+)\s*min');
    RegExp sPattern = RegExp(r'(\d+)\s*s');

    Match? hMatch = hPattern.firstMatch(value);
    if (hMatch != null) hours = int.parse(hMatch.group(1)!);

    Match? minMatch = minPattern.firstMatch(value);
    if (minMatch != null) minutes = int.parse(minMatch.group(1)!);

    Match? sMatch = sPattern.firstMatch(value);
    if (sMatch != null) seconds = int.parse(sMatch.group(1)!);

    totalMinutes = (hours * 60 + minutes + seconds / 60.0);
    return totalMinutes;
  }
  return 0.0;
}

class City {
  // 기본 정보 (cities15000.json & cities.json 공통)
  final String name;
  final String country;
  final String countryIsoA2;
  final String continent;
  final int population;
  final double latitude;
  final double longitude;
  final CapitalStatus capitalStatus;

  // 상세 통계 정보 (cities.json 전용, 없으면 0)
  final int annualVisitors;
  final double avgTemp;
  final int avgPrecipitation;
  final int altitude;
  final double gdpNominal;
  final double gdpPpp;
  final int starbucksCount;
  final int millionaires;
  final int billionaires;
  final double cityTouristRatio;
  final int stationsCount;
  final double studentScore;
  final double safetyScore;
  final double liveabilityScore;
  final int surveillanceCameraCount;
  final int skyscraperCount;
  final double pollutionScore;
  final double homicideRate;
  final double trafficTimeMinutes;
  final double hollywoodScore;
  final String gawcTier;

  City({
    required this.name,
    required this.country,
    required this.countryIsoA2,
    required this.continent,
    required this.population,
    required this.latitude,
    required this.longitude,
    this.capitalStatus = CapitalStatus.none, // 기본값 설정
    this.annualVisitors = 0,
    this.avgTemp = 0.0,
    this.avgPrecipitation = 0,
    this.altitude = 0,
    this.gdpNominal = 0.0,
    this.gdpPpp = 0.0,
    this.starbucksCount = 0,
    this.millionaires = 0,
    this.billionaires = 0,
    this.cityTouristRatio = 0.0,
    this.stationsCount = 0,
    this.studentScore = 0.0,
    this.safetyScore = 0.0,
    this.liveabilityScore = 0.0,
    this.surveillanceCameraCount = 0,
    this.skyscraperCount = 0,
    this.pollutionScore = 0.0,
    this.homicideRate = 0.0,
    this.trafficTimeMinutes = 0.0,
    this.hollywoodScore = 0.0,
    this.gawcTier = 'N/A',
  });

  // cities.json (상세 데이터) 파싱용 팩토리
  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: _parseString(json['name'] ?? json['city']),
      country: _parseString(json['country']),
      countryIsoA2: _parseString(json['country_iso'] ?? ''),
      continent: _parseString(json['continent'] ?? ''),
      population: _parseInt(json['population']),
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      capitalStatus: _parseCapitalStatus(json['isCapital']),
      annualVisitors: _parseInt(json['annualVisitors']),
      avgTemp: _parseDouble(json['avgTemp']),
      avgPrecipitation: _parseInt(json['avgPrecipitation']),
      altitude: _parseInt(json['altitude'] ?? json['age']),
      gdpNominal: _parseDouble(json['gdp_nominal']),
      gdpPpp: _parseDouble(json['gdp_ppp']),
      starbucksCount: _parseInt(json['Starbucks']),
      millionaires: _parseInt(json['Millionaires']),
      billionaires: _parseInt(json['Billionaires']),
      cityTouristRatio: _parseDouble(json['city_tour_ratio'] ?? json['city_tourist_ratio']),
      stationsCount: _parseInt(json['stations']),
      studentScore: _parseDouble(json['student']),
      safetyScore: _parseDouble(json['safety'] ?? json['index']),
      liveabilityScore: _parseDouble(json['liveability'] ?? json['index']),
      surveillanceCameraCount: _parseDouble(json['surveillance'] ?? json['cameras']).round(),
      skyscraperCount: _parseInt(json['skyscraper'] ?? json['skyscrapers']),
      pollutionScore: _parseDouble(json['pollution']),
      homicideRate: _parseDouble(json['homicide']),
      trafficTimeMinutes: _parseTrafficTimeToMinutes(json['traffic']),
      hollywoodScore: _parseDouble(json['hollywood']),
      gawcTier: _parseString(json['tier']),
    );
  }

  // cities15000.json (지도용 데이터) 파싱용 팩토리
  // 상세 데이터가 없으므로 대부분 0으로 초기화하고 위치 정보만 사용
  factory City.fromMapJson(Map<String, dynamic> json, Map<String, String> continentMap) {
    String iso = _parseString(json['country_code'] ?? json['iso_a2']);
    return City(
      name: _parseString(json['name']), // 이름
      country: _parseString(json['country'] ?? 'Unknown'), // cities15000에는 country 필드가 없을 수 있음
      countryIsoA2: iso,
      continent: _parseString(json['continent']) == '' ? (continentMap[iso] ?? 'Unknown') : _parseString(json['continent']),
      population: _parseInt(json['population']), // 인구
      latitude: _parseDouble(json['latitude']), // 위도
      longitude: _parseDouble(json['longitude']), // 경도
      capitalStatus: CapitalStatus.none, // 기본값
      // 나머지는 기본값(0) 사용
    );
  }
}