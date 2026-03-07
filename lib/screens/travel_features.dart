// lib/travel_persona/travel_features.dart

import 'dart:math';

/// 10가지 여행 성향 타입h
enum TravelPersonaType {
  identitySeeker,
  sensoryImmersionist,
  efficiencyMaximizer,
  culturalDecoder,
  joyCollector,
  innerSanctuarySeeker,
  wildlifeEarthEnthusiast,
  globalConnector,
  freedomDrifter,
  achievementHunter,
}

/// Gemini가 뱉어주는 31개의 축을 담는 데이터 모델
/// (전부 -1.0 ~ 1.0 범위 안의 값이라고 가정)
class TravelFeatures {
  // --- Distribution (5) — 반드시 -1, 0, 1 중 하나로만 사용
  final double continentDistribution;
  final double countryDistribution;
  final double cityDistribution;
  final double airportDistribution;
  final double airlineDistribution;

  // --- Country / City traits (6)
  final double countryWealth;
  final double cityWealth;
  final double countryType;      // -1 = 자연 중심, +1 = 인간/도시/문화유산 중심
  final double cityType;         // -1 = 자연 중심 도시, +1 = 인공/도시 중심
  final double countryNightlife; // -1 = 조용, +1 = 밤문화 강함
  final double cityNightlife;

  // --- Flight / Transfer (3)
  final double airlineTime;           // -1 = 짧은 비행 위주, +1 = 장거리 위주
  final double transferAirportScore;  // 공항 기준 환승 성향
  final double transferFlightScore;   // 비행편 기준 환승 성향

  // --- Landmark 10축 (10)
  final double landmarkCultureNature;
  final double landmarkAncientModern;
  final double landmarkUrbanRural;
  final double landmarkAdventureRelax;
  final double landmarkArtScience;
  final double landmarkSpiritualSecular;
  final double landmarkCrowd;
  final double landmarkBudgetLuxury;
  final double landmarkLocalTourist;
  final double landmarkCalmNightlife;

  // --- Personality 8축 (다른 Provider에서 온 값 + 약간 조정된 값)
  final double soloSocial;
  final double relaxedIntense;
  final double plannedSpontaneous;
  final double urbanNature;
  final double cultureFun;
  final double personalityBudgetLuxury;
  final double morningNight;
  final double documenterLive;

  const TravelFeatures({
    // Distribution
    required this.continentDistribution,
    required this.countryDistribution,
    required this.cityDistribution,
    required this.airportDistribution,
    required this.airlineDistribution,
    // Country/City
    required this.countryWealth,
    required this.cityWealth,
    required this.countryType,
    required this.cityType,
    required this.countryNightlife,
    required this.cityNightlife,
    // Flight
    required this.airlineTime,
    required this.transferAirportScore,
    required this.transferFlightScore,
    // Landmark
    required this.landmarkCultureNature,
    required this.landmarkAncientModern,
    required this.landmarkUrbanRural,
    required this.landmarkAdventureRelax,
    required this.landmarkArtScience,
    required this.landmarkSpiritualSecular,
    required this.landmarkCrowd,
    required this.landmarkBudgetLuxury,
    required this.landmarkLocalTourist,
    required this.landmarkCalmNightlife,
    // Personality
    required this.soloSocial,
    required this.relaxedIntense,
    required this.plannedSpontaneous,
    required this.urbanNature,
    required this.cultureFun,
    required this.personalityBudgetLuxury,
    required this.morningNight,
    required this.documenterLive,
  });

