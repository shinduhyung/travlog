// lib/screens/city_geography_screen.dart

import 'package:flutter/material.dart';
import 'package:jidoapp/models/city_model.dart';
import 'package:jidoapp/providers/city_provider.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:jidoapp/screens/city_climate_screen.dart';
import 'package:jidoapp/screens/city_stats_map_screen.dart'; // 🗺️ CityStatsMapScreen 임포트

// Map and UI packages
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:jidoapp/my_tile_layer.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

// --- Data Classes ---
class RankingInfo {
  final String title;
  final IconData icon;
  final Color themeColor;
  final String metricKey;
  final num Function(City) valueAccessor;
  final String unit;
  final int precision;
  final bool absValue;

  const RankingInfo({
    required this.title,
    required this.icon,
    required this.themeColor,
    required this.metricKey,
    required this.valueAccessor,
    this.unit = '',
    this.precision = 2,
    this.absValue = false,
  });
}

// MapFilter Enum
enum MapFilter { all, visited }

// ====================================================================
// Main Integration Screen (CityGeographyStatsScreen)
// ====================================================================

class CityGeographyStatsScreen extends StatelessWidget {
  const CityGeographyStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.from(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.yellow,
        ),
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            elevation: 1,
            automaticallyImplyLeading: false,
            title: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.public, size: 20), text: 'Geography'),
                Tab(icon: Icon(Icons.thermostat, size: 20), text: 'Climate'),
              ],
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              indicatorSize: TabBarIndicatorSize.tab,
              labelPadding: EdgeInsets.zero,
            ),
          ),
          body: const TabBarView(
            children: [
              CityGeographyTabScreen(),
              CityClimateTabScreen(),
            ],
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// Geography Tab Content
// ====================================================================

class CityGeographyTabScreen extends StatelessWidget {
  const CityGeographyTabScreen({super.key});

  static final Map<String, Color> continentColors = {
    'Asia': Colors.pink.shade200, 'Europe': Colors.amber, 'Africa': Colors.brown,
    'North America': Colors.blue.shade200, 'South America': Colors.green, 'Oceania': Colors.purple,
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<CityProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final visitedCities = provider.allCities.where((city) => provider.visitedCities.contains(city.name)).toList();
        final visitedCityNames = provider.visitedCities;

        City? mostNorthern, mostSouthern, mostEastern, mostWestern;
        double avgLat = 0.0;
        double avgLon = 0.0;
        City? closestCityToCenter;

        if (visitedCities.isNotEmpty) {
          mostNorthern = visitedCities.reduce((a, b) => a.latitude > b.latitude ? a : b);
          mostSouthern = visitedCities.reduce((a, b) => a.latitude < b.latitude ? a : b);
          mostEastern = visitedCities.reduce((a, b) => a.longitude > b.longitude ? a : b);
          mostWestern = visitedCities.reduce((a, b) => a.longitude < b.longitude ? a : b);

          double sumLat = 0.0;
          double sumLon = 0.0;
          for (var city in visitedCities) {
            sumLat += city.latitude;
            sumLon += city.longitude;
          }
          avgLat = sumLat / visitedCities.length;
          avgLon = sumLon / visitedCities.length;

          double minDistanceSq = double.infinity;
          for (var city in visitedCities) {
            final distanceSq = math.pow(city.latitude - avgLat, 2) + math.pow(city.longitude - avgLon, 2);
            if (distanceSq < minDistanceSq) {
              minDistanceSq = distanceSq.toDouble();
              closestCityToCenter = city;
            }
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (visitedCities.isNotEmpty) ...[
                _buildSectionHeader(context, 'Geographic Center'),
                Card(
                  elevation: 2,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildCenterInfoCard(
                            context,
                            title: 'Average',
                            value: '${avgLat.toStringAsFixed(2)}°, ${avgLon.toStringAsFixed(2)}°',
                            subValue: null,
                            icon: Icons.public,
                            color: Colors.teal,
                          ),
                          const SizedBox(width: 12),
                          _buildCenterInfoCard(
                            context,
                            title: 'Closest City',
                            value: closestCityToCenter?.name ?? 'N/A',
                            subValue: closestCityToCenter?.country,
                            icon: Icons.location_city_rounded,
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildSectionHeader(context, 'Visited Extremes'),
                Card(
                  elevation: 2,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildExtremeCard(context, title: 'Northernmost', city: mostNorthern, icon: Icons.north, color: Colors.blue),
                              const SizedBox(width: 12),
                              _buildExtremeCard(context, title: 'Southernmost', city: mostSouthern, icon: Icons.south, color: Colors.lightBlueAccent),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildExtremeCard(context, title: 'Easternmost', city: mostEastern, icon: Icons.east, color: Colors.orange),
                              const SizedBox(width: 12),
                              _buildExtremeCard(context, title: 'Westernmost', city: mostWestern, icon: Icons.west, color: Colors.deepOrangeAccent),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // 랭킹 카드 (지도 버튼 없음)
              _CombinedRankingCard(
                allCities: provider.allCities,
                visitedCityNames: provider.visitedCities,
              ),
              const SizedBox(height: 32),

              // Special Geography Lists (지도 버튼 포함)
              _SpecialCityGroupCard(
                title: 'Tropic of Cancer',
                icon: Icons.wb_sunny,
                color: Colors.orange,
                cities: provider.capitalsOnTropicOfCancer,
                visitedCityNames: visitedCityNames,
              ),
              const SizedBox(height: 16),

              _SpecialCityGroupCard(
                title: 'Two Hemispheres',
                icon: Icons.language,
                color: Colors.pink,
                cities: provider.capitalsInTwoHemispheres,
                visitedCityNames: visitedCityNames,
              ),
              const SizedBox(height: 16),

              _SpecialCityGroupCard(
                title: 'Transcontinental',
                icon: Icons.map,
                color: Colors.purpleAccent,
                cities: provider.transcontinentalCities,
                visitedCityNames: visitedCityNames,
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
      ),
    );
  }

  Widget _buildCenterInfoCard(BuildContext context, {
    required String title,
    required String value,
    required String? subValue,
    required IconData icon,
    required Color color,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Card(
        elevation: 0,
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(title, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              if (subValue != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    subValue,
                    style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExtremeCard(BuildContext context, {
    required String title,
    required City? city,
    required IconData icon,
    required Color color,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final value = city != null
        ? (title.contains('Northern') || title.contains('Southern')
        ? '${city.latitude.toStringAsFixed(2)}°'
        : '${city.longitude.toStringAsFixed(2)}°')
        : '';

    return Expanded(
      child: Card(
        elevation: 0,
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(title, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              if (city != null) ...[
                Text(
                  city.name,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  city.country,
                  style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    value,
                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: color),
                  ),
                ),
              ] else ...[
                const Spacer(),
                Center(child: Text('N/A', style: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600))),
                const Spacer(),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// 1. Ranking Card (지도 버튼 없음)
// ====================================================================

class _CombinedRankingCard extends StatefulWidget {
  final List<City> allCities;
  final Set<String> visitedCityNames;

  const _CombinedRankingCard({required this.allCities, required this.visitedCityNames});

  @override
  State<_CombinedRankingCard> createState() => _CombinedRankingCardState();
}

class _CombinedRankingCardState extends State<_CombinedRankingCard> {
  late final List<RankingInfo> _rankings;
  late RankingInfo _selectedRanking;
  int _sortSegment = 0;
  List<City> _rankedList = [];

  @override
  void initState() {
    super.initState();
    _rankings = [
      RankingInfo(title: 'Latitude', icon: Icons.public, themeColor: Colors.blue, metricKey: 'latitude', valueAccessor: (c) => c.latitude, unit: '°', absValue: true),
      RankingInfo(title: 'Elevation', icon: Icons.terrain, themeColor: Colors.brown, metricKey: 'altitude', valueAccessor: (c) => c.altitude, unit: 'm', precision: 0),
    ];
    _selectedRanking = _rankings.first;
    _prepareList();
  }

  void _prepareList() {
    List<City> listToRank = widget.allCities.where((c) => _selectedRanking.valueAccessor(c) != 0).toList();

    listToRank.sort((a, b) {
      num valA = _selectedRanking.valueAccessor(a);
      num valB = _selectedRanking.valueAccessor(b);

      if (_selectedRanking.metricKey == 'latitude') {
        return _sortSegment == 0 ? valB.compareTo(valA) : valA.compareTo(valB);
      }

      if (_selectedRanking.absValue) {
        valA = valA.abs();
        valB = valB.abs();
      }
      return _sortSegment == 0 ? valB.compareTo(valA) : valA.compareTo(valB);
    });

    setState(() {
      _rankedList = listToRank.take(30).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final useDefaultColor = Provider.of<CityProvider>(context, listen: false).useDefaultCityRankingBarColor;

    num topValue = 1.0;
    if (_rankedList.isNotEmpty) {
      topValue = _selectedRanking.valueAccessor(_rankedList.first);
      if (_selectedRanking.absValue) topValue = topValue.abs();
    }

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
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
                        Icon(r.icon, color: r.themeColor), const SizedBox(width: 12),
                        Text(r.title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
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
            height: 350,
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _rankedList.length,
              itemBuilder: (context, index) {
                final item = _rankedList[index];
                final isVisited = widget.visitedCityNames.contains(item.name);
                final rank = index + 1;
                num value = _selectedRanking.valueAccessor(item);

                final themeColor = _selectedRanking.themeColor;
                final barColor = useDefaultColor ? themeColor : (CityGeographyTabScreen.continentColors[item.continent] ?? themeColor);

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
                            Text('${value.toStringAsFixed(_selectedRanking.precision)}${_selectedRanking.unit}', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: (topValue == 0 ? 0 : (_selectedRanking.absValue ? value.abs() : value) / topValue).toDouble(),
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
// 2. Reusable Special Group Card (지도 버튼 추가)
// ====================================================================

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

                          // 🗺️ 지도 버튼 추가 (랭킹에는 없음)
                          IconButton(
                            icon: const Icon(Icons.map, color: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CityStatsMapScreen(
                                    cities: sortedCities,
                                    title: widget.title,
                                    markerColor: widget.color, // 통계 테마 색상 전달
                                  ),
                                ),
                              );
                            },
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

// ====================================================================
// 3. Generic City Map Screen (호환성 유지용)
// ====================================================================

class _GenericCityMapScreen extends StatefulWidget {
  final String title;
  final List<City> cities;
  final Set<String> visitedCityNames;
  const _GenericCityMapScreen({required this.title, required this.cities, required this.visitedCityNames});

  @override
  State<_GenericCityMapScreen> createState() => _GenericCityMapScreenState();
}

class _GenericCityMapScreenState extends State<_GenericCityMapScreen> {
  City? _selectedCity;
  MapFilter _mapFilter = MapFilter.visited;

  @override
  Widget build(BuildContext context) {
    final visitedCities = widget.visitedCityNames;
    final citiesForMapPins = _mapFilter == MapFilter.visited ? widget.cities.where((c) => visitedCities.contains(c.name)).toList() : widget.cities;
    final citiesForList = List<City>.from(widget.cities)..sort((a, b) => a.name.compareTo(b.name));

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    cameraConstraint: CameraConstraint.contain(bounds: LatLngBounds(const LatLng(-60, -180), const LatLng(85, 180))),
                    initialZoom: 2.0,
                    interactionOptions: const InteractionOptions(flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom | InteractiveFlag.doubleTapZoom),
                    onTap: (_, __) => setState(() => _selectedCity = null),
                  ),
                  children: [
                    const MyTileLayer(),
                    _buildCityMarkers(citiesForMapPins, visitedCities),
                    if (_selectedCity != null)
                      MarkerLayer(markers: [Marker(point: LatLng(_selectedCity!.latitude, _selectedCity!.longitude), width: 200, height: 50, child: _buildInfoPopup(_selectedCity!))])
                  ],
                ),
                Positioned(
                  top: 8, right: 8,
                  child: Card(
                    elevation: 2, color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9), shape: const StadiumBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: [
                          ChoiceChip(label: const Text('All'), selected: _mapFilter == MapFilter.all, onSelected: (selected) { if (selected) setState(() => _mapFilter = MapFilter.all); }, showCheckmark: false, labelStyle: TextStyle(fontSize: 11, color: _mapFilter == MapFilter.all ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface), selectedColor: Theme.of(context).primaryColor, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
                          const SizedBox(width: 2),
                          ChoiceChip(label: const Text('Visited'), selected: _mapFilter == MapFilter.visited, onSelected: (selected) { if (selected) setState(() => _mapFilter = MapFilter.visited); }, showCheckmark: false, labelStyle: TextStyle(fontSize: 11, color: _mapFilter == MapFilter.visited ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface), selectedColor: Theme.of(context).primaryColor, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildCityList(context, citiesForList, visitedCities)),
        ],
      ),
    );
  }

  Widget _buildInfoPopup(City city) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(child: Text(city.name, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
            IconButton(icon: const Icon(Icons.close, size: 18), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => setState(() => _selectedCity = null))
          ],
        ),
      ),
    );
  }

  Widget _buildCityMarkers(List<City> cities, Set<String> visited) {
    final markers = cities.map((city) {
      final isVisited = visited.contains(city.name);
      return Marker(
        width: 40, height: 40, point: LatLng(city.latitude, city.longitude),
        child: GestureDetector(
          onTap: () => setState(() => _selectedCity = city),
          child: Tooltip(
            message: city.name,
            child: Icon(Icons.location_on, color: isVisited ? Colors.red : Colors.red.withOpacity(0.5), size: 30, shadows: const [Shadow(color: Colors.black54, blurRadius: 4.0)]),
          ),
        ),
      );
    }).toList();
    return MarkerLayer(markers: markers);
  }

  Widget _buildCityList(BuildContext context, List<City> cities, Set<String> visitedCities) {
    final total = cities.length;
    final visitedCount = cities.where((c) => visitedCities.contains(c.name)).length;
    final percentage = total > 0 ? (visitedCount / total) : 0.0;

    return Card(
      margin: EdgeInsets.zero, elevation: 4.0, shape: const RoundedRectangleBorder(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Visited Cities in List', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: LinearProgressIndicator(value: percentage, borderRadius: BorderRadius.circular(5), minHeight: 10)),
                    const SizedBox(width: 16),
                    Text('$visitedCount / $total (${(percentage * 100).toStringAsFixed(0)}%)'),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: cities.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final city = cities[index];
                final isVisited = visitedCities.contains(city.name);
                return ListTile(
                  title: Text(city.name),
                  subtitle: Text(city.country),
                  trailing: isVisited ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor) : const Icon(Icons.check_circle_outline, color: Colors.grey),
                  onTap: () { Provider.of<CityProvider>(context, listen: false).toggleVisitedStatus(city.name); },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}