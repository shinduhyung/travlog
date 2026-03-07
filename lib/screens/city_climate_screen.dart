// lib/screens/city_climate_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:jidoapp/models/city_model.dart';
import 'package:jidoapp/providers/city_provider.dart';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:jidoapp/screens/city_geography_screen.dart';
import 'package:jidoapp/screens/city_stats_map_screen.dart'; // 🗺️ 지도 화면 임포트

class RankingInfo {
  final String title;
  final IconData icon;
  final Color themeColor;
  final num Function(City) valueAccessor;
  final String unit;

  const RankingInfo({
    required this.title,
    required this.icon,
    required this.themeColor,
    required this.valueAccessor,
    this.unit = '',
  });
}

class CityClimateTabScreen extends StatelessWidget {
  const CityClimateTabScreen({super.key});

  static final Map<String, Color> continentColors = CityGeographyTabScreen.continentColors;

  @override
  Widget build(BuildContext context) {
    return Consumer<CityProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final visitedCityNames = provider.visitedCities;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 랭킹 카드 (지도 버튼 없음)
              _CombinedRankingCard(
                allCities: provider.allCities,
                visitedCityNames: provider.visitedCities,
                useDefaultColor: provider.useDefaultCityRankingBarColor,
              ),

              const SizedBox(height: 32),

              // 기후/고도 관련 리스트 (지도 버튼 추가)
              _SpecialCityGroupCard(
                title: 'Below Sea Level',
                icon: Icons.water,
                color: Colors.blue,
                cities: provider.capitalsBelowSeaLevel,
                visitedCityNames: visitedCityNames,
              ),
              const SizedBox(height: 16),
              _SpecialCityGroupCard(
                title: 'On Major Rivers',
                icon: Icons.water_drop,
                color: Colors.lightBlue,
                cities: provider.capitalsOnMajorRivers,
                visitedCityNames: visitedCityNames,
              ),
              const SizedBox(height: 16),
              _SpecialCityGroupCard(
                title: 'Elevation > 1,000m',
                icon: Icons.landscape,
                color: Colors.green,
                cities: provider.capitalsAbove1000m,
                visitedCityNames: visitedCityNames,
              ),
              const SizedBox(height: 16),
              _SpecialCityGroupCard(
                title: 'Hot Desert Climate',
                icon: Icons.public,
                color: Colors.amber,
                cities: provider.capitalsHotDesertClimate,
                visitedCityNames: visitedCityNames,
              ),
              const SizedBox(height: 16),
              _SpecialCityGroupCard(
                title: 'No Seasonal Snowfall',
                icon: Icons.ac_unit_outlined,
                color: Colors.cyan,
                cities: provider.capitalsNoSeasonalSnowfall,
                visitedCityNames: visitedCityNames,
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

class CityClimateScreen extends StatelessWidget {
  const CityClimateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CityClimateTabScreen();
  }
}

class _CombinedRankingCard extends StatefulWidget {
  final List<City> allCities;
  final Set<String> visitedCityNames;
  final bool useDefaultColor;

  const _CombinedRankingCard({
    required this.allCities,
    required this.visitedCityNames,
    required this.useDefaultColor,
  });

  @override
  State<_CombinedRankingCard> createState() => _CombinedRankingCardState();
}

class _CombinedRankingCardState extends State<_CombinedRankingCard> {
  late final List<RankingInfo> _rankings;
  late RankingInfo _selectedRanking;
  int _sortSegment = 0; // 0 for High, 1 for Low
  List<City> _rankedList = [];

  @override
  void initState() {
    super.initState();
    _rankings = [
      RankingInfo(title: 'Average Temperature', icon: Icons.thermostat, themeColor: Colors.orange, valueAccessor: (c) => c.avgTemp, unit: '°C'),
      RankingInfo(title: 'Average Precipitation', icon: Icons.water_drop, themeColor: Colors.blue, valueAccessor: (c) => c.avgPrecipitation, unit: 'mm'),
    ];
    _selectedRanking = _rankings.first;
    _prepareList();
  }

  void _prepareList() {
    List<City> listToRank = widget.allCities.where((c) => _selectedRanking.valueAccessor(c) != 0.0).toList();

    listToRank.sort((a, b) {
      num valA = _selectedRanking.valueAccessor(a);
      num valB = _selectedRanking.valueAccessor(b);
      return _sortSegment == 0 ? valB.compareTo(valA) : valA.compareTo(valB);
    });

    setState(() {
      _rankedList = listToRank.take(30).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final topValue = _rankedList.isNotEmpty
        ? _rankedList.map((c) => _selectedRanking.valueAccessor(c).abs()).reduce(math.max)
        : 1.0;

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
            child: Column(
              children: [
                DropdownButtonHideUnderline(
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
                    onChanged: (value) => setState(() { _selectedRanking = value!; _prepareList(); }),
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<int>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment<int>(value: 0, label: Text('High')),
                    ButtonSegment<int>(value: 1, label: Text('Low')),
                  ],
                  selected: {_sortSegment},
                  onSelectionChanged: (s) => setState(() { _sortSegment = s.first; _prepareList(); }),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SizedBox(
            height: 400,
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _rankedList.length,
              itemBuilder: (context, index) {
                final item = _rankedList[index];
                final isVisited = widget.visitedCityNames.contains(item.name);
                final rank = index + 1;
                final value = _selectedRanking.valueAccessor(item);

                final themeColor = _selectedRanking.themeColor;
                final barColor = widget.useDefaultColor ? themeColor : (CityGeographyTabScreen.continentColors[item.continent] ?? themeColor);

                return Card(
                  elevation: 0,
                  color: isVisited ? themeColor.withOpacity(0.12) : Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text('#$rank', style: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
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
                            Text('${value.toStringAsFixed(1)}${_selectedRanking.unit}', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: (value.abs() / topValue).clamp(0.0, 1.0),
                          borderRadius: BorderRadius.circular(5),
                          minHeight: 5,
                          backgroundColor: Colors.grey.shade300,
                          color: barColor,
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

class _SpecialCityGroupCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<City> cities;
  final Set<String> visitedCityNames;

  const _SpecialCityGroupCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.cities,
    required this.visitedCityNames,
  });

  @override
  State<_SpecialCityGroupCard> createState() => _SpecialCityGroupCardState();
}

class _SpecialCityGroupCardState extends State<_SpecialCityGroupCard> with SingleTickerProviderStateMixin {
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
    final sortedCities = List<City>.from(widget.cities)..sort((a, b) => a.name.compareTo(b.name));
    final total = sortedCities.length;
    final visitedCount = sortedCities.where((c) => widget.visitedCityNames.contains(c.name)).length;
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
                                  cities: sortedCities,
                                  title: widget.title,
                                  markerColor: widget.color,
                                )
                            )),
                          ),

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
                children: sortedCities.map((city) {
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