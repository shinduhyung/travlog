// lib/screens/city_sports_screen.dart

import 'package:flutter/material.dart';
import 'package:jidoapp/providers/city_provider.dart';
import 'package:provider/provider.dart';
import 'package:jidoapp/models/city_model.dart';
import 'package:jidoapp/screens/city_stats_map_screen.dart'; // 🗺️ 지도 화면 임포트
import 'package:collection/collection.dart';

class CitySportsScreen extends StatelessWidget {
  const CitySportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CityProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _CristianoRonaldoCard(visitedNames: provider.visitedCities, provider: provider),
            const SizedBox(height: 16),
            _LionelMessiCard(visitedNames: provider.visitedCities, provider: provider),
            const SizedBox(height: 16),
            _ZlatanIbrahimovicCard(visitedNames: provider.visitedCities, provider: provider),
            const SizedBox(height: 16),
            _SummerOlympicsCard(visitedNames: provider.visitedCities, cities: provider.summerOlympicsCities, provider: provider),
            const SizedBox(height: 16),
            _WinterOlympicsCard(visitedNames: provider.visitedCities, cities: provider.winterOlympicsCities, provider: provider),
            const SizedBox(height: 16),
            _NFLCitiesCard(visitedNames: provider.visitedCities, cities: provider.nflCities, provider: provider),
            const SizedBox(height: 16),
            _NBACitiesCard(visitedNames: provider.visitedCities, cities: provider.nbaCities, provider: provider),
            const SizedBox(height: 16),
            _MLBCitiesCard(visitedNames: provider.visitedCities, cities: provider.mlbCities, provider: provider),
            const SizedBox(height: 16),
            _NHLCitiesCard(visitedNames: provider.visitedCities, cities: provider.nhlCities, provider: provider),
            const SizedBox(height: 16),
            _MLSCitiesCard(visitedNames: provider.visitedCities, cities: provider.mlsCities, provider: provider),
            const SizedBox(height: 16),
            _TennisGrandSlamCard(visitedNames: provider.visitedCities, provider: provider),
          ],
        );
      },
    );
  }
}

