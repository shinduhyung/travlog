// lib/screens/city_society_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:jidoapp/models/city_model.dart';
import 'package:jidoapp/providers/city_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:jidoapp/screens/city_history_screen.dart'; // History Screen Import

// 데이터 클래스: 랭킹 정보
class RankingInfo {
  final String title;
  final IconData icon;
  final Color themeColor;
  final num Function(City) valueAccessor;
  final String dataSourceKey; // 'student', 'safety', etc.
  final bool isAscendingBetter;

  const RankingInfo({
    required this.title,
    required this.icon,
    required this.themeColor,
    required this.valueAccessor,
    required this.dataSourceKey,
    this.isAscendingBetter = false, // false = descending is better (higher is rank 1)
  });
}

// CitySocietyScreen: Society & History 탭 통합
class CitySocietyScreen extends StatelessWidget {
  const CitySocietyScreen({super.key});

  static const List<String> _tabs = ['Society', 'History'];
  static const Map<String, IconData> _tabIcons = {
    'Society': Icons.groups,
    'History': Icons.history_edu,
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
              CitySocietyTabScreen(), // Society 탭 내용
              CityHistoryTabScreen(), // History 탭 내용
            ],
          ),
        ),
      ),
    );
  }
}

// CitySocietyTabScreen: Society 랭킹 컨텐츠
class CitySocietyTabScreen extends StatelessWidget {
  const CitySocietyTabScreen({super.key});

  static final Map<String, Color> continentColors = {
    'Asia': Colors.pink.shade200, 'Europe': Colors.amber, 'Africa': Colors.brown,
    'North America': Colors.blue.shade200, 'South America': Colors.green, 'Oceania': Colors.purple,
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<CityProvider>(
      builder: (context, cityProvider, child) {
        if (cityProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _CombinedRankingCard(cityProvider: cityProvider),
        );
      },
    );
  }
}

// 통합 랭킹 카드 (Soft UI 적용)
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
      RankingInfo(title: 'QS Best Student Cities', icon: Icons.school, themeColor: Colors.orange, valueAccessor: (c) => c.studentScore, dataSourceKey: 'student'),
      RankingInfo(title: 'Safety Ranking', icon: Icons.security, themeColor: Colors.blue, valueAccessor: (c) => c.safetyScore, dataSourceKey: 'safety'),
      RankingInfo(title: 'Liveability Ranking', icon: Icons.favorite, themeColor: Colors.red, valueAccessor: (c) => c.liveabilityScore, dataSourceKey: 'liveability'),
      // 🚨 살인율: 큰 숫자부터 나열되도록 isAscendingBetter를 false로 설정 (기본값)
      RankingInfo(title: 'Homicide Rate', icon: Icons.personal_injury, themeColor: Colors.red.shade900, valueAccessor: (c) => c.homicideRate, dataSourceKey: 'homicide', isAscendingBetter: false),
      RankingInfo(title: 'Surveillance Cameras', icon: Icons.videocam, themeColor: Colors.grey.shade700, valueAccessor: (c) => c.surveillanceCameraCount, dataSourceKey: 'surveillance'),
      RankingInfo(title: 'Pollution Ranking', icon: Icons.cloud_off, themeColor: Colors.brown, valueAccessor: (c) => c.pollutionScore, dataSourceKey: 'pollution'),
    ];
    _selectedRanking = _rankings.first;
    _prepareList();
  }

  void _prepareList() {
    List<City> listToRank;
    switch (_selectedRanking.dataSourceKey) {
      case 'student': listToRank = widget.cityProvider.studentCities.where((c) => c.studentScore != 0).toList(); break;
      case 'safety': listToRank = widget.cityProvider.safetyCities.where((c) => c.safetyScore != 0).toList(); break;
      case 'liveability': listToRank = widget.cityProvider.liveabilityCities.where((c) => c.liveabilityScore != 0).toList(); break;
      case 'homicide': listToRank = widget.cityProvider.homicideCities.where((c) => c.homicideRate != 0).toList(); break;
      case 'surveillance': listToRank = widget.cityProvider.surveillanceCities.where((c) => c.surveillanceCameraCount != 0).toList(); break;
      case 'pollution': listToRank = widget.cityProvider.pollutionCities.where((c) => c.pollutionScore != 0).toList(); break;
      default: listToRank = [];
    }

    listToRank.sort((a, b) {
      final valA = _selectedRanking.valueAccessor(a);
      final valB = _selectedRanking.valueAccessor(b);
      // isAscendingBetter가 false면 내림차순(큰게 1위)
      return _selectedRanking.isAscendingBetter ? valA.compareTo(valB) : valB.compareTo(valA);
    });

    setState(() {
      _rankedList = listToRank.take(30).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // 🚨 바의 최대 기준값 설정: 리스트의 첫 번째 항목(내림차순일 경우 최댓값)을 기준으로 함
    double topValue = 1.0;
    if (_rankedList.isNotEmpty) {
      final val = _selectedRanking.valueAccessor(_rankedList.first).toDouble();
      topValue = val == 0 ? 1.0 : val;
    }

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
            height: 400,
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _rankedList.length,
              itemBuilder: (context, index) {
                final item = _rankedList[index];
                final value = _selectedRanking.valueAccessor(item);
                final isVisited = widget.cityProvider.visitedCities.contains(item.name);
                final rank = index + 1;

                final themeColor = _selectedRanking.themeColor;
                final barColor = widget.cityProvider.useDefaultCityRankingBarColor
                    ? themeColor
                    : CitySocietyTabScreen.continentColors[item.continent] ?? themeColor;

                // 🚨 진행도 계산: topValue(최댓값) 대비 현재 값의 비율
                double progressValue = (value.toDouble() / topValue).clamp(0.0, 1.0);

                // 만약 '작은게 좋은' 랭킹이라면 바를 반전시키지만,
                // 살인율은 이제 큰게 위로 오게 했으므로 1위 도시가 1.0(꽉 참)이 됩니다.
                if (_selectedRanking.isAscendingBetter) {
                  progressValue = 1.0 - progressValue;
                }

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
                            Text(value.toStringAsFixed(1), style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: progressValue,
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