// lib/models/unesco_model.dart

import 'package:jidoapp/models/visit_date_model.dart';

class UnescoSubLocation {
  final String name;
  final double latitude;
  final double longitude;

  UnescoSubLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory UnescoSubLocation.fromJson(Map<String, dynamic> json) {
    return UnescoSubLocation(
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class UnescoSite {
  final String name;
  // [Added] Type field (Cultural, Natural, Mixed)
  final String type;
  final double latitude;
  final double longitude;
  final List<String> countriesIsoA3;
  final String city;

  final String? inscription;
  final String? overview;
  final String? history_significance;
  final String? highlights;

  final List<UnescoSubLocation> locations;

  // Runtime state
  double? rating;
  List<VisitDate> visitDates;

  UnescoSite({
    required this.name,
    required this.type, // [Added]
    required this.latitude,
    required this.longitude,
    required this.countriesIsoA3,
    required this.city,
    this.inscription,
    this.overview,
    this.history_significance,
    this.highlights,
    this.rating,
    List<UnescoSubLocation>? locations,
    List<VisitDate>? visitDates,
  })  : locations = locations ?? [],
        visitDates = visitDates ?? [];

  factory UnescoSite.fromJson(Map<String, dynamic> json) {
    var locList = <UnescoSubLocation>[];
    if (json['locations'] != null) {
      locList = (json['locations'] as List)
          .map((e) => UnescoSubLocation.fromJson(e))
          .toList();
    }

    double mainLat = (json['latitude'] as num).toDouble();
    double mainLng = (json['longitude'] as num).toDouble();
    String mainName = json['name'] as String;

    if (locList.isEmpty) {
      locList.add(UnescoSubLocation(
          name: mainName, latitude: mainLat, longitude: mainLng));
    }

    return UnescoSite(
      name: mainName,
      // [Added] Parse type, default to Cultural if missing
      type: json['type'] as String? ?? 'Cultural',
      latitude: mainLat,
      longitude: mainLng,
      countriesIsoA3: List<String>.from(json['countriesIsoA3'] ?? []),
      city: json['city'] as String,
      inscription: json['inscription'] as String?,
      overview: json['overview'] as String?,
      history_significance: json['history_significance'] as String?,
      highlights: json['highlights'] as String?,
      locations: locList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type, // [Added]
      'latitude': latitude,
      'longitude': longitude,
      'countriesIsoA3': countriesIsoA3,
      'city': city,
      'inscription': inscription,
      'overview': overview,
      'history_significance': history_significance,
      'highlights': highlights,
      'locations': locations.map((e) => e.toJson()).toList(),
      'rating': rating,
      'visitDates': visitDates.map((d) => d.toJson()).toList(),
    };
  }
}