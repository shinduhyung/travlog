// lib/models/language_data_model.dart

import 'package:flutter/material.dart';

// 개별 언어 정보를 담는 클래스
class LanguageInfo {
  final String language;
  final Color color;

  LanguageInfo({required this.language, required this.color});

  factory LanguageInfo.fromJson(Map<String, dynamic> json) {
    // Hex 코드를 Color 객체로 변환
    // 예: "0xFF2E8B57" -> Color(0xFF2E8B57)
    final colorValue = int.parse(json['color'].substring(2), radix: 16) | 0xFF000000;
    return LanguageInfo(
      language: json['language'] as String,
      color: Color(colorValue),
    );
  }
}

// 국가별 언어 데이터 리스트를 담는 클래스
class LanguageData {
  final List<LanguageInfo> languages;

  LanguageData({required this.languages});

  factory LanguageData.fromJson(Map<String, dynamic> json) {
    var langList = json['languages'] as List;
    List<LanguageInfo> languages = langList.map((i) => LanguageInfo.fromJson(i)).toList();
    return LanguageData(languages: languages);
  }
}