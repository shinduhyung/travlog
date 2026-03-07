class ReligionData {
  final String religion;
  final String? denomination;

  ReligionData({required this.religion, this.denomination});

  factory ReligionData.fromJson(Map<String, dynamic> json) {
    return ReligionData(
      religion: json['religion'] as String,
      denomination: json['denomination'] as String?,
    );
  }
}