  /// 계산용 벡터로 변환 (코사인 유사도 계산에 사용)
  List<double> toVector() {
    return [
      // Distribution (5)
      continentDistribution,
      countryDistribution,
      cityDistribution,
      airportDistribution,
      airlineDistribution,
      // Country/City (6)
      countryWealth,
      cityWealth,
      countryType,
      cityType,
      countryNightlife,
      cityNightlife,
      // Flight (3)
      airlineTime,
      transferAirportScore,
      transferFlightScore,
      // Landmark (10)
      landmarkCultureNature,
      landmarkAncientModern,
      landmarkUrbanRural,
      landmarkAdventureRelax,
      landmarkArtScience,
      landmarkSpiritualSecular,
      landmarkCrowd,
      landmarkBudgetLuxury,
      landmarkLocalTourist,
      landmarkCalmNightlife,
      // Personality (8)
      soloSocial,
      relaxedIntense,
      plannedSpontaneous,
      urbanNature,
      cultureFun,
      personalityBudgetLuxury,
      morningNight,
      documenterLive,
    ];
  }

  /// Gemini가 준 JSON을 이 모델로 변환하는 팩토리
  factory TravelFeatures.fromJson(Map<String, dynamic> json) {
    double d(String key) => (json[key] ?? 0.0).toDouble();

    return TravelFeatures(
      continentDistribution: d('continentDistribution'),
      countryDistribution: d('countryDistribution'),
      cityDistribution: d('cityDistribution'),
      airportDistribution: d('airportDistribution'),
      airlineDistribution: d('airlineDistribution'),
      countryWealth: d('countryWealth'),
      cityWealth: d('cityWealth'),
      countryType: d('countryType'),
      cityType: d('cityType'),
      countryNightlife: d('countryNightlife'),
      cityNightlife: d('cityNightlife'),
      airlineTime: d('airlineTime'),
      transferAirportScore: d('transferAirportScore'),
      transferFlightScore: d('transferFlightScore'),
      landmarkCultureNature: d('landmark_culture_nature'),
      landmarkAncientModern: d('landmark_ancient_modern'),
      landmarkUrbanRural: d('landmark_urban_rural'),
      landmarkAdventureRelax: d('landmark_adventure_relax'),
      landmarkArtScience: d('landmark_art_science'),
      landmarkSpiritualSecular: d('landmark_spiritual_secular'),
      landmarkCrowd: d('landmark_crowd'),
      landmarkBudgetLuxury: d('landmark_budget_luxury'),
      landmarkLocalTourist: d('landmark_local_tourist'),
      landmarkCalmNightlife: d('landmark_calm_nightlife'),
      soloSocial: d('solo_social'),
      relaxedIntense: d('relaxed_intense'),
      plannedSpontaneous: d('planned_spontaneous'),
      urbanNature: d('urban_nature'),
      cultureFun: d('culture_fun'),
      personalityBudgetLuxury: d('personality_budget_luxury'),
      morningNight: d('morning_night'),
      documenterLive: d('documenter_live'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'continentDistribution': continentDistribution,
      'countryDistribution': countryDistribution,
      'cityDistribution': cityDistribution,
      'airportDistribution': airportDistribution,
      'airlineDistribution': airlineDistribution,
      'countryWealth': countryWealth,
      'cityWealth': cityWealth,
      'countryType': countryType,
      'cityType': cityType,
      'countryNightlife': countryNightlife,
      'cityNightlife': cityNightlife,
      'airlineTime': airlineTime,
      'transferAirportScore': transferAirportScore,
      'transferFlightScore': transferFlightScore,
      'landmark_culture_nature': landmarkCultureNature,
      'landmark_ancient_modern': landmarkAncientModern,
      'landmark_urban_rural': landmarkUrbanRural,
      'landmark_adventure_relax': landmarkAdventureRelax,
      'landmark_art_science': landmarkArtScience,
      'landmark_spiritual_secular': landmarkSpiritualSecular,
      'landmark_crowd': landmarkCrowd,
      'landmark_budget_luxury': landmarkBudgetLuxury,
      'landmark_local_tourist': landmarkLocalTourist,
      'landmark_calm_nightlife': landmarkCalmNightlife,
      'solo_social': soloSocial,
      'relaxed_intense': relaxedIntense,
      'planned_spontaneous': plannedSpontaneous,
      'urban_nature': urbanNature,
      'culture_fun': cultureFun,
      'personality_budget_luxury': personalityBudgetLuxury,
      'morning_night': morningNight,
      'documenter_live': documenterLive,
    };
  }
}

/// 프로토타입(예상값) 하나
class PersonaPrototype {
  final TravelPersonaType type;
  final TravelFeatures expected;

