// lib/models/trip_log_entry.dart

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:jidoapp/models/city_visit_detail_model.dart';

class AiLandmarkLog {
  final String name;
  final String? visitDate;

  AiLandmarkLog({required this.name, this.visitDate});

  factory AiLandmarkLog.fromMap(Map<String, dynamic> map) {
    return AiLandmarkLog(
      name: map['name'] ?? '',
      visitDate: map['visitDate'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'visitDate': visitDate,
    };
  }

  // Added toJson to support jsonEncode safely
  Map<String, dynamic> toJson() => toMap();

  // Overriding toString to ensure the name is returned instead of "Instance of..."
  @override
  String toString() => name;

  AiLandmarkLog copyWith({String? name, String? visitDate}) {
    return AiLandmarkLog(
      name: name ?? this.name,
      visitDate: visitDate ?? this.visitDate,
    );
  }
}

class AirportLog {
  final String iataCode;
  final String name;
  final String? visitDate;
  final bool isTransit;

  AirportLog({
    required this.iataCode,
    required this.name,
    this.visitDate,
    this.isTransit = false,
  });

  factory AirportLog.fromMap(Map<String, dynamic> map) {
    return AirportLog(
      iataCode: map['iataCode'] ?? '',
      name: map['name'] ?? '',
      visitDate: map['visitDate'] as String?,
      isTransit: map['isTransit'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'iataCode': iataCode,
      'name': name,
      'visitDate': visitDate,
      'isTransit': isTransit,
    };
  }

  AirportLog copyWith({
    String? iataCode,
    String? name,
    String? visitDate,
    bool? isTransit,
  }) {
    return AirportLog(
      iataCode: iataCode ?? this.iataCode,
      name: name ?? this.name,
      visitDate: visitDate ?? this.visitDate,
      isTransit: isTransit ?? this.isTransit,
    );
  }
}

class FlightDetail {
  final String flightNumber;
  final String origin;
  final String destination;
  final String? flightDate;
  final String? departureTime;
  final String? arrivalTime;
  final String? duration;
  final int sequence;

  FlightDetail({
    this.flightNumber = '',
    this.origin = '',
    this.destination = '',
    this.flightDate,
    this.departureTime,
    this.arrivalTime,
    this.duration,
    this.sequence = 0,
  });

  factory FlightDetail.fromMap(Map<String, dynamic> map) {
    return FlightDetail(
      flightNumber: map['flightNumber'] ?? '',
      origin: map['origin'] ?? '',
      destination: map['destination'] ?? '',
      flightDate: map['flightDate'],
      duration: map['duration'],
      departureTime: map['departureTime'],
      arrivalTime: map['arrivalTime'],
      sequence: map['sequence'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'flightNumber': flightNumber,
      'origin': origin,
      'destination': destination,
      'flightDate': flightDate,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'duration': duration,
      'sequence': sequence,
    };
  }
}

class AirlineLog {
  final String airlineName;
  final List<FlightDetail> flights;

  AirlineLog({
    this.airlineName = '',
    this.flights = const [],
  });