// --- Helper widget builder (지도 버튼 로직 통합) ---
Widget _buildExpandableCard({
  required BuildContext context,
  required String title,
  required IconData icon,
  required Color themeColor,
  required List<String> cityNames,
  required Set<String> visitedNames,
  required bool isExpanded,
  required VoidCallback onToggle,
  required AnimationController rotationController,
  required CityProvider provider, // 🗺️ City 조회를 위해 추가
}) {
  final textTheme = Theme.of(context).textTheme;
  final total = cityNames.length;
  final visitedCount = cityNames.where((city) => visitedNames.contains(city)).length;
  final percentage = total > 0 ? (visitedCount / total) : 0.0;

  // 🗺️ 지도용 City 리스트 생성
  final List<City> mapCities = cityNames
      .map((name) => provider.allCities.firstWhereOrNull((c) => c.name == name))
      .whereType<City>().toList();

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
              onTap: onToggle,
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
                          child: Icon(icon, size: 24, color: Colors.white),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            title,
                            style: textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // 🗺️ 지도 버튼 추가
                        IconButton(
                          icon: const Icon(Icons.map, color: Colors.white),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(
                              builder: (context) => CityStatsMapScreen(
                                cities: mapCities,
                                title: title,
                                markerColor: themeColor,
                              )
                          )),
                        ),

                        const SizedBox(width: 8),
                        RotationTransition(
                          turns: Tween(begin: 0.0, end: 0.5).animate(rotationController),
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
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 70,
                                height: 70,
                                child: CircularProgressIndicator(
                                  value: percentage,
                                  strokeWidth: 6,
                                  backgroundColor: Colors.white.withOpacity(0.3),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              Text(
                                '${(percentage * 100).toInt()}%',
                                style: textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
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
          child: isExpanded
              ? Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: cityNames.map((city) {
                final isVisited = visitedNames.contains(city);
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

// --- 1. Cristiano Ronaldo Card ---
class _CristianoRonaldoCard extends StatefulWidget {
  final Set<String> visitedNames;
  final CityProvider provider;
  const _CristianoRonaldoCard({required this.visitedNames, required this.provider});

  @override
  State<_CristianoRonaldoCard> createState() => _CristianoRonaldoCardState();
}

class _CristianoRonaldoCardState extends State<_CristianoRonaldoCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _rotationController;
  static const List<String> _cities = ['Manchester', 'Riyadh', 'Madrid', 'Lisbon', 'Turin'];

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

  @override
  Widget build(BuildContext context) {
    return _buildExpandableCard(
      context: context,
      title: 'Cristiano Ronaldo',
      icon: Icons.sports_soccer,
      themeColor: Colors.red,
      cityNames: _cities,
      visitedNames: widget.visitedNames,
      isExpanded: _isExpanded,
      onToggle: () => setState(() {
        _isExpanded = !_isExpanded;
        if (_isExpanded) _rotationController.forward(); else _rotationController.reverse();
      }),
      rotationController: _rotationController,
      provider: widget.provider,
    );
  }
}

// --- 2. Lionel Messi Card ---
class _LionelMessiCard extends StatefulWidget {
  final Set<String> visitedNames;
  final CityProvider provider;
  const _LionelMessiCard({required this.visitedNames, required this.provider});

  @override
  State<_LionelMessiCard> createState() => _LionelMessiCardState();
}

class _LionelMessiCardState extends State<_LionelMessiCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _rotationController;
  static const List<String> _cities = ['Barcelona', 'Paris', 'Miami'];

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

  @override
  Widget build(BuildContext context) {
    return _buildExpandableCard(
      context: context,
      title: 'Lionel Messi',
      icon: Icons.sports_soccer,
      themeColor: Colors.lightBlue,
      cityNames: _cities,
      visitedNames: widget.visitedNames,
      isExpanded: _isExpanded,
      onToggle: () => setState(() {
        _isExpanded = !_isExpanded;
        if (_isExpanded) _rotationController.forward(); else _rotationController.reverse();
      }),
      rotationController: _rotationController,
      provider: widget.provider,
    );
  }
}

// --- 3. Zlatan Ibrahimović Card ---
class _ZlatanIbrahimovicCard extends StatefulWidget {
  final Set<String> visitedNames;
  final CityProvider provider;
  const _ZlatanIbrahimovicCard({required this.visitedNames, required this.provider});

  @override
  State<_ZlatanIbrahimovicCard> createState() => _ZlatanIbrahimovicCardState();
}

class _ZlatanIbrahimovicCardState extends State<_ZlatanIbrahimovicCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _rotationController;
  static const List<String> _cities = ['Malmö', 'Amsterdam', 'Turin', 'Milan', 'Barcelona', 'Paris', 'Manchester', 'Los Angeles'];

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

  @override
  Widget build(BuildContext context) {
    return _buildExpandableCard(
      context: context,
      title: 'Zlatan Ibrahimović',
      icon: Icons.sports_soccer,
      themeColor: Colors.blue,
      cityNames: _cities,
      visitedNames: widget.visitedNames,
      isExpanded: _isExpanded,
      onToggle: () => setState(() {
        _isExpanded = !_isExpanded;
        if (_isExpanded) _rotationController.forward(); else _rotationController.reverse();
      }),
      rotationController: _rotationController,
      provider: widget.provider,
    );
  }
}

// --- 4. Summer Olympics Card ---
class _SummerOlympicsCard extends StatefulWidget {
  final Set<String> visitedNames;
  final List cities;
  final CityProvider provider;
  const _SummerOlympicsCard({required this.visitedNames, required this.cities, required this.provider});

  @override
  State<_SummerOlympicsCard> createState() => _SummerOlympicsCardState();
}

class _SummerOlympicsCardState extends State<_SummerOlympicsCard> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    final cityNames = widget.cities.map((c) => c.name as String).toList()..sort();
    return _buildExpandableCard(
      context: context,
      title: 'Summer Olympics Hosts',
      icon: Icons.directions_run,
      themeColor: Colors.amber,
      cityNames: cityNames,
      visitedNames: widget.visitedNames,
      isExpanded: _isExpanded,
      onToggle: () => setState(() {
        _isExpanded = !_isExpanded;
        if (_isExpanded) _rotationController.forward(); else _rotationController.reverse();
      }),
      rotationController: _rotationController,
      provider: widget.provider,
    );
  }
}