  const PersonaPrototype({
    required this.type,
    required this.expected,
  });
}

/// 기본 0벡터에서 중요한 축만 값 넣는 헬퍼
TravelFeatures baseFeatures({
  double continentDistribution = 0,
  double countryDistribution = 0,
  double cityDistribution = 0,
  double airportDistribution = 0,
  double airlineDistribution = 0,
  double countryWealth = 0,
  double cityWealth = 0,
  double countryType = 0,
  double cityType = 0,
  double countryNightlife = 0,
  double cityNightlife = 0,
  double airlineTime = 0,
  double transferAirportScore = 0,
  double transferFlightScore = 0,
  double landmarkCultureNature = 0,
  double landmarkAncientModern = 0,
  double landmarkUrbanRural = 0,
  double landmarkAdventureRelax = 0,
  double landmarkArtScience = 0,
  double landmarkSpiritualSecular = 0,
  double landmarkCrowd = 0,
  double landmarkBudgetLuxury = 0,
  double landmarkLocalTourist = 0,
  double landmarkCalmNightlife = 0,
  double soloSocial = 0,
  double relaxedIntense = 0,
  double plannedSpontaneous = 0,
  double urbanNature = 0,
  double cultureFun = 0,
  double personalityBudgetLuxury = 0,
  double morningNight = 0,
  double documenterLive = 0,
}) {
  return TravelFeatures(
    continentDistribution: continentDistribution,
    countryDistribution: countryDistribution,
    cityDistribution: cityDistribution,
    airportDistribution: airportDistribution,
    airlineDistribution: airlineDistribution,
    countryWealth: countryWealth,
    cityWealth: cityWealth,
    countryType: countryType,
    cityType: cityType,
    countryNightlife: countryNightlife,
    cityNightlife: cityNightlife,
    airlineTime: airlineTime,
    transferAirportScore: transferAirportScore,
    transferFlightScore: transferFlightScore,
    landmarkCultureNature: landmarkCultureNature,
    landmarkAncientModern: landmarkAncientModern,
    landmarkUrbanRural: landmarkUrbanRural,
    landmarkAdventureRelax: landmarkAdventureRelax,
    landmarkArtScience: landmarkArtScience,
    landmarkSpiritualSecular: landmarkSpiritualSecular,
    landmarkCrowd: landmarkCrowd,
    landmarkBudgetLuxury: landmarkBudgetLuxury,
    landmarkLocalTourist: landmarkLocalTourist,
    landmarkCalmNightlife: landmarkCalmNightlife,
    soloSocial: soloSocial,
    relaxedIntense: relaxedIntense,
    plannedSpontaneous: plannedSpontaneous,
    urbanNature: urbanNature,
    cultureFun: cultureFun,
    personalityBudgetLuxury: personalityBudgetLuxury,
    morningNight: morningNight,
    documenterLive: documenterLive,
  );
}

/// 10개 유형의 "이상적인 프로필" 정의
/// (여기 숫자들은 나중에 얼마든지 미세 조정 가능)
final List<PersonaPrototype> personaPrototypes = [
  PersonaPrototype(
    type: TravelPersonaType.identitySeeker,
    expected: baseFeatures(
      documenterLive: -0.8,           // 기록 강함
      landmarkSpiritualSecular: -0.3, // 영성/내면 쪽
      landmarkCalmNightlife: -0.5,    // 조용한 환경
      soloSocial: -0.2,               // 살짝 솔로 성향
      relaxedIntense: -0.2,
    ),
  ),
  PersonaPrototype(
    type: TravelPersonaType.sensoryImmersionist,
    expected: baseFeatures(
      relaxedIntense: -0.7,           // 여유
      landmarkAdventureRelax: -0.4,   // 느긋한 관람
      cityDistribution: -0.3,         // 몇 도시에서 오래 머무름
      airlineTime: -0.3,              // 짧은 이동
    ),
  ),
  PersonaPrototype(
    type: TravelPersonaType.efficiencyMaximizer,
    expected: baseFeatures(
      relaxedIntense: 0.8,
      plannedSpontaneous: -0.7,
      countryDistribution: 0.6,
      cityDistribution: 0.5,
      transferFlightScore: 0.4,
    ),
  ),
  PersonaPrototype(
    type: TravelPersonaType.culturalDecoder,
    expected: baseFeatures(
      cultureFun: -0.8,               // 문화/역사
      landmarkCultureNature: 0.7,     // 문화 유산
      landmarkArtScience: -0.6,       // 예술/인문
      countryType: 0.4,               // 도시/유적 국가
    ),
  ),
  PersonaPrototype(
    type: TravelPersonaType.joyCollector,
    expected: baseFeatures(
      cultureFun: 0.7,                // 엔터/맛집
      urbanNature: 0.6,               // 도시
      countryNightlife: 0.5,
      landmarkLocalTourist: 0.7,
      landmarkCalmNightlife: 0.4,
    ),
  ),
  PersonaPrototype(
    type: TravelPersonaType.innerSanctuarySeeker,
    expected: baseFeatures(
      relaxedIntense: -0.8,
      urbanNature: -0.6,
      landmarkCalmNightlife: -0.7,
      landmarkCultureNature: -0.3,
    ),
  ),
  PersonaPrototype(
    type: TravelPersonaType.wildlifeEarthEnthusiast,
    expected: baseFeatures(
      urbanNature: -0.8,
      landmarkCultureNature: -0.8,
      landmarkArtScience: 0.3,        // 과학/지구 쪽
      countryType: -0.5,
    ),
  ),
  PersonaPrototype(
    type: TravelPersonaType.globalConnector,
    expected: baseFeatures(
      soloSocial: 0.8,
      cityDistribution: 0.5,
      countryDistribution: 0.4,
      landmarkLocalTourist: 0.3,
      landmarkCrowd: 0.5,
    ),
  ),
  PersonaPrototype(
    type: TravelPersonaType.freedomDrifter,
    expected: baseFeatures(
      plannedSpontaneous: 0.8,
      relaxedIntense: -0.4,
      countryDistribution: -0.3,      // 몇 국가에 오래
      airlineTime: 0.3,
    ),
  ),
  PersonaPrototype(
    type: TravelPersonaType.achievementHunter,
    expected: baseFeatures(
      relaxedIntense: 0.7,
      documenterLive: -0.5,
      countryDistribution: 0.7,
      cityDistribution: 0.7,
      landmarkLocalTourist: 0.5,
    ),
  ),
];

/// 코사인 유사도
double cosineSimilarity(List<double> a, List<double> b) {
  assert(a.length == b.length);
  double dot = 0;
  double normA = 0;
  double normB = 0;
  for (var i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
    normA += a[i] * a[i];
    normB += b[i] * b[i];
  }
  if (normA == 0 || normB == 0) return 0.0;
  return dot / (sqrt(normA) * sqrt(normB));
}

/// 코사인 유사도들을 softmax-like 확률로 변환
Map<TravelPersonaType, double> similarityToProbabilities(
    Map<TravelPersonaType, double> sims,
    ) {
  // 음수 유사도 있을 수 있으니 전체 shift
  final minSim = sims.values.fold<double>(1e9, min);
  final shifted = sims.map((k, v) => MapEntry(k, v - minSim)); // 모두 >= 0

  final expMap = shifted.map((k, v) => MapEntry(k, exp(v)));
  final sumExp = expMap.values.fold<double>(0, (a, b) => a + b);
  if (sumExp == 0) {
    final p = 1.0 / sims.length;
    return {for (final k in sims.keys) k: p};
  }
  return expMap.map((k, v) => MapEntry(k, v / sumExp));
}
