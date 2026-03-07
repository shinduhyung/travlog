// lib/providers/country_info_provider.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:jidoapp/models/country_info_model.dart';

class CountryInfoProvider with ChangeNotifier {
  Map<String, CountryInfo> _countryInfoMap = {};
  bool _isLoading = true;

  Map<String, CountryInfo> get countryInfoMap => _countryInfoMap;
  bool get isLoading => _isLoading;

  CountryInfoProvider() {
    _loadAllCountryInfo();
  }

  Future<void> _loadAllCountryInfo() async {
    try {
      // 1. Load all JSON files
      final String infoString = await rootBundle.loadString('assets/country_info.json');
      final String historyString = await rootBundle.loadString('assets/country_history.json');
      final String safetyString = await rootBundle.loadString('assets/country_safety.json');

      // 2. Decode JSONs
      final Map<String, dynamic> infoJson = json.decode(infoString);
      final Map<String, dynamic> historyJson = json.decode(historyString);
      final Map<String, dynamic> safetyJson = json.decode(safetyString);

      // 3. Merge and Create CountryInfo objects
      _countryInfoMap = infoJson.map((key, value) {
        // 'value' is the Map from country_info.json (capital, currency, etc.)
        final Map<String, dynamic> combinedMap = Map<String, dynamic>.from(value as Map<String, dynamic>);

        // Inject History Data
        if (historyJson.containsKey(key)) {
          combinedMap['history'] = historyJson[key];
        } else {
          combinedMap['history'] = [];
        }

        // Inject Safety Data
        if (safetyJson.containsKey(key)) {
          final safetyData = safetyJson[key];
          // Handle "level": "5" (String) -> 5 (int) conversion
          if (safetyData is Map && safetyData['level'] != null) {
            final levelRaw = safetyData['level'];
            if (levelRaw is int) {
              combinedMap['safetyLevel'] = levelRaw;
            } else if (levelRaw is String) {
              combinedMap['safetyLevel'] = int.tryParse(levelRaw) ?? 0;
            }
          }
        } else {
          combinedMap['safetyLevel'] = 0;
        }

        return MapEntry(key, CountryInfo.fromJson(combinedMap));
      });

    } catch (e) {
      debugPrint("Error loading country info: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}