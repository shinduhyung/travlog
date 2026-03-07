// lib/providers/language_provider.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:jidoapp/models/language_data_model.dart';

class LanguageProvider with ChangeNotifier {
  bool _isLoading = true;
  Map<String, LanguageData> _languageDataMap = {};

  bool get isLoading => _isLoading;
  Map<String, LanguageData> get languageDataMap => _languageDataMap;

  LanguageProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    final String jsonStr = await rootBundle.loadString('assets/language_data.json');
    final Map<String, dynamic> decodedJson = json.decode(jsonStr);

    _languageDataMap = decodedJson.map((key, value) {
      return MapEntry(key, LanguageData.fromJson(value));
    });

    _isLoading = false;
    notifyListeners();
  }
}