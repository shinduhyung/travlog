// providers/economy_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jidoapp/models/economy_data_model.dart';

class EconomyProvider with ChangeNotifier {
  List<EconomyData> _economyData = [];
  Map<String, Map<String, double>> _economicsTriviaData = {};
  bool _isLoading = false;

  List<EconomyData> get economyData => _economyData;
  Map<String, Map<String, double>> get economicsTriviaData => _economicsTriviaData;
  bool get isLoading => _isLoading;

  EconomyProvider() {
    loadEconomyData();
  }

  Future<void> loadEconomyData() async {
    if (_economyData.isNotEmpty || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final String response = await rootBundle.loadString('assets/economy_data.json');
      final List<dynamic> data = json.decode(response) as List<dynamic>;
      _economyData = data.map((item) => EconomyData.fromJson(item as Map<String, dynamic>)).toList();

      await _loadEconomicsTriviaData();

    } catch (e) {
      debugPrint("Error loading economy data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadEconomicsTriviaData() async {
    try {
      final String response = await rootBundle.loadString('assets/economics_trivia.json');
      final Map<String, dynamic> data = json.decode(response);
      final Map<String, Map<String, double>> processedData = {};

      data.forEach((category, list) {
        final cropList = list as List;
        final Map<String, double> cropMap = {};
        for (var item in cropList) {
          String? iso;

          // 🆕 이제 iso_a3만 확인하면 됩니다.
          if (item.containsKey('iso_a3')) {
            iso = item['iso_a3'] as String;
          }

          if (iso != null) {
            // iso_a3 키를 제외한 다른 값 키를 찾습니다.
            final valueKey = item.keys.firstWhere(
                    (k) => k != 'iso_a3',
                orElse: () => '');

            if (valueKey.isNotEmpty) {
              cropMap[iso] = (item[valueKey] as num).toDouble();
            }
          }
        }
        processedData[category] = cropMap;
      });

      _economicsTriviaData = processedData;

    } catch (e) {
      debugPrint('Economics Trivia Data Error: $e');
    }
  }
}