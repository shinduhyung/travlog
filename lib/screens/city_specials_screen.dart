// lib/screens/city_specials_screen.dart

import 'package:flutter/material.dart';
import 'package:jidoapp/models/city_model.dart';
import 'package:jidoapp/providers/city_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// 🚨 지도 화면 및 스포츠 스크린 임포트
import 'package:jidoapp/screens/city_sports_screen.dart';
import 'package:jidoapp/screens/city_stats_map_screen.dart';

// ====================================================================
// 데이터 클래스 및 Enum 정의
// ====================================================================

// RankingInfo (Specials에서 사용)
class RankingInfo {
  final String title;
  final IconData icon;
  final Color themeColor;
  final num Function(dynamic) valueAccessor;
  final String metricKey;
  final String unit;

  const RankingInfo({
    required this.title,
    required this.icon,
    required this.themeColor,
    required this.valueAccessor,
    this.metricKey = '',
    this.unit = '',
  });
}

// SpecialGroupInfo class (Sports 등에서 사용될 수 있음)
class SpecialGroupInfo {
  final String title;
  final IconData icon;
  final Color themeColor;
  final List<City> cities;

  SpecialGroupInfo({
    required this.title,
    required this.icon,
    required this.themeColor,
    required this.cities,
  });
}

// MapFilter enum
enum MapFilter { all, visited }

// 대륙별 색상 데이터
final Map<String, Color> continentColors = {
  'Asia': Colors.pink.shade200,
  'Europe': Colors.amber,
  'Africa': Colors.brown,
  'North America': Colors.blue.shade200,
  'South America': Colors.green,
  'Oceania': Colors.purple,
};

// ====================================================================
// 메인 통합 스크린 (CitySpecialsScreen)
// ====================================================================

class CitySpecialsScreen extends StatelessWidget {
  const CitySpecialsScreen({super.key});

