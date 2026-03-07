// lib/providers/language_family_provider.dart

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jidoapp/models/language_family_model.dart';

class LanguageFamilyProvider with ChangeNotifier {
  bool _isLoading = true;
  Map<String, LanguageFamilyInfo> _languageFamilyDataMap = {};
  Map<String, Color> _familyColors = {};
  Map<String, Color> _subbranchColors = {};
  Map<String, Color> _subsubbranchColors = {};

  bool get isLoading => _isLoading;
  Map<String, LanguageFamilyInfo> get languageFamilyDataMap => _languageFamilyDataMap;
  Map<String, Color> get familyColors => _familyColors;
  Map<String, Color> get subbranchColors => _subbranchColors;
  Map<String, Color> get subsubbranchColors => _subsubbranchColors;

  LanguageFamilyProvider() {
    _loadLanguageFamilyData();
  }

  Future<void> _loadLanguageFamilyData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/europe_asia_languages.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      // ✅ 1. 데이터 구조화를 위한 계층형 맵 생성
      final Map<String, Map<String, Set<String>>> familyTree = {};

      for (var item in jsonList) {
        final isoA3 = item['iso_a3'] as String;
        final info = LanguageFamilyInfo.fromJson(item);
        _languageFamilyDataMap[isoA3] = info;

        // family -> subbranch -> subsubbranch 계층 구조로 데이터 저장
        familyTree.putIfAbsent(info.family, () => {});
        familyTree[info.family]!.putIfAbsent(info.subbranch, () => {});
        familyTree[info.family]![info.subbranch]!.add(info.subsubbranch);
      }

      // ✅ 2. 계층 구조 기반으로 HSL 색상 생성
      _familyColors = {};
      _subbranchColors = {};
      _subsubbranchColors = {};

      final families = familyTree.keys.toList()..sort();

      for (final familyName in families) {
        if (familyName == 'N/A') {
          _familyColors[familyName] = Colors.grey.shade400;
          continue;
        }

        // Family: 이름의 해시코드를 기반으로 기본 Hue(색상), Saturation(채도), Lightness(밝기) 생성
        final int familyHash = familyName.hashCode;
        final Random familyRandom = Random(familyHash);
        final double baseHue = familyRandom.nextDouble() * 360.0;
        final double baseSaturation = familyRandom.nextDouble() * 0.3 + 0.6; // 0.6 ~ 0.9
        final double baseLightness = familyRandom.nextDouble() * 0.2 + 0.4;  // 0.4 ~ 0.6

        final Color familyColor = HSLColor.fromAHSL(1.0, baseHue, baseSaturation, baseLightness).toColor();
        _familyColors[familyName] = familyColor;

        final branches = familyTree[familyName]!.keys.toList()..sort();
        for (int j = 0; j < branches.length; j++) {
          final branchName = branches[j];
          if (branchName == 'N/A') {
            _subbranchColors[branchName] = Colors.grey.shade400;
            continue;
          }

          // Branch: Family의 Hue, Saturation은 유지하되, Lightness(밝기)에 변형을 줌
          final double lightnessVariation = (branches.length > 1)
              ? (j.toDouble() / (branches.length - 1) * 0.4) - 0.2 // -0.2 ~ +0.2
              : 0;
          final double newLightness = (baseLightness + lightnessVariation).clamp(0.2, 0.8);

          final Color branchColor = HSLColor.fromAHSL(1.0, baseHue, baseSaturation, newLightness).toColor();
          _subbranchColors[branchName] = branchColor;

          final subbranches = familyTree[familyName]![branchName]!.toList()..sort();
          for (int k = 0; k < subbranches.length; k++) {
            final subbranchName = subbranches[k];
            if (subbranchName == 'N/A') {
              _subsubbranchColors[subbranchName] = Colors.grey.shade400;
              continue;
            }

            // Subbranch: Family의 Hue, Branch의 Lightness는 유지하되, Saturation(채도)에 변형을 줌
            final double saturationVariation = (subbranches.length > 1)
                ? (k.toDouble() / (subbranches.length - 1) * 0.5) - 0.25 // -0.25 ~ +0.25
                : 0;
            final double newSaturation = (baseSaturation + saturationVariation).clamp(0.3, 1.0);

            final Color subbranchColor = HSLColor.fromAHSL(1.0, baseHue, newSaturation, newLightness).toColor();
            _subsubbranchColors[subbranchName] = subbranchColor;
          }
        }
      }

    } catch (e) {
      debugPrint("Error loading language family data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

// ✅ 3. 기존 색상 생성 함수들 제거
// _generateColorMap(List<String> items)
// _generateColor(String text)
}