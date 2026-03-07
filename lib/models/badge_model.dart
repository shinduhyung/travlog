// lib/models/badge_model.dart

enum AchievementCategory {
  Country,
  City,
  Flight,
  Landmarks,
}

enum AchievementDifficulty {
  Rookie,
  Explorer,
  Nomad,
  Adventurer,
  Globetrotter,
  Worldmaster,
  Legend,
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final AchievementDifficulty difficulty;
  final int points; // Points awarded for this achievement
  final String imagePath;
  final AchievementCategory category;
  bool isUnlocked;

  // Total count required for the achievement (e.g., 10 countries visited)
  final int? targetCount;
  // Specific ISO codes required for the achievement (e.g., list of World Cup winners)
  final Set<String>? targetIsoCodes;

  // Population-based achievement field
  final int? targetPopulationLimit;

  // Area-based achievement field (in km²)
  final int? targetAreaLimit;

  // GDP-based achievement field (in USD)
  final double? targetGdpLimit;

  // New requirement fields for beginner achievements
  final bool requiresHome;
  final bool requiresRating;
  final bool requiresCulturalLandmark;
  final bool requiresNaturalLandmark;
  final bool requiresAirportRating;
  final bool requiresAirportHub;
  final bool requiresAirlineRating;
  final bool requiresBusinessClass;
  final bool requiresFirstClass;

  // Landmark and UNESCO count requirements
  final int? requiresLandmarkCount;
  final int? requiresUnescoCount;
  final bool requiresCulturalUnescoSite;
  final bool requiresNaturalUnescoSite;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.points,
    required this.imagePath,
    required this.category,
    this.isUnlocked = false,
    this.targetCount,
    this.targetIsoCodes,
    this.targetPopulationLimit,
    this.targetAreaLimit,
    this.targetGdpLimit,
    this.requiresHome = false,
    this.requiresRating = false,
    this.requiresCulturalLandmark = false,
    this.requiresNaturalLandmark = false,
    this.requiresAirportRating = false,
    this.requiresAirportHub = false,
    this.requiresAirlineRating = false,
    this.requiresBusinessClass = false,
    this.requiresFirstClass = false,
    this.requiresLandmarkCount,
    this.requiresUnescoCount,
    this.requiresCulturalUnescoSite = false,
    this.requiresNaturalUnescoSite = false,
  });
}