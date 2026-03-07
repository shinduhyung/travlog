import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:jidoapp/models/historical_empire_model.dart';

// GeoJSON의 FeatureCollection 구조를 파싱하도록 함수를 수정합니다.
List<HistoricalEmpire> _parseEmpires(String jsonStr) {
  final Map<String, dynamic> geoJson = json.decode(jsonStr);
  final List<dynamic> features = geoJson['features'];
  return features.map((feature) => HistoricalEmpire.fromJson(feature)).toList();
}

class HistoryProvider with ChangeNotifier {
  bool _isLoading = true;
  List<HistoricalEmpire> _allEmpires = [];

  bool get isLoading => _isLoading;
  List<HistoricalEmpire> get allEmpires => _allEmpires;

  HistoryProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    // 새로운 geojson 파일을 불러옵니다.
    final String jsonStr = await rootBundle.loadString('assets/historical_empires.geojson');
    _allEmpires = await compute(_parseEmpires, jsonStr);
    _isLoading = false;
    notifyListeners();
  }
}
