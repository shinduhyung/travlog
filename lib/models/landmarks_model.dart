// lib/models/landmarks_model.dart

import 'package:jidoapp/models/visit_date_model.dart';

class LandmarkSubLocation {
  final String name;
  final double latitude;
  final double longitude;

  LandmarkSubLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory LandmarkSubLocation.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return LandmarkSubLocation(
      name: json['name']?.toString() ?? 'Unknown',
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
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

class Landmark {
  final String name;

  // Location fields
  final double latitude;
  final double longitude;
  final String city;

  // Ranks
  int global_rank;
  Map<String, int> localRanks = {};
  int local_rank;
  int attribute_rank;
  final int? nationalRank;
  final List<String> countriesIsoA3;
  final List<String> attributes;
  final int? height;
  final int? qsRank;

  // Popularity Score Added
  final int popularity;

  // Optional fields
  final String? team;
  final String? opened;
  final String? title;
  final String? artist;
  final String? created;
  final String? museum;
  final String? brand;
  final int? numberOfLocations;
  final String? length;
  final int? area;
  final String? month;
  final String? location;
  final String? releaseDate;
  final String? director;
  final String? overview;
  final String? history_significance;
  final String? history;
  final String? highlights;
  final String? bestDishes;
  final String? type;
  final String? inscription;
  final List<LandmarkSubLocation>? locations;

  // Runtime state
  double? rating;
  List<VisitDate> visitDates;

  Landmark({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.city,
    this.global_rank = 0,
    this.local_rank = 0,
    this.attribute_rank = 0,
    this.nationalRank,
    required this.countriesIsoA3,
    required this.attributes,
    this.height,
    this.qsRank,
    this.popularity = 0, // Default to 0
    this.team,
    this.opened,
    this.title,
    this.artist,
    this.created,
    this.museum,
    this.brand,
    this.numberOfLocations,
    this.length,
    this.area,
    this.month,
    this.location,
    this.releaseDate,
    this.director,
    this.overview,
    this.history_significance,
    this.history,
    this.highlights,
    this.bestDishes,
    this.type,
    this.inscription,
    this.locations,
    this.rating,
    List<VisitDate>? visitDates,
  }) : visitDates = visitDates ?? [];

  int getRankForCountry(String? countryIso) {
    if (countryIso == null) return 0;
    if (localRanks.containsKey(countryIso)) {
      return localRanks[countryIso]!;
    }
    return 0;
  }

  factory Landmark.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value, {int defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    int? parseNullableInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value.replaceAll(',', ''));
      return null;
    }

    double parseDouble(dynamic value, {double defaultValue = 0.0}) {
      if (value == null) return defaultValue;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    var attrList = <String>[];
    if (json['attributes'] != null) {
      attrList = List<String>.from(json['attributes']);
    }

    var vDates = <VisitDate>[];
    if (json['visitDates'] != null) {
      vDates = (json['visitDates'] as List)
          .map((v) => VisitDate.fromJson(v))
          .toList();
    }

    List<LandmarkSubLocation>? subLocs;
    if (json['locations'] != null) {
      subLocs = (json['locations'] as List)
          .map((e) => LandmarkSubLocation.fromJson(e))
          .toList();
    }

    String? typeString;
    if (json['type'] is List) {
      typeString = (json['type'] as List).join(', ');
    } else {
      typeString = json['type']?.toString();
    }

    String? highlightsString = json['highlights']?.toString() ?? json['highlight']?.toString();

    return Landmark(
      name: json['name']?.toString() ?? 'Unknown',
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      city: json['city']?.toString() ?? 'Unknown City',
      global_rank: parseInt(json['global_rank']),
      local_rank: parseInt(json['local_rank']),
      attribute_rank: parseInt(json['attribute_rank']),
      nationalRank: parseNullableInt(json['nationalRank']),
      height: parseNullableInt(json['height']),
      qsRank: parseNullableInt(json['qsRank']),
      popularity: parseInt(json['landmarkPopularity'] ?? json['popularity']), // Map popularity
      countriesIsoA3: List<String>.from(json['countriesIsoA3'] ?? []),
      attributes: attrList,
      team: json['Team']?.toString(),
      opened: json['Opened']?.toString() ?? json['open']?.toString(),
      title: json['Title']?.toString(),
      artist: json['Artist']?.toString(),
      created: json['Created']?.toString(),
      museum: json['Museum']?.toString(),
      brand: json['brand']?.toString(),
      numberOfLocations: parseNullableInt(json['number_of_locations']),
      length: json['length']?.toString(),
      area: parseNullableInt(json['area']),
      month: json['Month']?.toString(),
      location: json['Location']?.toString(),
      releaseDate: json['Release date']?.toString(),
      director: json['Director']?.toString(),
      overview: json['overview']?.toString(),
      history_significance: json['history_significance']?.toString(),
      history: json['history']?.toString(),
      highlights: highlightsString,
      bestDishes: json['Best Dishes']?.toString(),
      rating: parseDouble(json['rating']),
      visitDates: vDates,
      type: typeString,
      inscription: json['inscription']?.toString(),
      locations: subLocs,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'global_rank': global_rank,
      'local_rank': local_rank,
      'attribute_rank': attribute_rank,
      'nationalRank': nationalRank,
      'countriesIsoA3': countriesIsoA3,
      'attributes': attributes,
      'height': height,
      'qsRank': qsRank,
      'landmarkPopularity': popularity,
      'overview': overview,
      'history_significance': history_significance,
      'highlights': highlights,
      'rating': rating,
      'visitDates': visitDates.map((date) => date.toJson()).toList(),
    };

    if (team != null) data['Team'] = team;
    if (opened != null) data['Opened'] = opened;
    if (title != null) data['Title'] = title;
    if (artist != null) data['Artist'] = artist;
    if (created != null) data['Created'] = created;
    if (museum != null) data['Museum'] = museum;
    if (brand != null) data['brand'] = brand;
    if (numberOfLocations != null) data['number_of_locations'] = numberOfLocations;
    if (length != null) data['length'] = length;
    if (area != null) data['area'] = area;
    if (month != null) data['Month'] = month;
    if (location != null) data['Location'] = location;
    if (releaseDate != null) data['Release date'] = releaseDate;
    if (director != null) data['Director'] = director;
    if (history != null) data['history'] = history;
    if (bestDishes != null) data['Best Dishes'] = bestDishes;
    if (type != null) data['type'] = type;
    if (inscription != null) data['inscription'] = inscription;
    if (locations != null) {
      data['locations'] = locations!.map((l) => l.toJson()).toList();
    }

    return data;
  }
}