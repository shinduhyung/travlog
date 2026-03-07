import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:jidoapp/models/religion_data_model.dart';

class ReligionProvider with ChangeNotifier {
  bool _isLoading = true;
  // 국가 ISO 코드(예: "KOR")를 Key로 사용하는 Map
  Map<String, ReligionData> _religionDataMap = {};

  bool get isLoading => _isLoading;
  Map<String, ReligionData> get religionDataMap => _religionDataMap;

  ReligionProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    final String jsonStr = await rootBundle.loadString('assets/religion_data.json');
    final Map<String, dynamic> decodedJson = json.decode(jsonStr);

    _religionDataMap = decodedJson.map((key, value) {
      return MapEntry(key, ReligionData.fromJson(value));
    });

    _isLoading = false;
    notifyListeners();
  }
}