// --- 5. Winter Olympics Card ---
class _WinterOlympicsCard extends StatefulWidget {
  final Set<String> visitedNames;
  final List cities;
  final CityProvider provider;
  const _WinterOlympicsCard({required this.visitedNames, required this.cities, required this.provider});

  @override
  State<_WinterOlympicsCard> createState() => _WinterOlympicsCardState();
}

class _WinterOlympicsCardState extends State<_WinterOlympicsCard> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    final cityNames = widget.cities.map((c) => c.name as String).toList()..sort();
    return _buildExpandableCard(
      context: context,
      title: 'Winter Olympics Hosts',
      icon: Icons.snowboarding,
      themeColor: Colors.lightBlue,
      cityNames: cityNames,
      visitedNames: widget.visitedNames,
      isExpanded: _isExpanded,
      onToggle: () => setState(() {
        _isExpanded = !_isExpanded;
        if (_isExpanded) _rotationController.forward(); else _rotationController.reverse();
      }),
      rotationController: _rotationController,
      provider: widget.provider,
    );
  }
}

// --- 6. NFL Cities Card ---
class _NFLCitiesCard extends StatefulWidget {
  final Set<String> visitedNames;
  final List cities;
  final CityProvider provider;
  const _NFLCitiesCard({required this.visitedNames, required this.cities, required this.provider});

  @override
  State<_NFLCitiesCard> createState() => _NFLCitiesCardState();
}

class _NFLCitiesCardState extends State<_NFLCitiesCard> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    final cityNames = widget.cities.map((c) => c.name as String).toList()..sort();
    return _buildExpandableCard(
      context: context,
      title: 'NFL Cities',
      icon: Icons.sports_football,
      themeColor: Colors.brown.shade800,
      cityNames: cityNames,
      visitedNames: widget.visitedNames,
      isExpanded: _isExpanded,
      onToggle: () => setState(() {
        _isExpanded = !_isExpanded;
        if (_isExpanded) _rotationController.forward(); else _rotationController.reverse();
      }),
      rotationController: _rotationController,
      provider: widget.provider,
    );
  }
}

// --- 7. NBA Cities Card ---
class _NBACitiesCard extends StatefulWidget {
  final Set<String> visitedNames;
  final List cities;
  final CityProvider provider;
  const _NBACitiesCard({required this.visitedNames, required this.cities, required this.provider});

  @override
  State<_NBACitiesCard> createState() => _NBACitiesCardState();
}

class _NBACitiesCardState extends State<_NBACitiesCard> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    final cityNames = widget.cities.map((c) => c.name as String).toList()..sort();
    return _buildExpandableCard(
      context: context,
      title: 'NBA Cities',
      icon: Icons.sports_basketball,
      themeColor: Colors.orange,
      cityNames: cityNames,
      visitedNames: widget.visitedNames,
      isExpanded: _isExpanded,
      onToggle: () => setState(() {
        _isExpanded = !_isExpanded;
        if (_isExpanded) _rotationController.forward(); else _rotationController.reverse();
      }),
      rotationController: _rotationController,
      provider: widget.provider,
    );
  }
}

// --- 8. MLB Cities Card ---
class _MLBCitiesCard extends StatefulWidget {
  final Set<String> visitedNames;
  final List cities;
  final CityProvider provider;
  const _MLBCitiesCard({required this.visitedNames, required this.cities, required this.provider});

