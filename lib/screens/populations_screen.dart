// lib/screens/populations_screen.dart
import 'package:flutter/material.dart';
import 'package:jidoapp/models/city_model.dart';
import 'package:jidoapp/providers/city_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class PopulationsScreen extends StatelessWidget {
  const PopulationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CityProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final compactFormatter = NumberFormat.compact();
          final themeColor = Colors.teal;

          final visitedCities = provider.allCities.where((c) {
            return provider.visitedCities.contains(c.name);
          }).toList();

          final totalVisitedCities = visitedCities.length;

          int totalVisitedPopulation = 0;
          for (var city in visitedCities) {
            totalVisitedPopulation += city.population;
          }

          final double averageVisitedPopulation =
          totalVisitedCities > 0 ? totalVisitedPopulation / totalVisitedCities : 0.0;

          int over10m = 0;
          int between1mAnd10m = 0;
          int between100kAnd1m = 0;
          int under100k = 0;

          for (var city in visitedCities) {
            if (city.population >= 10000000) {
              over10m++;
            } else if (city.population >= 1000000) {
              between1mAnd10m++;
            } else if (city.population >= 100000) {
              between100kAnd1m++;
            } else {
              under100k++;
            }
          }

          final double percentOver10m =
          totalVisitedCities == 0 ? 0 : (over10m / totalVisitedCities) * 100;
          final double percent1mTo10m =
          totalVisitedCities == 0 ? 0 : (between1mAnd10m / totalVisitedCities) * 100;
          final double percent100kTo1m =
          totalVisitedCities == 0 ? 0 : (between100kAnd1m / totalVisitedCities) * 100;
          final double percentUnder100k =
          totalVisitedCities == 0 ? 0 : (under100k / totalVisitedCities) * 100;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🎨 통계 카드들
                Row(
                  children: [
                    Expanded(
                      child: _buildModernStatCard(
                        icon: Icons.people_alt_rounded,
                        title: 'Total Population',
                        value: compactFormatter.format(totalVisitedPopulation),
                        color: themeColor,
                        context: context,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildModernStatCard(
                        icon: Icons.analytics_rounded,
                        title: 'Average',
                        value: compactFormatter.format(averageVisitedPopulation.round()),
                        color: Colors.deepPurple,
                        context: context,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 🎨 인구 티어 분석 타이틀
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.bar_chart_rounded,
                        color: themeColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Population Distribution',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 🎨 3D 막대그래프
                _buildModern3DBarChart(
                  [over10m, between1mAnd10m, between100kAnd1m, under100k],
                  themeColor,
                  context,
                ),
                const SizedBox(height: 20),

                // 🎨 원형 진행바 티어 정보
                Row(
                  children: [
                    Expanded(
                      child: _buildModernTierInfo(
                        percentOver10m.toStringAsFixed(1),
                        over10m,
                        '10M+',
                        themeColor,
                        context,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildModernTierInfo(
                        percent1mTo10m.toStringAsFixed(1),
                        between1mAnd10m,
                        '1-10M',
                        Colors.blue.shade600,
                        context,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildModernTierInfo(
                        percent100kTo1m.toStringAsFixed(1),
                        between100kAnd1m,
                        '100K-1M',
                        Colors.orange.shade600,
                        context,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildModernTierInfo(
                        percentUnder100k.toStringAsFixed(1),
                        under100k,
                        '<100K',
                        Colors.grey.shade600,
                        context,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 🎨 랭킹 카드 (고정 높이)
                SizedBox(
                  height: 600,
                  child: _CombinedRankingCard(
                    cityProvider: provider,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🎨 통계 카드
  Widget _buildModernStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color.withOpacity(0.9),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }

  // 🎨 티어 정보 카드
  Widget _buildModernTierInfo(
      String percentage,
      int count,
      String label,
      Color color,
      BuildContext context,
      ) {
    final percentValue = double.tryParse(percentage) ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  value: percentValue / 100,
                  strokeWidth: 4,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text(
                '$percentage%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '($count)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // 🎨 3D 막대그래프
  Widget _buildModern3DBarChart(List<int> counts, Color color, BuildContext context) {
    final maxCount = counts.isEmpty ? 1 : counts.reduce(max);
    if (maxCount == 0) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: Text(
            'No visited cities',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final labels = ['10M+', '1-10M', '100K-1M', '<100K'];

    return SizedBox(
      height: 90,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(counts.length, (index) {
          final height = (counts[index] / maxCount) * 50;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (counts[index] > 0)
                    Text(
                      '${counts[index]}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Container(
                    height: height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color,
                          color.withOpacity(0.6),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    labels[index],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
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
  int _displaySegment = 0;
  String _selectedContinent = 'World';
  List<City> _rankedList = [];

  final List<String> _continents = [
    'World',
    'Asia',
    'Europe',
    'Africa',
    'North America',
    'South America',
    'Oceania'
  ];

  @override
  void initState() {
    super.initState();
    _prepareList();
  }

  void _prepareList() {
    List<City> listToRank;
    if (_displaySegment == 0) {
      listToRank = List.from(widget.cityProvider.allCities);
    } else {
      listToRank = widget.cityProvider.allCities
          .where((c) => widget.cityProvider.visitedCities.contains(c.name))
          .toList();
    }

    if (_selectedContinent != 'World') {
      listToRank = listToRank.where((c) => c.continent == _selectedContinent).toList();
    }

    listToRank.sort((a, b) => b.population.compareTo(a.population));

    if (mounted) {
      setState(() {
        _rankedList = listToRank;
      });
    }
  }

  void _onFilterChanged() => setState(() => _prepareList());

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final compactFormatter = NumberFormat.compact();
    final topPopulation = _rankedList.isNotEmpty ? _rankedList.first.population : 1;
    final useDefaultColor = widget.cityProvider.useDefaultCityRankingBarColor;
    final themeColor = Colors.teal;

    final Map<String, Color> _continentColors = {
      'Asia': Colors.pink.shade400,
      'Europe': Colors.amber.shade600,
      'Africa': Colors.brown.shade400,
      'North America': Colors.blue.shade400,
      'South America': Colors.green.shade500,
      'Oceania': Colors.purple.shade400,
    };

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 🎨 필터 섹션
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            color: Colors.grey.shade50,
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.groups, color: themeColor),
                    const SizedBox(width: 12),
                    Text(
                      'Population Ranking',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<int>(
                        showSelectedIcon: false,
                        style: SegmentedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          selectedForegroundColor: Colors.white,
                          selectedBackgroundColor: themeColor.withOpacity(0.8),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey.shade300, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 6,
                          ),
                        ),
                        segments: const [
                          ButtonSegment<int>(
                            value: 0,
                            label: Text('All'),
                          ),
                          ButtonSegment<int>(
                            value: 1,
                            label: Text('Visited'),
                          ),
                        ],
                        selected: {_displaySegment},
                        onSelectionChanged: (s) {
                          _displaySegment = s.first;
                          _onFilterChanged();
                        },
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: DropdownButton<String>(
                    value: _selectedContinent,
                    items: _continents
                        .map((String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ))
                        .toList(),
                    onChanged: (String? newValue) {
                      _selectedContinent = newValue!;
                      _onFilterChanged();
                    },
                    underline: const SizedBox(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // 🎨 랭킹 리스트
          Expanded(
            child: _rankedList.isEmpty
                ? const Center(child: Text('No data to display.'))
                : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _rankedList.length > 100 ? 100 : _rankedList.length,
              itemBuilder: (context, index) {
                final city = _rankedList[index];
                final isVisited =
                widget.cityProvider.visitedCities.contains(city.name);
                final rank = index + 1;
                final barColor = useDefaultColor
                    ? themeColor
                    : (_continentColors[city.continent] ?? themeColor);

                return Card(
                  elevation: 0,
                  color: isVisited
                      ? themeColor.withOpacity(0.12)
                      : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              '$rank',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      city.name,
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (isVisited)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            barColor,
                                            barColor.withOpacity(0.8),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: barColor.withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Visited',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              compactFormatter.format(city.population),
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        LayoutBuilder(
                          builder: (context, constraints) => Stack(
                            children: [
                              Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              Container(
                                height: 6,
                                width: constraints.maxWidth *
                                    (city.population / topPopulation),
                                decoration: BoxDecoration(
                                  color: barColor,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ],
                          ),
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