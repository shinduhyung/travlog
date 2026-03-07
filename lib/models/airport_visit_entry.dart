// lib/models/airport_visit_entry.dart

import 'package:flutter/material.dart';

/// Represents a single use or visit to an airport.
class AirportVisitEntry {
  // ⚠️ 기존 DateTime? date; 필드를 제거하고 int? 필드로 변경
  int? year;
  int? month;
  int? day;

  bool isTransfer; // 🆕 추가: 환승 여부 (독립적인 필드)
  bool isLayover;  // 🆕 추가: 경유 여부 (독립적인 필드)
  bool isStopover; // ⭐️ 추가: 스톱오버 여부

  // ⭐️ 추가: 개별 방문에 대한 라운지 이용 여부 및 평점
  bool isLoungeUsed;
  double? loungeRating;

  // ⭐️ 추가: 개별 라운지 방문에 대한 메모 및 사진
  String? loungeMemo;
  List<String> loungePhotos;

  // ▼▼▼▼▼▼▼▼▼▼ YEOGIYA ▼▼▼▼▼▼▼▼▼▼
  // ⭐️ 추가: 라운지 체류 시간 (분)
  int? loungeDurationInMinutes;
  // ▲▲▲▲▲▲▲▲▲▲ YEOGIYA ▲▲▲▲▲▲▲▲▲▲


  AirportVisitEntry({
    this.year,
    this.month,
    this.day,
    this.isTransfer = false,
    this.isLayover = false,
    this.isStopover = false,
    this.isLoungeUsed = false,
    this.loungeRating,
    this.loungeMemo,
    this.loungePhotos = const [],
    this.loungeDurationInMinutes, // ⭐️ 생성자에 추가
  });

  DateTime? get date {
    if (year == null && month == null && day == null) {
      return null;
    }
    final validYear = year ?? 1900;
    final validMonth = month ?? 1;
    final validDay = day ?? 1;
    try {
      return DateTime(validYear, validMonth, validDay);
    } catch (e) {
      return null;
    }
  }

  factory AirportVisitEntry.fromJson(Map<String, dynamic> json) {
    return AirportVisitEntry(
      year: json['year'] as int?,
      month: json['month'] as int?,
      day: json['day'] as int?,
      isTransfer: json['isTransfer'] ?? json['isTransit'] ?? false,
      isLayover: json['isLayover'] ?? false,
      isStopover: json['isStopover'] ?? false,
      isLoungeUsed: json['isLoungeUsed'] ?? false,
      loungeRating: (json['loungeRating'] as num?)?.toDouble(),
      loungeMemo: json['loungeMemo'] as String?,
      loungePhotos: List<String>.from(json['loungePhotos'] ?? []),
      loungeDurationInMinutes: json['loungeDurationInMinutes'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'day': day,
      'isTransfer': isTransfer,
      'isLayover': isLayover,
      'isStopover': isStopover,
      'isLoungeUsed': isLoungeUsed,
      'loungeRating': loungeRating,
      'loungeMemo': loungeMemo,
      'loungePhotos': loungePhotos,
      'loungeDurationInMinutes': loungeDurationInMinutes,
    };
  }
}