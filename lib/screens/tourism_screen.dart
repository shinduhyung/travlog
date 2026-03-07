// lib/screens/tourism_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:jidoapp/models/city_model.dart';
import 'package:jidoapp/providers/city_provider.dart';
import 'package:jidoapp/screens/city_transportation_screen.dart';
import 'package:jidoapp/screens/city_stats_map_screen.dart';

class RankingInfo {
  final String title;
  final IconData icon;
  final Color themeColor;
  final String metricKey;
  final num Function(City) valueAccessor;

  RankingInfo({
    required this.title,
    required this.icon,
    required this.themeColor,
    required this.metricKey,
    required this.valueAccessor,
  });
}

class TourismScreen extends StatelessWidget {
  const TourismScreen({super.key});

  static final Map<String, Color> continentColors = {
    'Asia': Colors.pink.shade200,
    'Europe': Colors.amber,
    'Africa': Colors.brown,
    'North America': Colors.blue.shade200,
    'South America': Colors.green,
    'Oceania': Colors.purple,
  };

  static const List<String> _tabs = ['Tourism', 'Transportation'];
  static const Map<String, IconData> _tabIcons = {
    'Tourism': Icons.tour,
    'Transportation': Icons.directions_bus,
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
              _TourismTabContent(),
              CityTransportationScreen(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TourismTabContent extends StatelessWidget {
  const _TourismTabContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<CityProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _CombinedRankingCard(cityProvider: provider),
              const SizedBox(height: 24),
              _ExpandableCityCard(
                title: 'Top Instagram Posted',
                icon: Icons.camera_alt,
                color: Colors.pink,
                cities: provider.instagramCities,
                visitedCityNames: provider.visitedCities,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CombinedRankingCard extends StatefulWidget {
  final CityProvider cityProvider;
  const _CombinedRankingCard({required this.cityProvider});

  @override
  State<_CombinedRankingCard> createState() => _CombinedRankingCardState();
}

class _CombinedRankingCardState extends State<_CombinedRankingCard> {
  late final List<RankingInfo> _rankings;
  late RankingInfo _selectedRanking;

  String _selectedContinent = 'World';
  List<City> _rankedList = [];

  final List<String> _continents = ['World', 'Asia', 'Europe', 'Africa', 'North America', 'South America', 'Oceania'];

  @override
  void initState() {
    super.initState();
    _rankings = [
      RankingInfo(title: 'Annual Visitors Ranking', icon: Icons.group, themeColor: Colors.orange, metricKey: 'visitors', valueAccessor: (c) => c.annualVisitors),
      RankingInfo(title: 'Starbucks Store Ranking', icon: Icons.store, themeColor: Colors.green, metricKey: 'starbucks', valueAccessor: (c) => c.starbucksCount),
      RankingInfo(title: 'Tourists Per Resident', icon: Icons.person_pin_circle, themeColor: Colors.purple, metricKey: 'ratio', valueAccessor: (c) => c.cityTouristRatio),
    ];
    _selectedRanking = _rankings.first;
    _prepareList();
  }

  void _prepareList() {
    List<City> listToRank;
    String metric = _selectedRanking.metricKey;

    if (metric == 'visitors') {
      listToRank = List.from(widget.cityProvider.allCities);
      if (_selectedContinent != 'World') {
        listToRank = listToRank.where((c) => c.continent == _selectedContinent).toList();
      }
      listToRank.sort((a, b) => _selectedRanking.valueAccessor(b).compareTo(_selectedRanking.valueAccessor(a)));
    } else if (metric == 'starbucks') {
      listToRank = List.from(widget.cityProvider.starbucksCities);
      listToRank.sort((a, b) => _selectedRanking.valueAccessor(b).compareTo(_selectedRanking.valueAccessor(a)));
    } else if (metric == 'ratio') {
      listToRank = widget.cityProvider.allCities.where((c) => c.cityTouristRatio > 0.0).toList();
      listToRank.sort((a, b) => _selectedRanking.valueAccessor(b).compareTo(_selectedRanking.valueAccessor(a)));
    } else {
      listToRank = [];
    }

    setState(() {
      int takeCount = (metric == 'visitors' && _selectedContinent != 'World') ? 10 : 30;
      _rankedList = listToRank.take(takeCount).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final compactFormatter = NumberFormat.compact();
    final decimalFormatter = NumberFormat('0.00');

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
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<RankingInfo>(
                          value: _selectedRanking,
                          isExpanded: true,
                          icon: Icon(Icons.arrow_drop_down_circle_outlined, color: _selectedRanking.themeColor),
                          items: _rankings.map((r) => DropdownMenuItem(
                            value: r,
                            child: Row(children: [
                              Icon(r.icon, color: r.themeColor), const SizedBox(width: 12),
                              Text(r.title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            ]),
                          )).toList(),
                          onChanged: (value) {
                            if (value != null) setState(() { _selectedRanking = value; _prepareList(); });
                          },
                        ),
                      ),
                    ),
                    // ⭐️ 상단 랭킹 지도 버튼이 제거되었습니다.
                  ],
                ),
                if (_selectedRanking.metricKey == 'visitors')
                  Align(
                    alignment: Alignment.centerRight,
                    child: DropdownButton<String>(
                      value: _selectedContinent,
                      items: _continents.map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 14)))).toList(),
                      onChanged: (v) => setState(() { _selectedContinent = v!; _prepareList(); }),
                      underline: const SizedBox(),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          SizedBox(
            height: 400,
            child: _rankedList.isEmpty
                ? const Center(child: Text('No data to display.'))
                : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _rankedList.length,
              itemBuilder: (context, index) {
                final city = _rankedList[index];
                final isVisited = widget.cityProvider.visitedCities.contains(city.name);
                final rank = index + 1;
                final value = _selectedRanking.valueAccessor(city);

                final themeColor = _selectedRanking.themeColor;
                final barColor = widget.cityProvider.useDefaultCityRankingBarColor
                    ? themeColor
                    : TourismScreen.continentColors[city.continent] ?? themeColor;

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
                              width: 32,
                              height: 32,
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
                                  Text(city.name, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 17)),
                                  Text(city.country, style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _selectedRanking.metricKey == 'ratio' ? decimalFormatter.format(value) : compactFormatter.format(value),
                              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade800),
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
    final displayCities = widget.cities;
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
                          // ⭐️ 인스타그램 지도 버튼은 유지됩니다.
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