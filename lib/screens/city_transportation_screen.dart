// lib/screens/city_transportation_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jidoapp/models/city_model.dart';
import 'package:jidoapp/providers/city_provider.dart';
import 'package:provider/provider.dart';
import 'package:jidoapp/screens/tourism_screen.dart';
import 'package:jidoapp/screens/city_stats_map_screen.dart'; // 🗺️ CityStatsMapScreen 임포트
import 'package:collection/collection.dart';

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

class CityTransportationScreen extends StatelessWidget {
  const CityTransportationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CityProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final subwayCities = List<City>.from(provider.transportationCities)
          ..sort((a, b) => a.name.compareTo(b.name));

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 랭킹 카드 (지도 버튼 없음)
            _CombinedRankingCard(cityProvider: provider),

            const SizedBox(height: 24),

            // 지하철 보유 도시 (지도 버튼 포함)
            _ExpandableCityCard(
              title: 'Cities with Subway',
              icon: Icons.train,
              color: Colors.blue,
              cities: subwayCities,
              visitedCityNames: provider.visitedCities,
            ),

            const SizedBox(height: 16),

            // 모든 교통수단 보유 도시 (지도 버튼 포함)
            _ExpandableCityCard(
              title: 'Cities with All Major Transit Modes',
              icon: Icons.directions_bus,
              color: Colors.teal,
              cities: provider.allTransitCities,
              visitedCityNames: provider.visitedCities,
            ),

            const SizedBox(height: 16),

            // 4개 이상 공항 보유 도시 (지도 버튼 포함)
            _CitiesWith4PlusAirportsCard(
              visitedNames: provider.visitedCities,
              cityProvider: provider,
            ),
          ],
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
  List<City> _rankedList = [];

  @override
  void initState() {
    super.initState();
    _rankings = [
      RankingInfo(title: 'Metro Station Count', icon: Icons.train, themeColor: Colors.deepPurple, metricKey: 'station', valueAccessor: (c) => c.stationsCount),
      RankingInfo(title: 'Traffic Ranking (per 10km)', icon: Icons.traffic, themeColor: Colors.redAccent, metricKey: 'traffic', valueAccessor: (c) => c.trafficTimeMinutes),
    ];
    _selectedRanking = _rankings.first;
    _prepareList();
  }

  void _prepareList() {
    List<City> listToRank;
    String key = _selectedRanking.metricKey;

    if (key == 'station') {
      listToRank = widget.cityProvider.stationCities.where((c) => c.stationsCount != 0).toList();
      listToRank.sort((a,b) => _selectedRanking.valueAccessor(b).compareTo(_selectedRanking.valueAccessor(a)));
    } else if (key == 'traffic') {
      listToRank = widget.cityProvider.trafficCities.where((c) => c.trafficTimeMinutes != 0).toList();
      listToRank.sort((a,b) => _selectedRanking.valueAccessor(b).compareTo(_selectedRanking.valueAccessor(a)));
    } else {
      listToRank = [];
    }

    setState(() {
      _rankedList = listToRank.take(30).toList();
    });
  }

  String _formatTrafficTime(double totalMinutes) {
    if (totalMinutes < 0.01) return '0s';
    int totalSeconds = (totalMinutes * 60).round();
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    String result = '';
    if (minutes > 0) result += '${minutes}min ';
    result += '${seconds}s';
    return result.trim();
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            color: Colors.grey.shade50,
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
          const Divider(height: 1),
          SizedBox(
            height: 350,
            child: _rankedList.isEmpty
                ? const Center(child: Text('No data available.'))
                : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _rankedList.length,
              itemBuilder: (context, index) {
                final item = _rankedList[index];
                final isVisited = widget.cityProvider.visitedCities.contains(item.name);
                final rank = index + 1;
                final value = _selectedRanking.valueAccessor(item);

                final themeColor = _selectedRanking.themeColor;
                final barColor = widget.cityProvider.useDefaultCityRankingBarColor
                    ? themeColor
                    : TourismScreen.continentColors[item.continent] ?? themeColor;

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
                                  Text(item.name, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 17)),
                                  Text(item.country, style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _selectedRanking.metricKey == 'traffic'
                                  ? _formatTrafficTime(value.toDouble())
                                  : compactFormatter.format(value),
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
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CityStatsMapScreen(
                                    cities: displayCities,
                                    title: widget.title,
                                    markerColor: widget.color,
                                  ),
                                ),
                              );
                            },
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

// 🚨 Cities with 4+ Airports Card
class _CitiesWith4PlusAirportsCard extends StatefulWidget {
  final Set<String> visitedNames;
  final CityProvider cityProvider; // 🆕 데이터 조회를 위해 추가

  const _CitiesWith4PlusAirportsCard({
    required this.visitedNames,
    required this.cityProvider,
  });

  @override
  State<_CitiesWith4PlusAirportsCard> createState() => _CitiesWith4PlusAirportsCardState();
}

class _CitiesWith4PlusAirportsCardState extends State<_CitiesWith4PlusAirportsCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _rotationController;

  static const List<String> _citiesWith4PlusAirports = [
    "New York City",
    "London",
    "Los Angeles",
    "Melbourne",
    "Paris",
    "Moscow",
    "Tokyo",
    "Manila",
    "Stockholm",
    "San Francisco",
    "Dubai",
    "Boston",
  ];

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
      if (_isExpanded) {
        _rotationController.forward();
      } else {
        _rotationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final total = _citiesWith4PlusAirports.length;
    final visitedCount = _citiesWith4PlusAirports.where((city) => widget.visitedNames.contains(city)).length;
    const themeColor = Colors.blue;

    // 🗺️ 지도용 City 객체 리스트 생성
    final List<City> mapCities = _citiesWith4PlusAirports
        .map((name) => widget.cityProvider.allCities.firstWhereOrNull((c) => c.name == name))
        .whereType<City>()
        .toList();

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
                colors: [themeColor.withOpacity(0.7), themeColor],
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
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.flight, size: 24, color: Colors.white),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Cities with 4+ Airports',
                              style: textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // 🗺️ 지도 버튼 추가
                          IconButton(
                            icon: const Icon(Icons.map, color: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CityStatsMapScreen(
                                    cities: mapCities,
                                    title: 'Cities with 4+ Airports',
                                    markerColor: themeColor,
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(width: 8),
                          RotationTransition(
                            turns: Tween(begin: 0.0, end: 0.5).animate(_rotationController),
                            child: const Icon(Icons.expand_more, color: Colors.white, size: 24),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cities visited',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      '$visitedCount',
                                      style: textTheme.headlineMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      ' / $total',
                                      style: textTheme.titleLarge?.copyWith(
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
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
                spacing: 8,
                runSpacing: 8,
                children: _citiesWith4PlusAirports.map((city) {
                  final isVisited = widget.visitedNames.contains(city);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isVisited
                          ? LinearGradient(
                        colors: [
                          themeColor.withOpacity(0.6),
                          themeColor.withOpacity(0.8),
                        ],
                      )
                          : null,
                      color: isVisited ? null : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: isVisited ? Border.all(color: themeColor, width: 1.5) : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isVisited) ...[
                          const Icon(Icons.check_circle, size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          city,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isVisited ? FontWeight.w600 : FontWeight.w500,
                            color: isVisited ? Colors.white : Colors.grey.shade700,
                          ),
                        ),
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