// lib/models/visit_date_model.dart

class VisitDate {
  int? year;
  int? month;
  int? day;
  String title;
  String? memo;
  List<String> photos;

  // [New] 유네스코용 세부 지역 방문 리스트 (일반 랜드마크는 빈 리스트로 유지됨)
  List<String> visitedDetails;

  VisitDate({
    this.year,
    this.month,
    this.day,
    this.title = '',
    this.memo,
    this.photos = const [],
    this.visitedDetails = const [], // 기본값 빈 리스트
  });

  factory VisitDate.fromJson(Map<String, dynamic> json) {
    return VisitDate(
      year: json['year'] as int?,
      month: json['month'] as int?,
      day: json['day'] as int?,
      title: json['title'] as String? ?? '',
      memo: json['memo'] as String?,
      photos: List<String>.from(json['photos'] ?? []),
      // [New] 기존 데이터(일반 랜드마크)에 이 키가 없어도 에러 없이 빈 리스트([])가 됨
      visitedDetails: List<String>.from(json['visitedDetails'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'day': day,
      'title': title,
      'memo': memo,
      'photos': photos,
      'visitedDetails': visitedDetails, // 저장 시 포함됨 (일반 랜드마크는 빈 리스트로 저장됨)
    };
  }

  VisitDate copyWith({
    int? year,
    int? month,
    int? day,
    String? title,
    String? memo,
    List<String>? photos,
    List<String>? visitedDetails, // [New]
    bool setToNullMemo = false,
  }) {
    return VisitDate(
      year: year ?? this.year,
      month: month ?? this.month,
      day: day ?? this.day,
      title: title ?? this.title,
      memo: setToNullMemo ? null : (memo ?? this.memo),
      photos: photos ?? this.photos,
      visitedDetails: visitedDetails ?? this.visitedDetails, // [New]
    );
  }
}