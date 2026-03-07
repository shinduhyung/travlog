// lib/models/itinerary_entry_model.dart

import 'dart:convert';
import 'dart:developer' as developer;

class DailyItinerary {
  final DateTime date;
  final String content;

  DailyItinerary({required this.date, required this.content});

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'content': content,
  };

  factory DailyItinerary.fromJson(Map<String, dynamic> json) {
    return DailyItinerary(
      date: DateTime.parse(json['date']),
      content: json['content'] as String,
    );
  }
}

class ItineraryEntry {
  final int id;
  final String title;
  final String content; // 사용자가 입력한 프롬프트
  final String generatedItinerary; // AI 전체 응답
  final DateTime date; // 여행 시작일
  final List<DailyItinerary> dailyPlans; // 날짜별로 쪼개진 데이터

  ItineraryEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.generatedItinerary,
    required this.date,
    this.dailyPlans = const [],
  });

  // ⭐️ [추가됨] Provider에서 사용하는 fromJson (fromMap과 연결)
  factory ItineraryEntry.fromJson(Map<String, dynamic> json) {
    return ItineraryEntry.fromMap(json);
  }

  // ⭐️ [추가됨] Provider에서 사용하는 toJson (toMap과 연결)
  Map<String, dynamic> toJson() {
    return toMap();
  }

  // 기존 데이터 호환용 Getter
  List<DailyItinerary> get effectiveDailyPlans {
    if (dailyPlans.isNotEmpty) {
      return dailyPlans;
    }
    if (generatedItinerary.isNotEmpty) {
      return parseFromText(generatedItinerary, date);
    }
    return [];
  }

  // 텍스트 -> 날짜별 리스트 변환 함수
  static List<DailyItinerary> parseFromText(String text, DateTime startDate) {
    final List<DailyItinerary> plans = [];
    final lines = text.split('\n');

    DateTime? currentDate;
    String currentBuffer = '';

    final dateRegex = RegExp(r'(\d{4}-\d{2}-\d{2})');
    final dayRegex = RegExp(r'(?:Day|DAY)\s*(\d+)');

    void saveCurrent() {
      if (currentDate != null && currentBuffer.trim().isNotEmpty) {
        plans.add(DailyItinerary(date: currentDate!, content: currentBuffer.trim()));
      }
    }

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      bool isNewSection = false;
      DateTime? parsedDate;

      final dateMatch = dateRegex.firstMatch(trimmed);
      if (dateMatch != null) {
        try {
          final d = DateTime.parse(dateMatch.group(1)!);
          parsedDate = DateTime.utc(d.year, d.month, d.day);
          isNewSection = true;
        } catch (_) {}
      }
      else {
        final dayMatch = dayRegex.firstMatch(trimmed);
        if (dayMatch != null) {
          try {
            final dayNum = int.parse(dayMatch.group(1)!);
            final calc = startDate.add(Duration(days: dayNum - 1));
            parsedDate = DateTime.utc(calc.year, calc.month, calc.day);
            isNewSection = true;
          } catch (_) {}
        }
      }

      if (isNewSection && parsedDate != null) {
        saveCurrent();
        currentDate = parsedDate;
        currentBuffer = '';
      } else {
        if (currentDate != null) {
          currentBuffer += '$trimmed\n';
        }
      }
    }
    saveCurrent();

    if (plans.isEmpty && text.trim().isNotEmpty) {
      plans.add(DailyItinerary(date: startDate, content: text));
    }

    return plans;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'generatedItinerary': generatedItinerary,
      'date': date.toIso8601String(),
      'dailyPlans': jsonEncode(dailyPlans.map((e) => e.toJson()).toList()),
    };
  }

  factory ItineraryEntry.fromMap(Map<String, dynamic> map) {
    List<DailyItinerary> loadedPlans = [];
    if (map['dailyPlans'] != null && map['dailyPlans'].toString().isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(map['dailyPlans']);
        loadedPlans = decoded.map((e) => DailyItinerary.fromJson(e)).toList();
      } catch (e) {
        developer.log('Error parsing dailyPlans: $e');
      }
    }

    return ItineraryEntry(
      id: map['id'] as int,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      generatedItinerary: map['generatedItinerary'] as String? ?? '',
      date: DateTime.parse(map['date']),
      dailyPlans: loadedPlans,
    );
  }
}