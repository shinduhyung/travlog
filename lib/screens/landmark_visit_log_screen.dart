// lib/screens/landmark_visit_log_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:country_flags/country_flags.dart';
import 'package:collection/collection.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // [추가] 별점 위젯

import 'package:jidoapp/models/landmarks_model.dart';
import 'package:jidoapp/models/visit_date_model.dart';
import 'package:jidoapp/providers/landmarks_provider.dart';
import 'package:jidoapp/providers/country_provider.dart';
import 'package:jidoapp/widgets/landmark_info_card.dart';

enum LogGroupOption { year, country }

class LandmarkVisitLogScreen extends StatefulWidget {
  const LandmarkVisitLogScreen({super.key});

  @override
  State<LandmarkVisitLogScreen> createState() => _LandmarkVisitLogScreenState();
}

class _LandmarkVisitLogScreenState extends State<LandmarkVisitLogScreen> {
  LogGroupOption _logGroupOption = LogGroupOption.year;

  // 이 화면의 기본 테마 색상 (녹색)
  final Color _themeColor = const Color(0xFF10B981);

  String? _getDisplayIsoA2(Landmark site, CountryProvider countryProvider) {
    if (site.city.contains('Macao') || site.countriesIsoA3.contains('MAC')) return 'MO';
    if (site.city.contains('Hong Kong') || site.countriesIsoA3.contains('HKG')) return 'HK';
    if (site.countriesIsoA3.contains('GRL')) return 'GL';
    if (site.countriesIsoA3.contains('PYF')) return 'PF';
    if (site.countriesIsoA3.contains('PRI')) return 'PR';
    if (site.countriesIsoA3.contains('BMU')) return 'BM';
    if (site.countriesIsoA3.contains('GIB')) return 'GI';
    if (site.countriesIsoA3.contains('PCN')) return 'PN';

    if (site.countriesIsoA3.length == 1) {
      try {
        final c = countryProvider.allCountries.firstWhereOrNull((c) => c.isoA3 == site.countriesIsoA3.first);
        return c?.isoA2;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Widget _buildFlag(Landmark item, CountryProvider cp) {
    final List<String> sortedIsoA3 = List.from(item.countriesIsoA3)
      ..sort((a, b) => a == 'CHN' ? -1 : (b == 'CHN' ? 1 : 0));

    String? displayIsoA2 = _getDisplayIsoA2(item, cp);

    if (sortedIsoA3.length >= 2) {
      String? iso1, iso2;
      try {
        iso1 = cp.allCountries.firstWhereOrNull((c) => c.isoA3 == sortedIsoA3[0])?.isoA2;
        iso2 = cp.allCountries.firstWhereOrNull((c) => c.isoA3 == sortedIsoA3[1])?.isoA2;
      } catch(e){}

      if (iso1 != null && iso2 != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            width: 24, height: 18,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CountryFlag.fromCountryCode(iso1),
                ClipPath(clipper: const DiagonalClipper(), child: CountryFlag.fromCountryCode(iso2)),
              ],
            ),
          ),
        );
      }
    }