  factory AirlineLog.fromMap(Map<String, dynamic> map) {
    return AirlineLog(
      airlineName: map['airlineName'] ?? '',
      flights: (map['flights'] as List<dynamic>?)
          ?.where((x) => x is Map<String, dynamic>)
          .map((x) => FlightDetail.fromMap(x as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'airlineName': airlineName,
      'flights': flights.map((x) => x.toMap()).toList(),
    };
  }
}

class CountryLog {
  final String name;
  final String arrivalDate;
  final String duration;

  CountryLog({
    this.name = '',
    this.arrivalDate = '',
    this.duration = '',
  });

  factory CountryLog.fromMap(Map<String, dynamic> map) {
    return CountryLog(
      name: map['name'] ?? '',
      arrivalDate: map['arrivalDate'] ?? '',
      duration: map['duration'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'arrivalDate': arrivalDate,
      'duration': duration,
    };
  }
}

class CitiesInCountry {
  final String countryName;
  final List<CityVisitDetail> cities;

  CitiesInCountry({
    this.countryName = '',
    this.cities = const [],
  });

  factory CitiesInCountry.fromMap(Map<String, dynamic> map) {
    final List<dynamic>? citiesRaw = map['cities'];
    List<CityVisitDetail> parsedCities = [];

    if (citiesRaw != null) {
      for (var item in citiesRaw) {
        if (item is Map<String, dynamic>) {
          parsedCities.add(CityVisitDetail.fromJson(item));
        } else if (item is String) {
          final cityMatch = RegExp(r'([^()]+)\s*\(([A-Z]{2})\)\(Arrival:\s*([^\s,]+),\s*Duration:\s*([^)]+)\)').firstMatch(item.trim());
          if (cityMatch != null) {
            String departureDate = 'Unknown';
            final arrivalDateStr = cityMatch.group(3)!.trim();
            final durationStr = cityMatch.group(4)!.trim();
            try {
              final arrival = DateTime.parse(arrivalDateStr);
              final durationMatch = RegExp(r'(\d+)').firstMatch(durationStr);
              if (durationMatch != null) {
                final days = int.parse(durationMatch.group(1)!);
                final departure = arrival.add(Duration(days: days - 1));
                departureDate = departure.toIso8601String().split('T')[0];
              }
            } catch (e) {
              departureDate = 'Unknown';
            }
            parsedCities.add(CityVisitDetail(
              name: cityMatch.group(1)!.trim(),
              arrivalDate: arrivalDateStr,
              departureDate: departureDate,
              duration: durationStr,
            ));
          } else {
            final simpleNameMatch = RegExp(r'([^()]+)\(Arrival:\s*([^\s,]+),\s*Duration:\s*([^)]+)\)').firstMatch(item.trim());
            if (simpleNameMatch != null) {
              parsedCities.add(CityVisitDetail(
                name: simpleNameMatch.group(1)!.trim(),
                arrivalDate: simpleNameMatch.group(2)!.trim(),
                duration: simpleNameMatch.group(3)!.trim(),
              ));
            } else {
              final bareCityName = item.trim().replaceAll(RegExp(r'\([^)]*\)'), '').trim();
              if (bareCityName.isNotEmpty) {
                parsedCities.add(CityVisitDetail(name: bareCityName));
              }
            }
          }
        }
      }
    }

    return CitiesInCountry(
      countryName: map['countryName'] ?? '',
      cities: parsedCities,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'countryName': countryName,
      'cities': cities.map((x) => x.toJson()).toList(),
    };
  }
}

class TrainLog {
  final String? trainCompany;
  final String? trainNumber;
  final String? origin;
  final String? destination;
  final String? date;
  final String? departureTime;
  final String? arrivalTime;
  final String? duration;
  final int sequence;

  TrainLog({
    this.trainCompany,
    this.trainNumber,
    this.origin,
    this.destination,
    this.date,
    this.departureTime,
    this.arrivalTime,
    this.duration,
    this.sequence = 0,
  });

  factory TrainLog.fromMap(Map<String, dynamic> map) {
    return TrainLog(
      trainCompany: map['trainCompany'],
      trainNumber: map['trainNumber'],
      origin: map['origin'],
      destination: map['destination'],
      date: map['date'],
      departureTime: map['departureTime'],
      arrivalTime: map['arrivalTime'],
      duration: map['duration'],
      sequence: map['sequence'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'trainCompany': trainCompany,
      'trainNumber': trainNumber,
      'origin': origin,
      'destination': destination,
      'date': date,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'duration': duration,
      'sequence': sequence,
    };
  }
}

class BusLog {
  final String? busCompany;
  final String? origin;
  final String? destination;
  final String? date;
  final String? departureTime;
  final String? arrivalTime;
  final String? duration;
  final int sequence;

  BusLog({
    this.busCompany,
    this.origin,
    this.destination,
    this.date,
    this.departureTime,
    this.arrivalTime,
    this.duration,
    this.sequence = 0,
  });

  factory BusLog.fromMap(Map<String, dynamic> map) {
    return BusLog(
      busCompany: map['busCompany'],
      origin: map['origin'],
      destination: map['destination'],
      date: map['date'],
      departureTime: map['departureTime'],
      arrivalTime: map['arrivalTime'],
      duration: map['duration'],
      sequence: map['sequence'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'busCompany': busCompany,
      'origin': origin,
      'destination': destination,
      'date': date,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'duration': duration,
      'sequence': sequence,
    };
  }
}

class FerryLog {
  final String? ferryName;
  final String? origin;
  final String? destination;
  final String? date;
  final String? departureTime;
  final String? arrivalTime;
  final String? duration;
  final int sequence;

  FerryLog({
    this.ferryName,
    this.origin,
    this.destination,
    this.date,
    this.departureTime,
    this.arrivalTime,
    this.duration,
    this.sequence = 0,
  });

  factory FerryLog.fromMap(Map<String, dynamic> map) {
    return FerryLog(
      ferryName: map['ferryName'],
      origin: map['origin'],
      destination: map['destination'],
      date: map['date'],
      departureTime: map['departureTime'],
      arrivalTime: map['arrivalTime'],
      duration: map['duration'],
      sequence: map['sequence'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ferryName': ferryName,
      'origin': origin,
      'destination': destination,
      'date': date,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'duration': duration,
      'sequence': sequence,
    };
  }
}

class CarLog {
  final String? carType;
  final String? origin;
  final String? destination;
  final String? date;
  final String? departureTime;
  final String? arrivalTime;
  final String? duration;
  final int sequence;

  CarLog({
    this.carType,
    this.origin,
    this.destination,
    this.date,
    this.departureTime,
    this.arrivalTime,
    this.duration,
    this.sequence = 0,
  });

  factory CarLog.fromMap(Map<String, dynamic> map) {
    return CarLog(
      carType: map['carType'],
      origin: map['origin'],
      destination: map['destination'],
      date: map['date'],
      departureTime: map['departureTime'],
      arrivalTime: map['arrivalTime'],
      duration: map['duration'],
      sequence: map['sequence'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'carType': carType,
      'origin': origin,
      'destination': destination,
      'date': date,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'duration': duration,
      'sequence': sequence,
    };
  }
}

class AiSummary {
  final List<CountryLog> countries;
  final List<CitiesInCountry> cities;
  final List<AirportLog> airports;
  final List<AirlineLog> flights;
  final List<TrainLog> trains;
  final List<BusLog> buses;
  final List<FerryLog> ferries;
  final List<CarLog> cars;
  final List<AiLandmarkLog> landmarks;
  final List<String> transitAirports;
  final String? startLocation;
  final String? endLocation;

  AiSummary({
    this.countries = const [],
    this.cities = const [],
    this.airports = const [],
    this.flights = const [],
    this.trains = const [],
    this.buses = const [],
    this.ferries = const [],
    this.cars = const [],
    this.landmarks = const [],
    this.transitAirports = const [],
    this.startLocation,
    this.endLocation,
  });

  factory AiSummary.fromMap(Map<String, dynamic> map) {
    List<T> parseList<T>(String key, T Function(Map<String, dynamic>) fromMap) {
      final list = map[key];
      if (list is List) {
        return list.map((item) {
          if (item is Map<String, dynamic>) {
            return fromMap(item);
          } else {
            developer.log('[ERROR] Invalid item type in $key: ${item.runtimeType}, Value: $item');
            throw FormatException('Invalid item type in $key. Expected Map but got ${item.runtimeType}');
          }
        }).toList();
      }
      return [];
    }

    return AiSummary(
      countries: parseList('countries', CountryLog.fromMap),
      cities: parseList('cities', CitiesInCountry.fromMap),
      airports: parseList('airports', AirportLog.fromMap),
      flights: parseList('flights', AirlineLog.fromMap),
      trains: parseList('trains', TrainLog.fromMap),
      buses: parseList('buses', BusLog.fromMap),
      ferries: parseList('ferries', FerryLog.fromMap),
      cars: parseList('cars', CarLog.fromMap),
      landmarks: parseList('landmarks', AiLandmarkLog.fromMap),
      transitAirports: List<String>.from(map['transitAirports'] ?? []),
      startLocation: map['startLocation'] as String?,
      endLocation: map['endLocation'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'countries': countries.map((x) => x.toMap()).toList(),
      'cities': cities.map((x) => x.toMap()).toList(),
      'airports': airports.map((x) => x.toMap()).toList(),
      'flights': flights.map((x) => x.toMap()).toList(),
      'trains': trains.map((x) => x.toMap()).toList(),
      'buses': buses.map((x) => x.toMap()).toList(),
      'ferries': ferries.map((x) => x.toMap()).toList(),
      'cars': cars.map((x) => x.toMap()).toList(),
      'landmarks': landmarks.map((x) => x.toMap()).toList(),
      'transitAirports': transitAirports,
      'startLocation': startLocation,
      'endLocation': endLocation,
    };
  }
}

class TripLogEntry {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  AiSummary? summary;
  String? generatedItinerary;

  TripLogEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.summary,
    this.generatedItinerary,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'summary': summary != null ? json.encode(summary!.toMap()) : null,
      'generatedItinerary': generatedItinerary,
    };
  }

  factory TripLogEntry.fromMap(Map<String, dynamic> map) {
    AiSummary? parsedSummary;
    if (map['summary'] != null) {
      try {
        if (map['summary'] is String) {
          parsedSummary = AiSummary.fromMap(json.decode(map['summary']));
        } else if (map['summary'] is Map<String, dynamic>) {
          parsedSummary = AiSummary.fromMap(map['summary']);
        }
      } catch (e) {
        developer.log('[ERROR] Failed to parse summary for Log ID: ${map['id']}');
        developer.log('Title: ${map['title']}');
        developer.log('Error details: $e');
        parsedSummary = null;
      }
    }

    return TripLogEntry(
      id: map['id'].toString(),
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      date: DateTime.parse(map['date']),
      summary: parsedSummary,
      generatedItinerary: map['generatedItinerary'] as String?,
    );
  }
}