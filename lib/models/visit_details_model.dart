// lib/models/visit_details_model.dart

import 'package:flutter/material.dart';

class VisitDetails {
  bool isVisited;
  bool hasLived;
  bool isWishlisted; // 🆕 추가: 위시리스트 여부
  double rating;
  int visitCount;
  List<DateRange> visitDateRanges;

  // 🆕 추가: 사용자 입력 평가 지표
  double affordability;
  double safety;
  double foodQuality;
  double transport;
  double englishProficiency;
  double cleanliness;
  double attractionDensity;
  double vibrancy;
  double accessibility;

  VisitDetails({
    this.isVisited = false, // 🆕 기본값을 false로 변경
    this.hasLived = false,
    this.isWishlisted = false, // 🆕 추가: 기본값 false
    this.rating = 0.0,
    this.visitCount = 0,
    List<DateRange>? visitDateRanges,
    this.affordability = 0.0,
    this.safety = 0.0,
    this.foodQuality = 0.0,
    this.transport = 0.0,
    this.englishProficiency = 0.0,
    this.cleanliness = 0.0,
    this.attractionDensity = 0.0,
    this.vibrancy = 0.0,
    this.accessibility = 0.0,
  }) : this.visitDateRanges = visitDateRanges ?? [];

  Map<String, dynamic> toJson() {
    return {
      'isVisited': isVisited,
      'hasLived': hasLived,
      'isWishlisted': isWishlisted, // 🆕 추가
      'rating': rating,
      'visitCount': visitCount,
      'visitDateRanges': visitDateRanges.map((e) => e.toJson()).toList(),
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

  factory VisitDetails.fromJson(Map<String, dynamic> json) {
    var rangesFromJson = json['visitDateRanges'] as List<dynamic>?;
    List<DateRange> ranges = rangesFromJson != null
        ? rangesFromJson.map((e) => DateRange.fromJson(e as Map<String, dynamic>)).toList()
        : [];

    return VisitDetails(
      isVisited: json['isVisited'] ?? false, // 🆕 수정
      hasLived: json['hasLived'] ?? false,
      isWishlisted: json['isWishlisted'] ?? false, // 🆕 추가
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      visitCount: json['visitCount'] ?? 0,
      visitDateRanges: ranges,
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

  int totalDurationInDays() {
    int totalDays = 0;
    for (var range in visitDateRanges) {
      if (range.userDefinedDuration != null) {
        totalDays += range.userDefinedDuration!;
      } else if (range.arrival != null && range.departure != null) {
        final duration = range.departure!.difference(range.arrival!).inDays;
        totalDays += duration + 1;
      }
    }
    return totalDays;
  }
}

class DateRange {
  String title;
  String memo;
  bool isLayover;
  bool isTransfer;
  int? userDefinedDuration;
  bool isDurationUnknown;
  DateTime? arrival;
  DateTime? departure;
  List<String> photos;
  List<String> cities;

  DateRange({
    this.title = '',
    this.memo = '',
    this.isLayover = false,
    this.isTransfer = false,
    this.userDefinedDuration,
    this.isDurationUnknown = false,
    this.arrival,
    this.departure,
    List<String>? photos,
    List<String>? cities,
  }) : this.photos = photos ?? [],
        this.cities = cities ?? [];

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'memo': memo,
      'isLayover': isLayover,
      'isTransfer': isTransfer,
      'userDefinedDuration': userDefinedDuration,
      'isDurationUnknown': isDurationUnknown,
      'arrival': arrival?.toIso8601String(),
      'departure': departure?.toIso8601String(),
      'photos': photos,
      'cities': cities,
    };
  }

  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      title: json['title'] ?? '',
      memo: json['memo'] ?? '',
      isLayover: json['isLayover'] ?? false,
      isTransfer: json['isTransfer'] ?? false,
      userDefinedDuration: json['userDefinedDuration'],
      isDurationUnknown: json['isDurationUnknown'] ?? false,
      arrival: json['arrival'] != null ? DateTime.parse(json['arrival']) : null,
      departure: json['departure'] != null ? DateTime.parse(json['departure']) : null,
      photos: List<String>.from(json['photos'] ?? []),
      cities: List<String>.from(json['cities'] ?? []),
    );
  }

  DateRange copyWith({
    String? title,
    String? memo,
    bool? isLayover,
    bool? isTransfer,
    int? userDefinedDuration,
    bool? isDurationUnknown,
    DateTime? arrival,
    DateTime? departure,
    List<String>? photos,
    List<String>? cities,
  }) {
    return DateRange(
      title: title ?? this.title,
      memo: memo ?? this.memo,
      isLayover: isLayover ?? this.isLayover,
      isTransfer: isTransfer ?? this.isTransfer,
      userDefinedDuration: userDefinedDuration ?? this.userDefinedDuration,
      isDurationUnknown: isDurationUnknown ?? this.isDurationUnknown,
      arrival: arrival ?? this.arrival,
      departure: departure ?? this.departure,
      photos: photos ?? this.photos,
      cities: cities ?? this.cities,
    );
  }
}