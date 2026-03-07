// lib/models/user_visa_model.dart

import 'dart:convert';

class UserVisaInfo {
  final String country;
  final String visaType;
  final String expiryDate;
  final String note;

  UserVisaInfo({
    required this.country,
    required this.visaType,
    required this.expiryDate,
    required this.note,
  });

  // 데이터를 저장하기 위해 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'country': country,
      'visaType': visaType,
      'expiryDate': expiryDate,
      'note': note,
    };
  }

  // 저장된 데이터를 불러오기 위해 Map에서 객체로 변환
  factory UserVisaInfo.fromMap(Map<String, dynamic> map) {
    return UserVisaInfo(
      country: map['country'] ?? '',
      visaType: map['visaType'] ?? '',
      expiryDate: map['expiryDate'] ?? '',
      note: map['note'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserVisaInfo.fromJson(String source) => UserVisaInfo.fromMap(json.decode(source));
}