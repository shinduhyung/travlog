// lib/models/city_visit_detail_model.dart

import 'package:jidoapp/models/visit_details_model.dart';
import 'dart:developer' as developer;

class CityVisitDetail {
  final String name;
  final String arrivalDate;
  final String? arrivalTime;
  final String departureDate;
  final String? departureTime;
  final String duration;

  bool hasLived;
  final bool isHome;
  final bool isWishlisted;
  double rating;
  List<DateRange> visitDateRanges;
  String? memo;
  List<String> photos;

  // 사용자 입력 평가 지표 추가
  double affordability;
  double safety;
  double foodQuality;
  double transport;
  double englishProficiency;
  double cleanliness;
  double attractionDensity;
  double vibrancy;
  double accessibility;

  int get visitCount => visitDateRanges.length;

  int totalDurationInDays() {
    return visitDateRanges.fold(0, (sum, range) {
      if (range.userDefinedDuration != null) {
        return sum + range.userDefinedDuration!;
      }
      if (range.arrival != null && range.departure != null) {
        final duration = range.departure!.difference(range.arrival!).inDays + 1;
        return sum + duration;
      }
      return sum;
    });
  }

  Duration? get preciseDuration {
    if (arrivalDate != 'Unknown' && arrivalTime != null &&
        departureDate != 'Unknown' && departureTime != null) {
      try {
        final arrival = DateTime.parse('$arrivalDate ${arrivalTime!}:00');
        final departure = DateTime.parse('$departureDate ${departureTime!}:00');
        return departure.difference(arrival);
      } catch (e) {
        developer.log('Error calculating precise duration: $e', name: 'CityVisitDetail.preciseDuration');
        return null;
      }
    }
    return null;
  }

  int? get stayHours {
    final precise = preciseDuration;
    if (precise != null) {
      return precise.inHours;
    }

    if (duration != 'N/A') {
      final hoursMatch = RegExp(r'(\d+)\s*hours?').firstMatch(duration);
      if (hoursMatch != null) {
        return int.tryParse(hoursMatch.group(1)!);
      }

      final daysMatch = RegExp(r'(\d+)\s*days?').firstMatch(duration);
      if (daysMatch != null) {
        final days = int.tryParse(daysMatch.group(1)!);
        return days != null ? days * 24 : null;
      }
    }

    return null;
  }

  String get formattedStayDuration {
    final hours = stayHours;
    if (hours == null) return duration;

    if (hours < 24) {
      return '$hours hours';
    } else {
      final days = hours ~/ 24;
      final remainingHours = hours % 24;
      if (remainingHours == 0) {
        return '$days days';
      } else {
        return '$days days $remainingHours hours';
      }
    }
  }

  DateTime? get arrivalDateTime {
    if (arrivalDate != 'Unknown') {
      try {
        final timeStr = arrivalTime ?? '00:00';
        return DateTime.parse('$arrivalDate $timeStr:00');
      } catch (e) {
        developer.log('Error parsing arrival datetime: $e', name: 'CityVisitDetail.arrivalDateTime');
      }
    }
    return null;
  }

  DateTime? get departureDateTime {
    if (departureDate != 'Unknown') {
      try {
        final timeStr = departureTime ?? '00:00';
        return DateTime.parse('$departureDate $timeStr:00');
      } catch (e) {
        developer.log('Error parsing departure datetime: $e', name: 'CityVisitDetail.departureDateTime');
      }
    }
    return null;
  }

  CityVisitDetail({
    required this.name,
    this.arrivalDate = 'Unknown',
    this.arrivalTime,
    this.departureDate = 'Unknown',
    this.departureTime,
    this.duration = 'N/A',
    this.hasLived = false,
    this.isHome = false,
    this.isWishlisted = false,
    this.rating = 0.0,
    List<DateRange>? visitDateRanges,
    this.memo,
    List<String>? photos,
    this.affordability = 0.0,
    this.safety = 0.0,
    this.foodQuality = 0.0,
    this.transport = 0.0,
    this.englishProficiency = 0.0,
    this.cleanliness = 0.0,
    this.attractionDensity = 0.0,
    this.vibrancy = 0.0,
    this.accessibility = 0.0,
  }) : this.visitDateRanges = visitDateRanges ?? [],
        this.photos = photos ?? [];

