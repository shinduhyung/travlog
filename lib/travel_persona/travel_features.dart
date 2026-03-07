// lib/travel_persona/travel_features.dart

import 'dart:math';

/// Gemini가 뱉어주는 31개의 축을 담는 데이터 모델
class TravelFeatures {
  // --- Distribution (5)
  final double continentDistribution;
  final double countryDistribution;
  final double cityDistribution;
  final double airportDistribution;
  final double airlineDistribution;

  // --- Country / City traits (6)
  final double countryWealth;
  final double cityWealth;
  final double countryType;      // -1 = 자연 중심, +1 = 도시 중심
  final double cityType;         // -1 = 자연 중심 도시, +1 = 인공/도시 중심
  final double countryNightlife; // -1 = 조용, +1 = 밤문화 강함
  final double cityNightlife;

  // --- Flight / Transfer (3)
  final double airlineTime;           // -1 = 짧은 비행, +1 = 장거리
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

  // --- Personality 8축 (DNA Test에서 옴)
  final double soloSocial;
  final double relaxedIntense;
  final double plannedSpontaneous;
  final double urbanNature;
  final double cultureFun;
  final double personalityBudgetLuxury;
  final double morningNight;
  final double documenterLive;

  const TravelFeatures({
    required this.continentDistribution,
    required this.countryDistribution,
    required this.cityDistribution,
    required this.airportDistribution,
    required this.airlineDistribution,
    required this.countryWealth,
    required this.cityWealth,
    required this.countryType,
    required this.cityType,
    required this.countryNightlife,
    required this.cityNightlife,
    required this.airlineTime,
    required this.transferAirportScore,
    required this.transferFlightScore,
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
    required this.soloSocial,
    required this.relaxedIntense,
    required this.plannedSpontaneous,
    required this.urbanNature,
    required this.cultureFun,
    required this.personalityBudgetLuxury,
    required this.morningNight,
    required this.documenterLive,
  });

  Map<String, double> toJson() {
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