  static const List<String> _tabs = ['Specials', 'Sports'];
  static const Map<String, IconData> _tabIcons = {
    'Specials': Icons.auto_awesome,
    'Sports': Icons.sports_soccer,
  };

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.from(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.yellow,
        ),
      ),
      child: DefaultTabController(
        length: _tabs.length,
        child: Scaffold(
          appBar: AppBar(
            elevation: 1,
            automaticallyImplyLeading: false,
            title: TabBar(
              tabs: _tabs.map((title) => Tab(
                icon: Icon(_tabIcons[title], size: 20),
                text: title,
              )).toList(),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              indicatorSize: TabBarIndicatorSize.tab,
              labelPadding: EdgeInsets.zero,
            ),
          ),
          body: const TabBarView(
            children: [
              _SpecialsTabContent(),
              CitySportsScreen(),
            ],
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// Specials 탭 내용
// ====================================================================

class _SpecialsTabContent extends StatelessWidget {
  const _SpecialsTabContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<CityProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final visitedCities = provider.visitedCities;

        // 데이터 준비
        final allSkyscraperData = provider.skyscraperCities.where((c) => c.skyscraperCount != 0).toList();
        final allHollywoodData = provider.hollywoodCities.where((c) => c.hollywoodScore != 0.0).toList();
        final useDefaultColor = provider.useDefaultCityRankingBarColor;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 상단 랭킹 카드 (지도 버튼 없음)
              _SpecialsCombinedRankingCard(
                skyscraperData: allSkyscraperData,
                hollywoodData: allHollywoodData,
                visitedNames: visitedCities,
                useDefaultColor: useDefaultColor,
              ),

              const SizedBox(height: 24),

              // 2. Special 항목들 (Expandable Cards - 지도 버튼 포함)
              _ExpandableCityCard(
                title: 'Int’l Film Festivals',
                icon: Icons.local_movies,
                color: Colors.redAccent,
                cities: provider.majorFilmFestivalCities,
                visitedCityNames: visitedCities,
              ),
              const SizedBox(height: 16),
              _ExpandableCityCard(
                title: 'Country Name Identical',
                icon: Icons.flag,
                color: Colors.indigo,
                cities: provider.countryNameIdenticalToCapital,
                visitedCityNames: visitedCities,
              ),
              const SizedBox(height: 16),
              _ExpandableCityCard(
                title: 'Capital with "City"',
                icon: Icons.location_city,
                color: Colors.teal,
                cities: provider.capitalsWithCityInName,
                visitedCityNames: visitedCities,
              ),
              const SizedBox(height: 16),
              _ExpandableCityCard(
                title: 'High Similarity Names',
                icon: Icons.compare_arrows,
                color: Colors.deepOrange,
                cities: provider.countryCapitalHighSimilarity,
                visitedCityNames: visitedCities,
              ),
              const SizedBox(height: 16),
              _ExpandableCityCard(
                title: 'Former Capitals',
                icon: Icons.history,
                color: Colors.brown,
                cities: provider.formerCapitalRelocations,
                visitedCityNames: visitedCities,
              ),
              const SizedBox(height: 16),
              _ExpandableCityCard(
                title: 'Planned Capitals',
                icon: Icons.architecture,
                color: Colors.blueGrey,
                cities: provider.plannedCapitals,
                visitedCityNames: visitedCities,
              ),
              const SizedBox(height: 16),
              _ExpandableCityCard(
                title: 'City-States',
                icon: Icons.location_on,
                color: Colors.deepPurple,
                cities: provider.cityStates,
                visitedCityNames: visitedCities,
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

// ====================================================================
// 1. 상단 랭킹 카드 (지도 버튼 없음)
// ====================================================================

class _SpecialsCombinedRankingCard extends StatefulWidget {
  final List<City> skyscraperData;
  final List<City> hollywoodData;
  final Set<String> visitedNames;
  final bool useDefaultColor;

  const _SpecialsCombinedRankingCard({
    required this.skyscraperData,
    required this.hollywoodData,
    required this.visitedNames,
    required this.useDefaultColor,
  });

  @override
  State<_SpecialsCombinedRankingCard> createState() => _SpecialsCombinedRankingCardState();
}

class _SpecialsCombinedRankingCardState extends State<_SpecialsCombinedRankingCard> {
  late final List<RankingInfo> _rankings;
  late RankingInfo _selectedRanking;
  List<City> _rankedList = [];

  @override
  void initState() {
    super.initState();
    _rankings = [
      RankingInfo(title: 'Skyscraper Count', icon: Icons.location_city, themeColor: Colors.blueGrey, valueAccessor: (c) => (c as City).skyscraperCount, metricKey: 'skyscraper'),
      RankingInfo(title: 'Hollywood Filming Location', icon: Icons.movie, themeColor: Colors.amber, valueAccessor: (c) => (c as City).hollywoodScore, metricKey: 'hollywood'),
    ];
    _selectedRanking = _rankings.first;
    _prepareList();
  }

  void _prepareList() {
    List<City> listToRank;
    if (_selectedRanking.metricKey == 'skyscraper') {
      listToRank = List<City>.from(widget.skyscraperData);
    } else {
      listToRank = List<City>.from(widget.hollywoodData);
    }

    listToRank.sort((a, b) => _selectedRanking.valueAccessor(b).compareTo(_selectedRanking.valueAccessor(a)));

    setState(() {
      _rankedList = listToRank.take(30).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final compactFormatter = NumberFormat.compact();
    final topValue = _rankedList.isNotEmpty ? _selectedRanking.valueAccessor(_rankedList.first) : 1;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            color: Colors.grey.shade50,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<RankingInfo>(
                value: _selectedRanking,
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down_circle_outlined, color: _selectedRanking.themeColor),
                items: _rankings.map((r) => DropdownMenuItem(
                  value: r,
                  child: Row(children: [
                    Icon(r.icon, color: r.themeColor),
                    const SizedBox(width: 12),
                    Text(r.title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ]),
                )).toList(),
                onChanged: (value) {
                  if (value != null) setState(() { _selectedRanking = value; _prepareList(); });
                },
              ),
            ),
          ),
          const Divider(height: 1),
          SizedBox(
            height: 350,
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _rankedList.length,
              itemBuilder: (context, index) {
                final item = _rankedList[index];
                final value = _selectedRanking.valueAccessor(item);
                final isVisited = widget.visitedNames.contains(item.name);
                final rank = index + 1;

                final themeColor = _selectedRanking.themeColor;
                final barColor = widget.useDefaultColor
                    ? themeColor
                    : continentColors[item.continent] ?? themeColor;

                return Card(
                  elevation: 0,
                  color: isVisited ? themeColor.withOpacity(0.08) : Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32, height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: themeColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$rank',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: themeColor.withOpacity(0.8),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 17)),
                                  Text(item.country, style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _selectedRanking.metricKey == 'hollywood' ? value.toInt().toString() : compactFormatter.format(value),
                              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: topValue == 0 ? 0 : value.toDouble() / topValue.toDouble(),
                          borderRadius: BorderRadius.circular(5),
                          minHeight: 5,
                          backgroundColor: barColor.withOpacity(0.1),
                          color: barColor.withOpacity(0.7),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// 2. 재사용 가능한 Special Group Card (지도 기능 추가 버전)
// ====================================================================

class _ExpandableCityCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<City> cities;
  final Set<String> visitedCityNames;

  const _ExpandableCityCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.cities,
    required this.visitedCityNames,
  });

  @override
  State<_ExpandableCityCard> createState() => _ExpandableCityCardState();
}

class _ExpandableCityCardState extends State<_ExpandableCityCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) _rotationController.forward(); else _rotationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final displayCities = List<City>.from(widget.cities)..sort((a, b) => a.name.compareTo(b.name));
    final total = displayCities.length;
    final visitedCount = displayCities.where((c) => widget.visitedCityNames.contains(c.name)).length;
    final percentage = total > 0 ? (visitedCount / total) : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [widget.color.withOpacity(0.7), widget.color],
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggleExpanded,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(12)),
                            child: Icon(widget.icon, size: 24, color: Colors.white),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Text(widget.title, style: textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold))),

                          // 🗺️ 지도 버튼 추가
                          IconButton(
                            icon: const Icon(Icons.map, color: Colors.white),
                            onPressed: () => Navigator.push(context, MaterialPageRoute(
                                builder: (context) => CityStatsMapScreen(
                                  cities: displayCities,
                                  title: widget.title,
                                  markerColor: widget.color,
                                )
                            )),
                          ),

                          const SizedBox(width: 8),
                          RotationTransition(turns: Tween(begin: 0.0, end: 0.5).animate(_rotationController), child: const Icon(Icons.expand_more, color: Colors.white, size: 24)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Cities visited', style: textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500)),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text('$visitedCount', style: textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                                    Text(' / $total', style: textTheme.titleLarge?.copyWith(color: Colors.white.withOpacity(0.8))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 70, height: 70,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(width: 70, height: 70, child: CircularProgressIndicator(value: percentage, strokeWidth: 6, backgroundColor: Colors.white.withOpacity(0.3), valueColor: const AlwaysStoppedAnimation<Color>(Colors.white))),
                                Text('${(percentage * 100).toInt()}%', style: textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Padding(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                spacing: 8, runSpacing: 8,
                children: displayCities.map((city) {
                  final isVisited = widget.visitedCityNames.contains(city.name);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isVisited ? LinearGradient(colors: [widget.color.withOpacity(0.6), widget.color.withOpacity(0.8)]) : null,
                      color: isVisited ? null : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: isVisited ? Border.all(color: widget.color, width: 1.5) : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isVisited) ...[const Icon(Icons.check_circle, size: 16, color: Colors.white), const SizedBox(width: 4)],
                        Text(city.name, style: TextStyle(fontSize: 13, fontWeight: isVisited ? FontWeight.w600 : FontWeight.w500, color: isVisited ? Colors.white : Colors.grey.shade700)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}