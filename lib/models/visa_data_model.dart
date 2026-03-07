// lib/models/visa_data_model.dart

class DestinationVisaInfo {
  final String destinationIsoA3;
  final String rawStatus;

  DestinationVisaInfo({
    required this.destinationIsoA3,
    required this.rawStatus,
  });

  factory DestinationVisaInfo.fromJson(Map<String, dynamic> json) {
    return DestinationVisaInfo(
      // [핵심 수정] JSON 파일에 적힌 키값인 'destination_iso'를 읽도록 수정
      destinationIsoA3: json['destination_iso'] as String? ?? 'N/A',

      // [핵심 수정] JSON 파일에 적힌 키값인 'status'를 읽도록 수정
      rawStatus: json['status']?.toString() ?? 'N/A',
    );
  }

  // 화면 표시용 텍스트 정리 (상태)
  String get displayStatus {
    if (int.tryParse(rawStatus) != null) {
      return 'Visa Free';
    }
    if (rawStatus.toLowerCase().contains('visa free')) {
      return 'Visa Free';
    }
    if (rawStatus == '-1') {
      return 'Home Country';
    }
    return rawStatus;
  }

  // 화면 표시용 텍스트 정리 (기간)
  String get durationText {
    if (int.tryParse(rawStatus) != null) {
      return '$rawStatus days';
    }
    return '';
  }
}

class PassportData {
  final String passportName;
  final int powerRank;
  final int visaFreeCountries;
  final List<DestinationVisaInfo> visaRequirements;

  PassportData({
    required this.passportName,
    required this.powerRank,
    required this.visaFreeCountries,
    required this.visaRequirements,
  });

  factory PassportData.fromJson(Map<String, dynamic> json) {
    var requirementsList = json['visa_requirements'] as List<dynamic>? ?? [];
    return PassportData(
      passportName: json['passport_name'] as String? ?? 'N/A',
      powerRank: json['passport_power_rank'] as int? ?? 0,
      visaFreeCountries: json['visa_free_countries'] as int? ?? 0,
      visaRequirements: requirementsList
          .map((e) => DestinationVisaInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}