  factory CityVisitDetail.fromJson(Map<String, dynamic> json) {
    return CityVisitDetail(
      name: json['name'] as String? ?? 'Unknown',
      arrivalDate: json['arrivalDate'] as String? ?? 'Unknown',
      arrivalTime: json['arrivalTime'] as String?,
      departureDate: json['departureDate'] as String? ?? 'Unknown',
      departureTime: json['departureTime'] as String?,
      duration: json['duration'] as String? ?? 'N/A',
      hasLived: json['hasLived'] as bool? ?? false,
      isHome: json['isHome'] as bool? ?? false,
      isWishlisted: json['isWishlisted'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      visitDateRanges: (json['visitDateRanges'] as List<dynamic>?)
          ?.map((e) => DateRange.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      memo: json['memo'] as String?,
      photos: (json['photos'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      affordability: (json['affordability'] as num?)?.toDouble() ?? 0.0,
      safety: (json['safety'] as num?)?.toDouble() ?? 0.0,
      foodQuality: (json['foodQuality'] as num?)?.toDouble() ?? 0.0,
      transport: (json['transport'] as num?)?.toDouble() ?? 0.0,
      englishProficiency: (json['englishProficiency'] as num?)?.toDouble() ?? 0.0,
      cleanliness: (json['cleanliness'] as num?)?.toDouble() ?? 0.0,
      attractionDensity: (json['attractionDensity'] as num?)?.toDouble() ?? 0.0,
      vibrancy: (json['vibrancy'] as num?)?.toDouble() ?? 0.0,
      accessibility: (json['accessibility'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'arrivalDate': arrivalDate,
      'arrivalTime': arrivalTime,
      'departureDate': departureDate,
      'departureTime': departureTime,
      'duration': duration,
      'hasLived': hasLived,
      'isHome': isHome,
      'isWishlisted': isWishlisted,
      'rating': rating,
      'visitDateRanges': visitDateRanges.map((e) => e.toJson()).toList(),
      'memo': memo,
      'photos': photos,
      'affordability': affordability,
      'safety': safety,
      'foodQuality': foodQuality,
      'transport': transport,
      'englishProficiency': englishProficiency,
      'cleanliness': cleanliness,
      'attractionDensity': attractionDensity,
      'vibrancy': vibrancy,
      'accessibility': accessibility,
    };
  }

  CityVisitDetail copyWith({
    String? name,
    String? arrivalDate,
    String? arrivalTime,
    String? departureDate,
    String? departureTime,
    String? duration,
    bool? hasLived,
    bool? isHome,
    bool? isWishlisted,
    double? rating,
    List<DateRange>? visitDateRanges,
    String? memo,
    List<String>? photos,
    double? affordability,
    double? safety,
    double? foodQuality,
    double? transport,
    double? englishProficiency,
    double? cleanliness,
    double? attractionDensity,
    double? vibrancy,
    double? accessibility,
  }) {
    return CityVisitDetail(
      name: name ?? this.name,
      arrivalDate: arrivalDate ?? this.arrivalDate,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      departureDate: departureDate ?? this.departureDate,
      departureTime: departureTime ?? this.departureTime,
      duration: duration ?? this.duration,
      hasLived: hasLived ?? this.hasLived,
      isHome: isHome ?? this.isHome,
      isWishlisted: isWishlisted ?? this.isWishlisted,
      rating: rating ?? this.rating,
      visitDateRanges: visitDateRanges ?? this.visitDateRanges,
      memo: memo ?? this.memo,
      photos: photos ?? this.photos,
      affordability: affordability ?? this.affordability,
      safety: safety ?? this.safety,
      foodQuality: foodQuality ?? this.foodQuality,
      transport: transport ?? this.transport,
      englishProficiency: englishProficiency ?? this.englishProficiency,
      cleanliness: cleanliness ?? this.cleanliness,
      attractionDensity: attractionDensity ?? this.attractionDensity,
      vibrancy: vibrancy ?? this.vibrancy,
      accessibility: accessibility ?? this.accessibility,
    );
  }

  @override
  String toString() {
    return 'CityVisitDetail(name: $name, arrival: $arrivalDate $arrivalTime, departure: $departureDate $departureTime, duration: $duration, hours: $stayHours)';
  }
}