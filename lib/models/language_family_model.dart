// lib/models/language_family_model.dart

class LanguageFamilyInfo {
  final String family;
  final String subbranch; // ✅ 원복: branch -> subbranch
  final String subsubbranch; // ✅ 원복: subbranch -> subsubbranch

  LanguageFamilyInfo({
    required this.family,
    required this.subbranch, // ✅ 원복
    required this.subsubbranch, // ✅ 원복
  });

  factory LanguageFamilyInfo.fromJson(Map<String, dynamic> json) {
    // ⭐️ JSON 키는 그대로 'subbranch', 'subsubbranch' 사용
    return LanguageFamilyInfo(
      family: json['family'] as String? ?? 'N/A',
      subbranch: json['subbranch'] as String? ?? 'N/A', // ✅ 원복
      subsubbranch: json['subsubbranch'] as String? ?? 'N/A', // ✅ 원복
    );
  }
}