    if (displayIsoA2 != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(width: 24, height: 18, child: CountryFlag.fromCountryCode(displayIsoA2)),
      );
    }

    return const Icon(Icons.place, size: 16, color: Colors.grey);
  }

  // [추가] FavoritesScreen과 동일한 상세 정보 모달
  void _showLandmarkDetailsModal(BuildContext context, Landmark landmark, Color fallbackThemeColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) => Consumer<LandmarksProvider>(
        builder: (context, provider, child) {
          final freshLandmark = provider.allLandmarks.firstWhereOrNull((l) => l.name == landmark.name) ?? landmark;
          final isVisited = provider.visitedLandmarks.contains(freshLandmark.name);
          final isWishlisted = provider.wishlistedLandmarks.contains(freshLandmark.name);
          final countryNames = provider.getCountryNames(freshLandmark.countriesIsoA3);
          final countryProvider = context.read<CountryProvider>();

          Color? themeColor;
          if (freshLandmark.countriesIsoA3.isNotEmpty) {
            final c = countryProvider.allCountries.firstWhereOrNull((c) => c.isoA3 == freshLandmark.countriesIsoA3.first);
            themeColor = c?.themeColor;
          }
          final finalColor = themeColor ?? fallbackThemeColor;
          final headerTextColor = ThemeData.estimateBrightnessForColor(finalColor) == Brightness.dark ? Colors.white : Colors.black;

          return Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
            child: FractionallySizedBox(
              heightFactor: 0.85,
              child: Column(children: [
                Container(
                  decoration: BoxDecoration(
                      color: finalColor,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      TextButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          child: Text('Cancel', style: TextStyle(color: headerTextColor, fontWeight: FontWeight.w600))),
                      ElevatedButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          style: ElevatedButton.styleFrom(backgroundColor: headerTextColor),
                          child: Text('Done', style: TextStyle(fontWeight: FontWeight.w600, color: finalColor))),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                          child: Text(freshLandmark.name,
                              style: Theme.of(sheetContext)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold, fontSize: 26, color: headerTextColor))),
                      if (isVisited) Icon(Icons.check_circle, color: headerTextColor, size: 24)
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      Icon(Icons.location_on, size: 14, color: headerTextColor.withOpacity(0.8)),
                      const SizedBox(width: 4),
                      Expanded(
                          child: Text(countryNames,
                              style: Theme.of(sheetContext)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(color: headerTextColor.withOpacity(0.8))))
                    ]),
                  ]),
                ),
                Expanded(
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Row(children: [
                              const Text('Wishlist:'),
                              IconButton(
                                  icon: Icon(isWishlisted ? Icons.favorite : Icons.favorite_border,
                                      color: isWishlisted ? Colors.red : Colors.grey),
                                  onPressed: () => provider.toggleWishlistStatus(freshLandmark.name))
                            ]),
                            RatingBar.builder(
                                initialRating: freshLandmark.rating ?? 0.0,
                                allowHalfRating: true,
                                itemSize: 28,
                                itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                                onRatingUpdate: (rating) => provider.updateLandmarkRating(freshLandmark.name, rating)),
                          ]),
                          const Divider(height: 32),
                          LandmarkInfoCard(
                              overview: freshLandmark.overview,
                              historySignificance: freshLandmark.history_significance,
                              highlights: freshLandmark.highlights,
                              themeColor: finalColor),
                        ])))
              ]),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LandmarksProvider>();
    final countryProvider = context.read<CountryProvider>();

    List<_VisitLogItem> logs = [];
    for (var site in provider.allLandmarks) {
      int totalVisits = site.visitDates.length;
      for (int i = 0; i < totalVisits; i++) {
        final visit = site.visitDates[i];
        logs.add(_VisitLogItem(site: site, visit: visit, nthVisit: totalVisits - i));
      }
    }

    logs.sort((a, b) {
      final dateA = DateTime(a.visit.year ?? 0, a.visit.month ?? 1, a.visit.day ?? 1);
      final dateB = DateTime(b.visit.year ?? 0, b.visit.month ?? 1, b.visit.day ?? 1);
      return dateB.compareTo(dateA);
    });

    Map<String, List<_VisitLogItem>> groupedLogs = {};
    if (_logGroupOption == LogGroupOption.year) {
      for (var log in logs) {
        groupedLogs.putIfAbsent(log.visit.year.toString(), () => []).add(log);
      }
    } else {
      for (var log in logs) {
        final iso = log.site.countriesIsoA3.isNotEmpty ? log.site.countriesIsoA3.first : 'Other';
        final name = countryProvider.isoToCountryNameMap[iso] ?? iso;
        groupedLogs.putIfAbsent(name, () => []).add(log);
      }
    }

    final sortedKeys = groupedLogs.keys.toList();
    if (_logGroupOption == LogGroupOption.year) {
      sortedKeys.sort((a, b) => b.compareTo(a));
    } else {
      sortedKeys.sort();
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Landmark Visit Log',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildFilterChip('By Year', _logGroupOption == LogGroupOption.year, () {
                        setState(() => _logGroupOption = LogGroupOption.year);
                      }),
                      const SizedBox(width: 8),
                      _buildFilterChip('By Country', _logGroupOption == LogGroupOption.country, () {
                        setState(() => _logGroupOption = LogGroupOption.country);
                      }),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemCount: sortedKeys.length,
                itemBuilder: (context, index) {
                  final key = sortedKeys[index];
                  final items = groupedLogs[key]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                        child: Text(
                          key,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _themeColor,
                          ),
                        ),
                      ),
                      ...items.map((log) => _buildLogTile(log, countryProvider)).toList(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _themeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _themeColor : Colors.grey[300]!,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: _themeColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildLogTile(_VisitLogItem item, CountryProvider cp) {
    String dateStr = "${item.visit.year}";
    if (item.visit.month != -9999) {
      dateStr += "-${item.visit.month.toString().padLeft(2, '0')}";
      if (item.visit.day != -9999) {
        dateStr += "-${item.visit.day.toString().padLeft(2, '0')}";
      }
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        child: _buildFlag(item.site, cp),
      ),
      title: Text(
        item.site.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Color(0xFF1F2937),
        ),
      ),
      subtitle: Text(
        "$dateStr • Visit #${item.nthVisit}",
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 12,
        ),
      ),
      trailing: item.site.rating != null && item.site.rating! > 0
          ? Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
          const SizedBox(width: 2),
          Text(
            item.site.rating!.toStringAsFixed(1),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Color(0xFF374151),
            ),
          ),
        ],
      )
          : null,
      onTap: () {
        // [수정] 단순 Navigator.push 대신 FavoritesScreen과 동일한 모달창 호출
        _showLandmarkDetailsModal(context, item.site, _themeColor);
      },
    );
  }
}

class _VisitLogItem {
  final Landmark site;
  final VisitDate visit;
  final int nthVisit;
  _VisitLogItem({required this.site, required this.visit, required this.nthVisit});
}

class DiagonalClipper extends CustomClipper<Path> {
  const DiagonalClipper();
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width, 0.0);
    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}