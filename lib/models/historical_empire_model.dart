// historical_empire_model.dart

import 'package:latlong2/latlong.dart';

class HistoricalEmpire {
  final String name;
  final String description;
  final List<String> countries;
  // GeoJSON MultiPolygon 구조를 지원하기 위해 List<List<List<LatLng>>>으로 변경 (기존의 List<List<LatLng>>?는 단일 Polygon 또는 Polygon + Hole 구조)
  // 주어진 JSON 구조에 맞추기 위해 List<List<LatLng>>? 유지.
  final List<List<LatLng>>? polygonCoordinates;

  HistoricalEmpire({
    required this.name,
    required this.description,
    required this.countries,
    this.polygonCoordinates,
  });

  // GeoJSON의 Feature 구조를 파싱하도록 factory 생성자를 수정합니다.
  factory HistoricalEmpire.fromJson(Map<String, dynamic> featureJson) {
    final properties = featureJson['properties'];
    final geometry = featureJson['geometry'];

    List<List<LatLng>>? coordinates;
    if (geometry != null && geometry['coordinates'] != null) {
      // GeoJSON은 [longitude, latitude] 순서이므로, LatLng으로 변환 시 순서를 바꿔줍니다.
      // GeoJSON의 Polygon: List<List<List<double>>> 형태 -> List<List<LatLng>>?
      // GeoJSON의 MultiPolygon: List<List<List<List<double>>>> 형태 -> List<List<List<LatLng>>>

      // ottoman_empire_border.json 구조 (List<List<point>>)를 파싱합니다.
      coordinates = (geometry['coordinates'] as List).map((polygon) {
        // polygon: List<point>
        return (polygon as List).map((point) {
          // point: [longitude, latitude]
          return LatLng((point[1] as num).toDouble(), (point[0] as num).toDouble());
        }).toList();
      }).toList();
    }

    return HistoricalEmpire(
      name: properties['name'] as String,
      description: properties['description'] as String,
      countries: List<String>.from(properties['countries']),
      polygonCoordinates: coordinates,
    );
  }
}