// lib/screens/city_history_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jidoapp/models/city_model.dart';
import 'package:jidoapp/providers/city_provider.dart';
import 'package:jidoapp/screens/city_stats_map_screen.dart';
import 'package:collection/collection.dart';

class CityHistoryTabScreen extends StatefulWidget {
  const CityHistoryTabScreen({super.key});

  static final Map<String, Color> continentColors = {
    'Asia': Colors.pink.shade200,
    'Europe': Colors.amber,
    'Africa': Colors.brown,
    'North America': Colors.blue.shade200,
    'South America': Colors.green,
    'Oceania': Colors.purple,
  };

  @override
  State<CityHistoryTabScreen> createState() => _CityHistoryTabScreenState();
}

class _CityHistoryTabScreenState extends State<CityHistoryTabScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CityProvider>(
      builder: (context, cityProvider, child) {
        if (cityProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final allOldestCitiesData = cityProvider.oldestCities.where((c) => c.altitude != 0).toList();
        final visitedCityNames = cityProvider.visitedCities;
        final useDefaultColor = cityProvider.useDefaultCityRankingBarColor;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OldestCityRankingCard(
                allData: allOldestCitiesData,
                visitedNames: visitedCityNames,
                useDefaultColor: useDefaultColor,
              ),
              const SizedBox(height: 16),
              _FormerImperialCapitalsCard(
                visitedNames: visitedCityNames,
                cityProvider: cityProvider,
              ),
            ],
          ),
        );
      },
    );
  }
}

class CityHistoryScreen extends StatelessWidget {
  const CityHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) => const CityHistoryTabScreen();
}

class _OldestCityRankingCard extends StatefulWidget {
  final List<City> allData;
  final Set<String> visitedNames;
  final bool useDefaultColor;

  const _OldestCityRankingCard({
    required this.allData,
    required this.visitedNames,
    required this.useDefaultColor,
  });

  @override
  State<_OldestCityRankingCard> createState() => _OldestCityRankingCardState();
}

class _OldestCityRankingCardState extends State<_OldestCityRankingCard> {
  List<City> _rankedList = [];
  String _selectedContinent = 'World';
  final List<String> _continents = ['World', 'Asia', 'Europe', 'Africa', 'North America', 'South America', 'Oceania'];

  @override
  void initState() {
    super.initState();
    _prepareList();
  }

  void _prepareList() {
    List<City> listToRank = _selectedContinent == 'World'
        ? List<City>.from(widget.allData)
        : widget.allData.where((c) => c.continent == _selectedContinent).toList();
    listToRank.sort((a, b) => a.altitude.compareTo(b.altitude));
    setState(() {
      _rankedList = listToRank.take(_selectedContinent == 'World' ? 30 : 10).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final topValue = _rankedList.isNotEmpty ? _rankedList.first.altitude.abs() : 1;
    const themeColor = Colors.brown;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            color: Colors.grey.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history, color: themeColor),
                    const SizedBox(width: 12),
                    Text('Oldest City Ranking',
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedContinent,
                    items: _continents.map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 14)))).toList(),
                    onChanged: (v) { if (v != null) { setState(() { _selectedContinent = v; _prepareList(); }); } },
                  ),
                ),
                // ⭐️ 이 위치에 있던 지도 IconButton 삭제됨
              ],
            ),
          ),
          const Divider(height: 1),
          SizedBox(
            height: 400,
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _rankedList.length,
              itemBuilder: (context, index) {
                final item = _rankedList[index];
                final age = item.altitude;
                final isVisited = widget.visitedNames.contains(item.name);
                final rank = index + 1;
                final barColor = widget.useDefaultColor ? themeColor : CityHistoryTabScreen.continentColors[item.continent] ?? themeColor;

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
                              width: 32, height: 32, alignment: Alignment.center,
                              decoration: BoxDecoration(color: themeColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                              child: Text('$rank', style: textTheme.bodyMedium?.copyWith(color: themeColor.withOpacity(0.8), fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(item.name, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 17)),
                              Text(item.country, style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                            ])),
                            Text(age < 0 ? '${age.abs()} BC' : '$age AD', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: topValue == 0 ? 0 : (age.abs() / topValue).toDouble(),
                          borderRadius: BorderRadius.circular(5), minHeight: 5,
                          backgroundColor: barColor.withOpacity(0.1), color: barColor.withOpacity(0.7),
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

class _FormerImperialCapitalsCard extends StatefulWidget {
  final Set<String> visitedNames;
  final CityProvider cityProvider;

  const _FormerImperialCapitalsCard({required this.visitedNames, required this.cityProvider});

  @override
  State<_FormerImperialCapitalsCard> createState() => _FormerImperialCapitalsCardState();
}

class _FormerImperialCapitalsCardState extends State<_FormerImperialCapitalsCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _rotationController;

  static const List<String> _imperialCapitals = [
    "Rome", "Istanbul", "Beijing", "Xi'an", "Baghdad", "Damascus", "Cairo",
    "Alexandria", "Athens", "Vienna", "Saint Petersburg", "Moscow", "Berlin",
    "Paris", "London", "Madrid", "Tokyo",
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
      if (_isExpanded) _rotationController.forward();
      else _rotationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final total = _imperialCapitals.length;
    final visitedCount = _imperialCapitals.where((city) => widget.visitedNames.contains(city)).length;
    const themeColor = Colors.purple;

    final List<City> mapCities = _imperialCapitals
        .map((name) => widget.cityProvider.allCities.firstWhereOrNull((c) => c.name == name))
        .whereType<City>().toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(gradient: LinearGradient(colors: [themeColor.withOpacity(0.7), themeColor])),
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
                            child: const Icon(Icons.account_balance, size: 24, color: Colors.white),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Text('Former Imperial Capitals', style: textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold))),
                          IconButton(
                            icon: const Icon(Icons.map, color: Colors.white),
                            onPressed: () => Navigator.push(context, MaterialPageRoute(
                                builder: (context) => CityStatsMapScreen(
                                  cities: mapCities,
                                  title: 'Imperial Capitals',
                                  markerColor: themeColor,
                                )
                            )),
                          ),
                          RotationTransition(
                            turns: Tween(begin: 0.0, end: 0.5).animate(_rotationController),
                            child: const Icon(Icons.expand_more, color: Colors.white, size: 24),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Cities visited', style: textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.9))),
                            Row(children: [
                              Text('$visitedCount', style: textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text(' / $total', style: textTheme.titleLarge?.copyWith(color: Colors.white.withOpacity(0.8))),
                            ]),
                          ])),
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
            child: _isExpanded
                ? Padding(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                spacing: 8, runSpacing: 8,
                children: _imperialCapitals.map((city) {
                  final isVisited = widget.visitedNames.contains(city);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isVisited ? LinearGradient(colors: [themeColor.withOpacity(0.6), themeColor.withOpacity(0.8)]) : null,
                      color: isVisited ? null : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: isVisited ? Border.all(color: themeColor, width: 1.5) : null,
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      if (isVisited) ...[const Icon(Icons.check_circle, size: 16, color: Colors.white), const SizedBox(width: 4)],
                      Text(city, style: TextStyle(fontSize: 13, fontWeight: isVisited ? FontWeight.w600 : FontWeight.w500, color: isVisited ? Colors.white : Colors.grey.shade700)),
                    ]),
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