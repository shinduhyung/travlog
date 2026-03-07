// lib/models/airport_model.dart

class Airport {
  final String iataCode;
  final String name;
  final String country; // country field
  final String? continent; // continent field
  final double latitude;
  final double longitude;
  int visitCount; // visit count
  double? rating; // rating (0.0 ~ 5.0)
  bool isTransit; // transit status
  bool isHub; // My Hub status
  bool isFavorite; // Favorite status

  Airport({
    required this.iataCode,
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.continent,
    this.visitCount = 0,
    this.rating,
    this.isTransit = false,
    this.isHub = false,
    this.isFavorite = false,
  });

  factory Airport.fromJson(Map<String, dynamic> json) {
    return Airport(
      iataCode: json['iata'] ?? json['icao'] ?? 'N/A',
      name: json['name'] ?? 'Unknown',
      country: json['country'] ?? 'Unknown',
      continent: json['continent'],
      latitude: (json['lat'] is String) ? double.tryParse(json['lat']) ?? 0.0 : (json['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['lon'] is String) ? double.tryParse(json['lon']) ?? 0.0 : (json['lon'] as num?)?.toDouble() ?? 0.0,
      visitCount: (json['visitCount'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble(),
      isTransit: json['isTransit'] ?? false,
      isHub: json['isHub'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'iata': iataCode,
      'name': name,
      'country': country,
      'continent': continent,
      'lat': latitude.toString(),
      'lon': longitude.toString(),
      'visitCount': visitCount,
      'rating': rating,
      'isTransit': isTransit,
      'isHub': isHub,
      'isFavorite': isFavorite,
    };
  }
}