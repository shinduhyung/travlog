import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:jidoapp/models/country_model.dart';
import 'package:path_provider/path_provider.dart';

enum WidgetType { countries, cities, flights }

class HomeWidgetService {
  static Future<void> updateWidget({
    required Uint8List? widgetImage,
    List<Country>? visitedCountries,
    WidgetType widgetType = WidgetType.countries,
  }) async {
    if (widgetImage == null) return;
    try {
      final fileKey = switch (widgetType) {
        WidgetType.countries => 'filename',
        WidgetType.cities    => 'cities_filename',
        WidgetType.flights   => 'flights_filename',
      };
      final widgetName = switch (widgetType) {
        WidgetType.countries => 'TravelogWidget',
        WidgetType.cities    => 'TravelogCitiesWidget',
        WidgetType.flights   => 'TravelogFlightsWidget',
      };
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileKey.png');
      await file.writeAsBytes(widgetImage);
      await HomeWidget.saveWidgetData<String>(fileKey, file.path);
      await HomeWidget.updateWidget(name: widgetName, androidName: widgetName);
    } catch (e) {
      debugPrint('🚨 [widgetdebug] ❌ 실패: $e');
    }
  }
}