  @override
  State<_MLBCitiesCard> createState() => _MLBCitiesCardState();
}

class _MLBCitiesCardState extends State<_MLBCitiesCard> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    final cityNames = widget.cities.map((c) => c.name as String).toList()..sort();
    return _buildExpandableCard(
      context: context,
      title: 'MLB Cities',
      icon: Icons.sports_baseball,
      themeColor: Colors.green.shade800,
      cityNames: cityNames,
      visitedNames: widget.visitedNames,
      isExpanded: _isExpanded,
      onToggle: () => setState(() {
        _isExpanded = !_isExpanded;
        if (_isExpanded) _rotationController.forward(); else _rotationController.reverse();
      }),
      rotationController: _rotationController,
      provider: widget.provider,
    );
  }
}

// --- 9. NHL Cities Card ---
class _NHLCitiesCard extends StatefulWidget {
  final Set<String> visitedNames;
  final List cities;
  final CityProvider provider;
  const _NHLCitiesCard({required this.visitedNames, required this.cities, required this.provider});

  @override
  State<_NHLCitiesCard> createState() => _NHLCitiesCardState();
}

class _NHLCitiesCardState extends State<_NHLCitiesCard> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    final cityNames = widget.cities.map((c) => c.name as String).toList()..sort();
    return _buildExpandableCard(
      context: context,
      title: 'NHL Cities',
      icon: Icons.sports_hockey,
      themeColor: Colors.red.shade800,
      cityNames: cityNames,
      visitedNames: widget.visitedNames,
      isExpanded: _isExpanded,
      onToggle: () => setState(() {
        _isExpanded = !_isExpanded;
        if (_isExpanded) _rotationController.forward(); else _rotationController.reverse();
      }),
      rotationController: _rotationController,
      provider: widget.provider,
    );
  }
}

// --- 10. MLS Cities Card ---
class _MLSCitiesCard extends StatefulWidget {
  final Set<String> visitedNames;
  final List cities;
  final CityProvider provider;
  const _MLSCitiesCard({required this.visitedNames, required this.cities, required this.provider});

  @override
  State<_MLSCitiesCard> createState() => _MLSCitiesCardState();
}

class _MLSCitiesCardState extends State<_MLSCitiesCard> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    final cityNames = widget.cities.map((c) => c.name as String).toList()..sort();
    return _buildExpandableCard(
      context: context,
      title: 'MLS Cities',
      icon: Icons.sports_soccer,
      themeColor: Colors.teal,
      cityNames: cityNames,
      visitedNames: widget.visitedNames,
      isExpanded: _isExpanded,
      onToggle: () => setState(() {
        _isExpanded = !_isExpanded;
        if (_isExpanded) _rotationController.forward(); else _rotationController.reverse();
      }),
      rotationController: _rotationController,
      provider: widget.provider,
    );
  }
}

// --- 11. Tennis Grand Slam Card ---
class _TennisGrandSlamCard extends StatefulWidget {
  final Set<String> visitedNames;
  final CityProvider provider;
  const _TennisGrandSlamCard({required this.visitedNames, required this.provider});

  @override
  State<_TennisGrandSlamCard> createState() => _TennisGrandSlamCardState();
}

class _TennisGrandSlamCardState extends State<_TennisGrandSlamCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _rotationController;
  static const List<String> _cities = ["Melbourne", "Paris", "London", "New York City"];

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

  @override
  Widget build(BuildContext context) {
    return _buildExpandableCard(
      context: context,
      title: 'Tennis Grand Slam',
      icon: Icons.sports_tennis,
      themeColor: Colors.green,
      cityNames: _cities,
      visitedNames: widget.visitedNames,
      isExpanded: _isExpanded,
      onToggle: () => setState(() {
        _isExpanded = !_isExpanded;
        if (_isExpanded) _rotationController.forward(); else _rotationController.reverse();
      }),
      rotationController: _rotationController,
      provider: widget.provider,
    );
  }
}