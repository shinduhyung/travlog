// lib/models/airline_model.dart

import 'package:flutter/material.dart';

class OtherMileageUsage {
  String id;
  String date;
  String description;
  String category;
  double miles;
  double? cashAmount;

  OtherMileageUsage({
    String? id,
    required this.date,
    required this.description,
    required this.category,
    required this.miles,
    this.cashAmount,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  factory OtherMileageUsage.fromJson(Map<String, dynamic> json) {
    return OtherMileageUsage(
      id: json['id'] as String,
      date: json['date'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      miles: (json['miles'] as num).toDouble(),
      cashAmount: (json['cashAmount'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'description': description,
    'category': category,
    'miles': miles,
    'cashAmount': cashAmount,
  };
}


class FlightLog {
  String id;
  String flightNumber;
  int times;
  String date;

  String? airlineName;
  String? airlineCode;
  String? departureIata;
  String? arrivalIata;
  String? scheduledDepartureTime;
  String? scheduledArrivalTime;

  String? aircraft;

  String? seatClass;
  double? ticketPrice;
  double? vat;
  bool isMileageTicket;
  String? mileageAirline;
  String? bookingDate;

  String? duration;
  String? delay;
  bool isCanceled;

  String? departureTerminal;
  String? departureGate;
  String? arrivalTerminal;
  String? arrivalGate;

  String? ticketPhoto;
  String? memo;
  List<String>? photos;

  double rating;
  String? itineraryId;

  double? upgradePrice;
  bool isUpgradedWithMiles;
  double? upgradeVat;
  String? upgradeDate;
  String? upgradeMileageAirline;


  FlightLog({
    String? id,
    required this.flightNumber,
    this.times = 1,
    this.date = 'Unknown',
    this.airlineName,
    this.airlineCode,
    this.departureIata,
    this.arrivalIata,
    this.scheduledDepartureTime,
    this.scheduledArrivalTime,
    this.aircraft,
    this.seatClass = 'Economy',
    this.ticketPrice,
    this.vat,
    this.isMileageTicket = false,
    this.mileageAirline,
    this.bookingDate,
    this.duration,
    this.delay,
    this.isCanceled = false,
    this.departureTerminal,
    this.departureGate,
    this.arrivalTerminal,
    this.arrivalGate,
    this.ticketPhoto,
    this.memo,
    List<String>? photos,
    this.rating = 0.0,
    this.itineraryId,
    this.upgradePrice,
    this.isUpgradedWithMiles = false,
    this.upgradeVat,
    this.upgradeDate,
    this.upgradeMileageAirline,
  })  : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        photos = photos ?? [];

  factory FlightLog.fromJson(Map<String, dynamic> json) {
    return FlightLog(
      id: json['id'] as String,
      flightNumber: json['flightNumber'] as String,
      times: json['times'] as int,
      date: json['date'] as String,
      airlineName: json['airlineName'] as String?,
      airlineCode: json['airlineCode'] as String?,
      departureIata: json['departureIata'] as String?,
      arrivalIata: json['arrivalIata'] as String?,
      scheduledDepartureTime: json['scheduledDepartureTime'] as String?,
      scheduledArrivalTime: json['scheduledArrivalTime'] as String?,
      aircraft: json['aircraft'] as String?,
      seatClass: json['seatClass'] as String?,
      ticketPrice: (json['ticketPrice'] as num?)?.toDouble(),
      vat: (json['vat'] as num?)?.toDouble(),
      isMileageTicket: json['isMileageTicket'] as bool? ?? false,
      mileageAirline: json['mileageAirline'] as String?,
      bookingDate: json['bookingDate'] as String?,
      duration: json['duration'] as String?,
      delay: json['delay'] as String?,
      isCanceled: json['isCanceled'] as bool? ?? false,
      departureTerminal: json['departureTerminal'] as String?,
      departureGate: json['departureGate'] as String?,
      arrivalTerminal: json['arrivalTerminal'] as String?,
      arrivalGate: json['arrivalGate'] as String?,
      ticketPhoto: json['ticketPhoto'] as String?,
      memo: json['memo'] as String?,
      photos: (json['photos'] as List?)?.map((e) => e as String).toList(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      itineraryId: json['itineraryId'] as String?,
      upgradePrice: (json['upgradePrice'] as num?)?.toDouble(),
      isUpgradedWithMiles: json['isUpgradedWithMiles'] as bool? ?? false,
      upgradeVat: (json['upgradeVat'] as num?)?.toDouble(),
      upgradeDate: json['upgradeDate'] as String?,
      upgradeMileageAirline: json['upgradeMileageAirline'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'flightNumber': flightNumber,
    'times': times,
    'date': date,
    'airlineName': airlineName,
    'airlineCode': airlineCode,
    'departureIata': departureIata,
    'arrivalIata': arrivalIata,
    'scheduledDepartureTime': scheduledDepartureTime,
    'scheduledArrivalTime': scheduledArrivalTime,
    'aircraft': aircraft,
    'seatClass': seatClass,
    'ticketPrice': ticketPrice,
    'vat': vat,
    'isMileageTicket': isMileageTicket,
    'mileageAirline': mileageAirline,
    'bookingDate': bookingDate,
    'duration': duration,
    'delay': delay,
    'isCanceled': isCanceled,
    'departureTerminal': departureTerminal,
    'departureGate': departureGate,
    'arrivalTerminal': arrivalTerminal,
    'arrivalGate': arrivalGate,
    'ticketPhoto': ticketPhoto,
    'memo': memo,
    'photos': photos,
    'rating': rating,
    'itineraryId': itineraryId,
    'upgradePrice': upgradePrice,
    'isUpgradedWithMiles': isUpgradedWithMiles,
    'upgradeVat': upgradeVat,
    'upgradeDate': upgradeDate,
    'upgradeMileageAirline': upgradeMileageAirline,
  };
}

class Airline {
  final String name;
  final String code; // IATA (e.g., KE)
  final String? code3; // ICAO (e.g., KAL)
  String? themeColorHex;
  String? airlineType; // "LCC" or "FSC"
  List<FlightLog> logs;
  List<OtherMileageUsage> otherUsages;
  double rating;
  bool isFavorite;
  double? mileageBalance;

  Airline({
    required this.name,
    required this.code,
    this.code3,
    this.themeColorHex,
    this.airlineType,
    List<FlightLog>? logs,
    List<OtherMileageUsage>? otherUsages,
    this.rating = 0.0,
    this.isFavorite = false,
    this.mileageBalance,
  }) : logs = logs ?? [],
        otherUsages = otherUsages ?? [];

  int get totalTimes => logs.fold(0, (sum, log) => sum + log.times);

  String get firstFlightDate {
    if (logs.isEmpty || logs.every((log) => log.date == 'Unknown')) return 'Unknown';
    final validDates = logs.where((log) => log.date != 'Unknown').map((log) => DateTime.tryParse(log.date)).whereType<DateTime>().toList();
    if (validDates.isEmpty) return 'Unknown';
    validDates.sort((a, b) => a.compareTo(b));
    return validDates.first.toIso8601String().substring(0, 10);
  }

  String get lastFlightDate {
    if (logs.isEmpty || logs.every((log) => log.date == 'Unknown')) return 'Unknown';
    final validDates = logs.where((log) => log.date != 'Unknown').map((log) => DateTime.tryParse(log.date)).whereType<DateTime>().toList();
    if (validDates.isEmpty) return 'Unknown';
    validDates.sort((a, b) => b.compareTo(a));
    return validDates.first.toIso8601String().substring(0, 10);
  }

  factory Airline.fromJson(Map<String, dynamic> json) => Airline(
    name: json['name'],
    code: json['code'],
    code3: json['code3'] as String?,
    themeColorHex: json['theme_color_hex'] as String?,
    airlineType: json['airlineType'] as String?,
    logs: (json['logs'] as List<dynamic>?)?.map((logJson) => FlightLog.fromJson(logJson as Map<String, dynamic>)).toList() ?? [],
    otherUsages: (json['otherUsages'] as List<dynamic>?)?.map((usageJson) => OtherMileageUsage.fromJson(usageJson as Map<String, dynamic>)).toList() ?? [],
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    isFavorite: json['isFavorite'] as bool? ?? false,
    mileageBalance: (json['mileageBalance'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'code': code,
    'code3': code3,
    'theme_color_hex': themeColorHex,
    'airlineType': airlineType,
    'logs': logs.map((log) => log.toJson()).toList(),
    'otherUsages': otherUsages.map((usage) => usage.toJson()).toList(),
    'rating': rating,
    'isFavorite': isFavorite,
    'mileageBalance': mileageBalance,
  };
}


class ConnectionInfo {
  String type;
  String? duration; // 경유 시간 저장 (예: "2h 30m")

  ConnectionInfo({required this.type, this.duration});

  factory ConnectionInfo.fromJson(Map<String, dynamic> json) {
    return ConnectionInfo(
      type: json['type'] as String,
      duration: json['duration'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'duration': duration,
  };
}

class FlightConnection {
  String id;
  String? name;
  List<String> flightLogIds;
  List<ConnectionInfo> connections;

  FlightConnection({
    String? id,
    this.name,
    required this.flightLogIds,
    required this.connections,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  factory FlightConnection.fromJson(Map<String, dynamic> json) {
    return FlightConnection(
      id: json['id'] as String,
      name: json['name'] as String?,
      flightLogIds: (json['flightLogIds'] as List).map((e) => e as String).toList(),
      connections: (json['connections'] as List)
          .map((e) => ConnectionInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'flightLogIds': flightLogIds,
    'connections': connections.map((e) => e.toJson()).toList(),
  };
}

class Itinerary {
  String id;
  List<String> flightLogIds;
  double? ticketPrice;
  bool isMileageTicket;
  double? vat;
  String? name;
  String? bookingDate;

  Itinerary({
    String? id,
    this.name,
    required this.flightLogIds,
    this.ticketPrice,
    this.isMileageTicket = false,
    this.vat,
    this.bookingDate,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    return Itinerary(
      id: json['id'] as String,
      name: json['name'] as String?,
      flightLogIds: List<String>.from(json['flightLogIds'] ?? []),
      ticketPrice: (json['ticketPrice'] as num?)?.toDouble(),
      isMileageTicket: json['isMileageTicket'] as bool? ?? false,
      vat: (json['vat'] as num?)?.toDouble(),
      bookingDate: json['bookingDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'flightLogIds': flightLogIds,
    'ticketPrice': ticketPrice,
    'isMileageTicket': isMileageTicket,
    'vat': vat,
    'bookingDate': bookingDate,
  };
}

class Purchase {
  final String id;
  final String description;
  final String? route;
  final double? price;
  final bool isMileage;
  final String? date;
  final bool isItinerary;
  final int flightCount;

  Purchase({
    required this.id,
    required this.description,
    this.route,
    this.price,
    required this.isMileage,
    this.date,
    required this.isItinerary,
    required this.flightCount,
  });
}