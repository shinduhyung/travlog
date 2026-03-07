// lib/models/calendar_memo_model.dart

import 'package:flutter/foundation.dart';

@immutable
class CalendarMemoModel {
  final String id;
  final String date; // 'yyyy-MM-dd' 형식
  final String? title; // ⭐️ [추가] 제목
  final String content;
  final String? imageUrl; // ⭐️ [추가] 사진 URL

  const CalendarMemoModel({
    required this.id,
    required this.date,
    this.title, // ⭐️ [수정] title은 선택 사항
    required this.content,
    this.imageUrl, // ⭐️ [수정] imageUrl은 선택 사항
  });

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'title': title, // ⭐️ [추가]
      'content': content,
      'imageUrl': imageUrl, // ⭐️ [추가]
    };
  }

  // JSON 역직렬화
  factory CalendarMemoModel.fromJson(Map<String, dynamic> json) {
    return CalendarMemoModel(
      id: json['id'] as String,
      date: json['date'] as String,
      title: json['title'] as String?, // ⭐️ [추가]
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?, // ⭐️ [추가]
    );
  }

  // ⭐️ [추가] 새로운 인스턴스를 생성하면서 특정 필드를 변경하는 copyWith 메서드
  CalendarMemoModel copyWith({
    String? id,
    String? date,
    String? title,
    String? content,
    String? imageUrl,
  }) {
    return CalendarMemoModel(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  String toString() {
    return 'CalendarMemoModel(id: $id, date: $date, title: $title, content: $content, imageUrl: $imageUrl)';
  }
}