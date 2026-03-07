// lib/screens/city_economy_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:jidoapp/models/city_model.dart';
import 'package:jidoapp/providers/city_provider.dart';

class RankingInfo {
  final String title;
  final IconData icon;
  final Color themeColor;
  final String metricKey;
  final num Function(dynamic) valueAccessor;
  final String unit;

  const RankingInfo({
    required this.title,
    required this.icon,
    required this.themeColor,
    required this.metricKey,
    required this.valueAccessor,
    this.unit = '',
  });
}

class CityEconomyScreen extends StatefulWidget {
  const CityEconomyScreen({super.key});

  static final Map<String, Color> continentColors = {
    'Asia': Colors.pink.shade400,
    'Europe': Colors.amber.shade600,
    'Africa': Colors.brown.shade400,
    'North America': Colors.blue.shade400,
    'South America': Colors.green.shade500,
    'Oceania': Colors.purple.shade400,
  };

  @override
  State<CityEconomyScreen> createState() => _CityEconomyScreenState();
}

class _CityEconomyScreenState extends State<CityEconomyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CityProvider>(
        builder: (context, cityProvider, child) {
          if (cityProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CombinedRankingCard(cityProvider: cityProvider),
              ],
            ),
          );
        },
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
  late final List<RankingInfo> _rankings;
  late RankingInfo _selectedRanking;

  int _gdpTypeSegment = 0;
  int _wealthTypeSegment = 0;

  String _selectedContinent = 'World';
  List<dynamic> _rankedList = [];

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
    _rankings = [
      RankingInfo(
          title: 'GDP Ranking',
          icon: Icons.monetization_on,
          themeColor: Colors.teal,
          metricKey: 'gdp',
          valueAccessor: (c) => c.gdpNominal,
          unit: '\$'),
      RankingInfo(
          title: 'Wealthiest Cities',
          icon: Icons.diamond,
          themeColor: Colors.blue,
          metricKey: 'wealth',
          valueAccessor: (c) => c.millionaires),
      RankingInfo(
          title: 'Global Financial Centres',
          icon: Icons.account_balance,
          themeColor: Colors.purple,
          metricKey: 'financial_index',
          valueAccessor: (c) => int.parse(c['financial_index']),
          unit: ''),
    ];
    _selectedRanking = _rankings.first;
    _prepareList();
  }

  void _prepareList() {
    dynamic listToRank;

    switch (_selectedRanking.metricKey) {
      case 'gdp':
        listToRank = widget.cityProvider.allCities
            .where((c) => c.gdpNominal != 0.0)
            .toList();
        if (_selectedContinent != 'World') {
          listToRank = (listToRank as List<City>)
              .where((c) => c.continent == _selectedContinent)
              .toList();
        }
        (listToRank as List<City>).sort((a, b) =>
            (_gdpTypeSegment == 0 ? b.gdpNominal : b.gdpPpp)
                .compareTo(_gdpTypeSegment == 0 ? a.gdpNominal : a.gdpPpp));
        break;
      case 'wealth':
        listToRank = widget.cityProvider.millionaireCities;
        if (_selectedContinent != 'World') {
          listToRank = (listToRank as List<City>)
              .where((c) => c.continent == _selectedContinent)
              .toList();
        }
        (listToRank as List<City>).sort((a, b) =>
            (_wealthTypeSegment == 0 ? b.millionaires : b.billionaires)
                .compareTo(_wealthTypeSegment == 0 ? a.millionaires : a.billionaires));
        break;
      case 'financial_index':
        listToRank = widget.cityProvider.financialIndexRawData;
        if (_selectedContinent != 'World') {
          listToRank = (listToRank as List<Map<String, dynamic>>)
              .where((c) => c['continent'] == _selectedContinent)
              .toList();
        }
        (listToRank as List<Map<String, dynamic>>).sort((a, b) =>
            int.parse(b['financial_index'])
                .compareTo(int.parse(a['financial_index'])));
        break;
      default:
        listToRank = [];
    }

    setState(() {
      _rankedList =
          listToRank.take(_selectedContinent == 'World' ? 100 : 30).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final compactFormatter = NumberFormat.compact(locale: 'en_US');
    final topValue = _rankedList.isNotEmpty
        ? _selectedRanking.valueAccessor(_rankedList.first)
        : 1;
    final useDefaultColor = widget.cityProvider.useDefaultCityRankingBarColor;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    icon: Icon(Icons.arrow_drop_down_circle_outlined,
                        color: _selectedRanking.themeColor),
                    items: _rankings
                        .map((r) => DropdownMenuItem(
                      value: r,
                      child: Row(children: [
                        Icon(r.icon, color: r.themeColor),
                        const SizedBox(width: 12),
                        Text(r.title,
                            style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold)),
                      ]),
                    ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedRanking = value;
                          _prepareList();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 8),
                if (_selectedRanking.metricKey == 'gdp')
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<int>(
                      showSelectedIcon: false,
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor:
                        _selectedRanking.themeColor.withOpacity(0.8),
                        selectedForegroundColor: Colors.white,
                      ),
                      segments: const [
                        ButtonSegment(value: 0, label: Text('Nominal')),
                        ButtonSegment(value: 1, label: Text('PPP'))
                      ],
                      selected: {_gdpTypeSegment},
                      onSelectionChanged: (s) => setState(() {
                        _gdpTypeSegment = s.first;
                        _prepareList();
                      }),
                    ),
                  ),
                if (_selectedRanking.metricKey == 'wealth')
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<int>(
                      showSelectedIcon: false,
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor:
                        _selectedRanking.themeColor.withOpacity(0.8),
                        selectedForegroundColor: Colors.white,
                      ),
                      segments: const [
                        ButtonSegment(value: 0, label: Text('Millionaires')),
                        ButtonSegment(value: 1, label: Text('Billionaires'))
                      ],
                      selected: {_wealthTypeSegment},
                      onSelectionChanged: (s) => setState(() {
                        _wealthTypeSegment = s.first;
                        _prepareList();
                      }),
                    ),
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: DropdownButton<String>(
                    value: _selectedContinent,
                    items: _continents
                        .map((v) => DropdownMenuItem(
                        value: v,
                        child: Text(v, style: const TextStyle(fontSize: 14))))
                        .toList(),
                    onChanged: (v) => setState(() {
                      _selectedContinent = v!;
                      _prepareList();
                    }),
                    underline: const SizedBox(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SizedBox(
            height: 600,
            child: _rankedList.isEmpty
                ? const Center(child: Text('No data to display.'))
                : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _rankedList.length,
              itemBuilder: (context, index) {
                final item = _rankedList[index];
                final rank = index + 1;

                final String name = item is City ? item.name : item['name'];
                final String continent =
                item is City ? item.continent : item['continent'];

                num value;
                if (_selectedRanking.metricKey == 'gdp') {
                  value = _gdpTypeSegment == 0
                      ? (item as City).gdpNominal
                      : (item as City).gdpPpp;
                } else if (_selectedRanking.metricKey == 'wealth') {
                  value = _wealthTypeSegment == 0
                      ? (item as City).millionaires
                      : (item as City).billionaires;
                } else {
                  value = _selectedRanking.valueAccessor(item);
                }

                final isVisited =
                widget.cityProvider.visitedCities.contains(name);
                final barColor = useDefaultColor
                    ? _selectedRanking.themeColor
                    : (CityEconomyScreen.continentColors[continent] ??
                    _selectedRanking.themeColor);

                return Card(
                  elevation: 0,
                  color: isVisited
                      ? _selectedRanking.themeColor.withOpacity(0.12)
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
                                      name,
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
                                        borderRadius:
                                        BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: barColor.withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Row(
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
                              '${_selectedRanking.unit}${compactFormatter.format(value)}',
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
                                    (topValue == 0 ? 0 : value / topValue),
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