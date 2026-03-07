import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:jidoapp/models/country_model.dart'; // 패키지명 확인하세요

class HomeWidgetService {
  static const String androidWidgetName = 'TravelogWidget'; // AndroidManifest.xml과 일치해야 함

  // 이 함수를 호출하면 위젯 화면을 그려서 저장하고 업데이트 신호를 보냅니다.
  static Future<void> updateWidget({
    required BuildContext context,
    required List<Country> visitedCountries,
    required Uint8List? mapImage, // 현재 보고 있는 지도를 캡쳐한 이미지
  }) async {
    // 1. 위젯으로 그릴 UI 생성 (CountriesShare 디자인 적용)
    final widget = _buildWidgetUI(context, visitedCountries, mapImage);

    // 2. 이미지를 파일로 저장 (파일명: widget_image)
    // 안드로이드 Kotlin 코드에서 "filename" 키로 이 경로를 찾습니다.
    await HomeWidget.renderFlutterWidget(
      widget,
      key: 'filename',
      logicalSize: const Size(600, 400), // 위젯 크기
      pixelRatio: 2.0, // 화질
    );

    // 3. 안드로이드에 업데이트 요청
    await HomeWidget.updateWidget(
      name: androidWidgetName,
      androidName: androidWidgetName,
    );
  }

  // ===========================================================================
  // 👇 디자인 영역 (CountriesShare.dart 스타일을 그대로 가져옴)
  // ===========================================================================

  static Widget _buildWidgetUI(
      BuildContext context,
      List<Country> visitedCountries,
      Uint8List? mapImage,
      ) {
    // 통계 계산
    final continentStats = _calculateContinentStats(visitedCountries);
    final continentTotals = {
      'Asia': 48, 'Europe': 44, 'Africa': 54,
      'North America': 23, 'South America': 12, 'Oceania': 14,
    };

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.transparent, // 배경 투명
        body: Container(
          width: 600,
          height: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. 헤더 (로고 + 카운트)
              _buildHeader(visitedCountries.length),

              const SizedBox(height: 12),

              // 2. 지도 영역 (이미지가 있으면 표시, 없으면 로딩/빈공간)
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    width: double.infinity,
                    child: mapImage != null
                        ? Image.memory(mapImage, fit: BoxFit.cover)
                        : Container(
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: Icon(Icons.map, color: Colors.grey, size: 40),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 3. 통계 그리드
              Expanded(
                flex: 2,
                child: _buildStatsGrid(continentStats, continentTotals),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // 로고 대신 아이콘 사용 (에셋 로드 문제 방지)
            const Icon(Icons.public, color: Colors.blue, size: 28),
            const SizedBox(width: 8),
            const Text(
              'Travelog',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count Countries',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.blue),
          ),
        ),
      ],
    );
  }

  static Widget _buildStatsGrid(Map<String, int> stats, Map<String, int> totals) {
    return Column(
      children: [
        Expanded(child: Row(children: [
          _buildSimpleCard('Asia', stats['Asia'] ?? 0, totals['Asia']!),
          const SizedBox(width: 8),
          _buildSimpleCard('Europe', stats['Europe'] ?? 0, totals['Europe']!),
          const SizedBox(width: 8),
          _buildSimpleCard('Africa', stats['Africa'] ?? 0, totals['Africa']!),
        ])),
        const SizedBox(height: 8),
        Expanded(child: Row(children: [
          _buildSimpleCard('N. America', stats['North America'] ?? 0, totals['North America']!),
          const SizedBox(width: 8),
          _buildSimpleCard('S. America', stats['South America'] ?? 0, totals['South America']!),
          const SizedBox(width: 8),
          _buildSimpleCard('Oceania', stats['Oceania'] ?? 0, totals['Oceania']!),
        ])),
      ],
    );
  }

  static Widget _buildSimpleCard(String name, int count, int total) {
    // CountriesShare의 색상 로직 적용
    Color barColor = Colors.grey;
    if (name.contains('Asia')) barColor = Colors.pink.shade300;
    else if (name.contains('Europe')) barColor = Colors.yellow.shade700;
    else if (name.contains('Africa')) barColor = Colors.brown.shade400;
    else if (name.contains('N. America')) barColor = Colors.blue.shade400;
    else if (name.contains('S. America')) barColor = Colors.green.shade400;
    else if (name.contains('Oceania')) barColor = Colors.purple.shade400;

    double ratio = total > 0 ? count / total : 0.0;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            const Spacer(),
            Text('$count/$total', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: barColor)),
            const SizedBox(height: 4),
            // 진행률 바
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: ratio,
                backgroundColor: Colors.grey.shade200,
                color: barColor,
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Map<String, int> _calculateContinentStats(List<Country> countries) {
    final stats = <String, int>{};
    for (var country in countries) {
      final continent = country.continent;
      if (continent != null && continent.isNotEmpty) {
        stats[continent] = (stats[continent] ?? 0) + 1;
      }
    }
    return stats;
  }
}