// lib/models/subregion_model.dart

import 'package:latlong2/latlong.dart';
import 'dart:developer' as developer;

class Subregion {
  final String name;
  final String isoCode; // e.g., "US-CA"
  final List<List<List<LatLng>>> polygonsData;

  Subregion({
    required this.name,
    required this.isoCode,
    required this.polygonsData,
  });

  factory Subregion.fromJson(Map<String, dynamic> feature) {
    final properties = feature['properties'] as Map<String, dynamic>;
    final geometry = feature['geometry'] as Map<String, dynamic>;

    // --- GeoJSON 표준 속성 이름 ---
    // 이름 찾기. 일반적인 키: 'NAME', 'name', 'ADMIN'.
    // 🆕 GeoJSON 파일에 있는 'NAME_1' 키를 추가합니다.
    final String name = properties['NAME_1']?.toString() ??
        properties['NAME']?.toString() ??
        properties['name']?.toString() ??
        properties['ADMIN']?.toString() ??
        'Unknown';

    // ISO 코드 찾기. 일반적인 키: 'iso_3166_2', 'ISO_A2', 'STUSPS' (미국)
    final String isoCode = properties['iso_3166_2']?.toString() ??
        properties['ISO_A2']?.toString() ??
        properties['STUSPS']?.toString() ??
        'Unknown';

    return Subregion(
      name: name,
      isoCode: isoCode,
      polygonsData: _parsePolygons(geometry, name),
    );
  }

  static List<List<List<LatLng>>> _parsePolygons(Map<String, dynamic> geometry, String name) {
    final type = geometry['type'] as String;
    final coordinates = geometry['coordinates'] as List<dynamic>;
    List<List<List<LatLng>>> polygons = [];

    try {
      if (type == 'Polygon') {
        // Polygon 좌표: List<List<List<num>>>
        // [ [ [lng, lat], [lng, lat]... ], // 외부 링
        //   [ [lng, lat], [lng, lat]... ]  // 홀(구멍)
        // ]
        List<List<LatLng>> polygon = [];
        for (var ring in coordinates) {
          List<LatLng> points = [];
          for (var point in ring as List<dynamic>) {
            // GeoJSON은 [longitude, latitude] 순서입니다.
            points.add(LatLng(point[1] as double, point[0] as double));
          }
          polygon.add(points);
        }
        polygons.add(polygon);

      } else if (type == 'MultiPolygon') {
        // MultiPolygon 좌표: List<List<List<List<num>>>>
        // [
        //   [ [ [lng, lat]... ], [ [lng, lat]... ] ], // 폴리곤 1 (홀 포함)
        //   [ [ [lng, lat]... ] ]                    // 폴리곤 2 (홀 없음)
        // ]
        for (var polygonCoords in coordinates) {
          List<List<LatLng>> polygon = [];
          for (var ring in polygonCoords as List<dynamic>) {
            List<LatLng> points = [];
            for (var point in ring as List<dynamic>) {
              // GeoJSON은 [longitude, latitude] 순서입니다.
              points.add(LatLng(point[1] as double, point[0] as double));
            }
            polygon.add(points);
          }
          polygons.add(polygon);
        }
      }
    } catch (e) {
      developer.log('Error parsing polygon geometry for "$name": $e', name: 'Subregion.fromJson');
    }
    return polygons;
  }
}