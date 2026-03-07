// lib/screens/instagram_ranking_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:country_flags/country_flags.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:jidoapp/models/landmarks_model.dart';
import 'package:jidoapp/models/visit_date_model.dart';
import 'package:jidoapp/providers/landmarks_provider.dart';
import 'package:jidoapp/providers/country_provider.dart';
import 'package:jidoapp/widgets/landmark_info_card.dart';

class InstagramRankingScreen extends StatefulWidget {
  const InstagramRankingScreen({super.key});

  @override
  State<InstagramRankingScreen> createState() => _InstagramRankingScreenState();
}

class _InstagramRankingScreenState extends State<InstagramRankingScreen> {
  final List<Map<String, String>> _top10List = [
    {'name': 'Eiffel Tower', 'image': 'assets/instagram/eiffel_tower.png', 'iso': 'FR'},
    {'name': 'Big Ben', 'image': 'assets/instagram/big_ben.png', 'iso': 'GB'},
    {'name': 'Louvre Museum', 'image': 'assets/instagram/louvre.png', 'iso': 'FR'},
    {'name': 'Empire State Building', 'image': 'assets/instagram/empire_state.png', 'iso': 'US'},
    {'name': 'Burj Khalifa', 'image': 'assets/instagram/burj_khalifa.png', 'iso': 'AE'},
    {'name': 'Notre-Dame de Paris', 'image': 'assets/instagram/notre_dame.png', 'iso': 'FR'},
    {'name': "St. Peter's Basilica", 'image': 'assets/instagram/st_peters.png', 'iso': 'VA'},
    {'name': 'Times Square', 'image': 'assets/instagram/times_square.png', 'iso': 'US'},
    {'name': 'Sagrada Familia', 'image': 'assets/instagram/sagrada_familia.png', 'iso': 'ES'},
    {'name': 'Colosseum', 'image': 'assets/instagram/colosseum.png', 'iso': 'IT'},
  ];

  @override
  Widget build(BuildContext context) {
    final landmarksProvider = context.watch<LandmarksProvider>();
    final allLandmarks = landmarksProvider.allLandmarks;
    final visitedSet = landmarksProvider.visitedLandmarks;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Top 10 Instagrammed',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                physics: const BouncingScrollPhysics(),
                itemCount: _top10List.length,
                itemBuilder: (context, index) {
                  final itemData = _top10List[index];
                  final rank = index + 1;
                  final name = itemData['name']!;
                  final imagePath = itemData['image']!;
                  final isoCode = itemData['iso']!;

                  final landmark = allLandmarks.firstWhereOrNull((l) => l.name == name);
                  final isVisited = visitedSet.contains(name);

                  return GestureDetector(
                    onTap: () {
                      if (landmark != null) {
                        _showLandmarkDetailsModal(context, landmark, Colors.pinkAccent, imagePath);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Landmark data not found for $name')),
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: isVisited
                            ? Border.all(color: Colors.teal.withOpacity(0.5), width: 2)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                child: SizedBox(
                                  height: 200,
                                  width: double.infinity,
                                  child: Image.asset(
                                    imagePath,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[200],
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.camera_alt, size: 40, color: Colors.grey[400]),
                                            const SizedBox(height: 8),
                                            Text('Image Placeholder', style: TextStyle(color: Colors.grey[500])),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '#$rank',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              if (isVisited)
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.teal,
                                      shape: BoxShape.circle,
                                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                    ),
                                    child: const Icon(Icons.check, color: Colors.white, size: 20),
                                  ),
                                ),
                            ],
                          ),

                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: SizedBox(
                                          width: 32,
                                          height: 24,
                                          child: CountryFlag.fromCountryCode(
                                            isoCode,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF111827),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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
      ),
    );
  }

  void _showLandmarkDetailsModal(BuildContext context, Landmark landmark, Color fallbackThemeColor, String imagePath) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        final provider = sheetContext.watch<LandmarksProvider>();
        final countryProvider = sheetContext.read<CountryProvider>();

        final freshLandmark = provider.allLandmarks.firstWhere((l) => l.name == landmark.name);
        final isVisited = provider.visitedLandmarks.contains(freshLandmark.name);
        final isWishlisted = provider.wishlistedLandmarks.contains(freshLandmark.name);
        final countryNames = provider.getCountryNames(freshLandmark.countriesIsoA3);

        final visitedSubCount = provider.getVisitedSubLocationCount(freshLandmark.name);
        final totalSubCount = freshLandmark.locations?.length ?? 0;

        String locationDisplay = countryNames;
        if (_isItemNatural(freshLandmark)) {
          locationDisplay = countryNames;
        } else if (freshLandmark.city != 'Unknown' && freshLandmark.city != 'Unknown City') {
          locationDisplay = '$countryNames, ${freshLandmark.city}';
        }

        if (_isItemCategory(freshLandmark, 'Filming Location') && freshLandmark.location != null) {
          locationDisplay += ' (${freshLandmark.location})';
        }

        Color? landmarkThemeColor;
        if (freshLandmark.countriesIsoA3.length == 1) {
          try {
            final country = countryProvider.allCountries.firstWhere(
                  (c) => c.isoA3 == freshLandmark.countriesIsoA3.first,
            );
            landmarkThemeColor = country.themeColor;
          } catch (e) {
            landmarkThemeColor = null;
          }
        }

        final themeColor = landmarkThemeColor ?? fallbackThemeColor;
        final headerTextColor = ThemeData.estimateBrightnessForColor(themeColor) == Brightness.dark
            ? Colors.white
            : Colors.black;

        String metricLabel = _getMetricText(freshLandmark);

        String? modalFlagIso = _getDisplayIsoA2(freshLandmark, countryProvider);
        List<String> displayIsos = [];
        if (modalFlagIso == null || freshLandmark.countriesIsoA3.length > 1) {
          for (var isoA3 in freshLandmark.countriesIsoA3) {
            final c = countryProvider.allCountries.firstWhereOrNull((c) => c.isoA3 == isoA3);
            if (c != null) displayIsos.add(c.isoA2);
          }
        } else {
          displayIsos = [modalFlagIso];
        }

        String displayTitle = freshLandmark.name;
        if (_isItemCategory(freshLandmark, 'Cafe') && freshLandmark.opened != null) {
          displayTitle += ' (${freshLandmark.opened})';
        }

        return FractionallySizedBox(
          heightFactor: 0.85,
          child: Column(
            children: [
              Container(
                color: themeColor,
                padding: const EdgeInsets.only(top: 16, left: 16, right: 8, bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            child: Text('Cancel', style: TextStyle(color: headerTextColor, fontWeight: FontWeight.w600))),
                        ElevatedButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            child: Text('Done', style: TextStyle(fontWeight: FontWeight.w600, color: themeColor)),
                            style: ElevatedButton.styleFrom(backgroundColor: headerTextColor)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                            child: Text(displayTitle,
                                style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold, fontSize: 26, color: headerTextColor))),
                        if (isVisited || visitedSubCount > 0) Icon(Icons.check_circle, color: headerTextColor, size: 24),
                      ],
                    ),
                    if (metricLabel.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(metricLabel, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: headerTextColor.withOpacity(0.95))),
                      ),

                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: headerTextColor.withOpacity(0.8)),
                        const SizedBox(width: 4),
                        Expanded(child: Text(locationDisplay, style: Theme.of(sheetContext).textTheme.titleSmall?.copyWith(color: headerTextColor.withOpacity(0.8), fontWeight: FontWeight.normal))),
                      ],
                    ),
                    const SizedBox(height: 12),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: displayIsos.map((isoA2) => Padding(padding: const EdgeInsets.only(right: 12.0), child: Container(height: 24, width: 32, decoration: BoxDecoration(border: Border.all(color: headerTextColor.withOpacity(0.3), width: 1), borderRadius: BorderRadius.circular(4)), child: ClipRRect(borderRadius: BorderRadius.circular(4), child: CountryFlag.fromCountryCode(isoA2))))).toList()),
                    ),

                    if (totalSubCount > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Text("$visitedSubCount / $totalSubCount visited",
                            style: Theme.of(sheetContext)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                color: headerTextColor.withOpacity(0.9),
                                fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            imagePath,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(mainAxisSize: MainAxisSize.min, children: [const Text('Wishlist:'), IconButton(visualDensity: VisualDensity.compact, icon: Icon(isWishlisted ? Icons.favorite : Icons.favorite_border, color: isWishlisted ? Colors.red : Colors.grey), onPressed: () => provider.toggleWishlistStatus(freshLandmark.name))]),
                            Row(mainAxisSize: MainAxisSize.min, children: [const Text('My Rating:'), const SizedBox(width: 8), RatingBar.builder(initialRating: freshLandmark.rating ?? 0.0, minRating: 0, direction: Axis.horizontal, allowHalfRating: true, itemCount: 5, itemSize: 28.0, itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber), onRatingUpdate: (rating) => provider.updateLandmarkRating(freshLandmark.name, rating))]),
                          ],
                        ),
                        const Divider(height: 20),

                        if (totalSubCount > 1) ...[
                          Text("Components / Locations",
                              style: Theme.of(sheetContext)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: freshLandmark.locations!.map((loc) {
                                final isLocVisited = provider.isSubLocationVisited(freshLandmark.name, loc.name);
                                return CheckboxListTile(
                                  title: Text(loc.name, style: const TextStyle(fontSize: 14)),
                                  value: isLocVisited,
                                  activeColor: themeColor,
                                  dense: true,
                                  controlAffinity: ListTileControlAffinity.leading,
                                  onChanged: (val) {
                                    provider.toggleSubLocation(freshLandmark.name, loc.name);
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                          const Divider(height: 24),
                        ],

                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('History (${freshLandmark.visitDates.length} entries)', style: Theme.of(sheetContext).textTheme.titleSmall), OutlinedButton.icon(icon: const Icon(Icons.add), label: const Text('Add Visit'), onPressed: () => provider.addVisitDate(freshLandmark.name))]),
                        const SizedBox(height: 8),
                        if (freshLandmark.visitDates.isNotEmpty) ...freshLandmark.visitDates.asMap().entries.map((entry) => _LandmarkVisitEditorCard(
                          key: ValueKey('${freshLandmark.name}_${entry.key}'),
                          landmarkName: freshLandmark.name,
                          visitDate: entry.value,
                          index: entry.key,
                          onDelete: () => provider.removeVisitDate(freshLandmark.name, entry.key),
                          availableLocations: freshLandmark.locations,
                        )) else const Center(child: Text('No visits recorded.')),
                        const Divider(height: 24),

                        LandmarkInfoCard(
                            overview: freshLandmark.overview,
                            historySignificance: freshLandmark.history_significance,
                            highlights: freshLandmark.highlights,
                            themeColor: themeColor
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) => setState(() {}));
  }

  bool _isItemCategory(Landmark item, String category) => item.attributes.contains(category);

  bool _isItemNatural(Landmark item) {
    return item.attributes.any((a) => [
      'Mountain', 'Waterfall', 'Falls', 'River', 'Lake', 'Sea', 'Beach', 'Island', 'Unique Landscape'
    ].contains(a));
  }

  double _getMetricValue(Landmark item) {
    if (_isItemCategory(item, 'Mountain') || item.attributes.contains('Falls') || item.attributes.contains('Waterfall')) {
      return (item.height ?? 0).toDouble();
    } else if (_isItemCategory(item, 'Lake')) {
      return (item.area ?? 0).toDouble();
    } else if (_isItemCategory(item, 'River')) {
      if (item.length != null) {
        return double.tryParse(item.length!.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
      }
    } else if (_isItemCategory(item, 'Fast Food')) {
      return (item.numberOfLocations ?? 0).toDouble();
    }
    return 0.0;
  }

  String _getMetricText(Landmark item) {
    final fmt = NumberFormat('#,###');
    if (_isItemCategory(item, 'Mountain') || item.attributes.contains('Falls') || item.attributes.contains('Waterfall')) {
      if (item.height != null) return '${fmt.format(item.height)} m';
    } else if (_isItemCategory(item, 'River')) {
      if (item.length != null) return '${item.length} km';
    } else if (_isItemCategory(item, 'Lake')) {
      if (item.area != null) return '${fmt.format(item.area)} km²';
    }
    return '';
  }

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
}

class _LandmarkVisitEditorCard extends StatefulWidget {
  final String landmarkName;
  final VisitDate visitDate;
  final int index;
  final VoidCallback onDelete;
  final List<LandmarkSubLocation>? availableLocations;

  const _LandmarkVisitEditorCard({
    super.key,
    required this.landmarkName,
    required this.visitDate,
    required this.index,
    required this.onDelete,
    this.availableLocations,
  });

  @override
  State<_LandmarkVisitEditorCard> createState() => _LandmarkVisitEditorCardState();
}

class _LandmarkVisitEditorCardState extends State<_LandmarkVisitEditorCard> {
  late final TextEditingController _titleController;
  late final TextEditingController _memoController;
  late List<String> _currentPhotos;
  int? _year, _month, _day;

  final ExpansionTileController _expansionTileController = ExpansionTileController();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.visitDate.title);
    _memoController = TextEditingController(text: widget.visitDate.memo);
    _currentPhotos = List.from(widget.visitDate.photos);
    _year = widget.visitDate.year;
    _month = widget.visitDate.month;
    _day = widget.visitDate.day;
  }

  void _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null && mounted) {
      final newPhotos = List<String>.from(_currentPhotos)..add(pickedFile.path);
      setState(() => _currentPhotos = newPhotos);
      if(mounted){
        context.read<LandmarksProvider>().updateLandmarkVisit(
            widget.landmarkName,
            widget.index,
            photos: newPhotos
        );
      }
    }
  }

  void _toggleLocationInVisit(String locName, bool isSelected) {
    final provider = context.read<LandmarksProvider>();
    List<String> currentDetails = List.from(widget.visitDate.visitedDetails);

    if (isSelected) {
      if (!currentDetails.contains(locName)) {
        currentDetails.add(locName);
        if (!provider.isSubLocationVisited(widget.landmarkName, locName)) {
          provider.toggleSubLocation(widget.landmarkName, locName);
        }
      }
    } else {
      currentDetails.remove(locName);
    }

    provider.updateLandmarkVisit(
        widget.landmarkName,
        widget.index,
        visitedDetails: currentDetails
    );

    setState(() {});
  }

  Widget _buildPhotoPreview(String photoPath, int index) {
    return Container(
        width: 60,
        height: 60,
        margin: const EdgeInsets.only(right: 8),
        color: Colors.grey[300],
        child: Image.file(File(photoPath), fit: BoxFit.cover));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<LandmarksProvider>();
    final themeColor = Theme.of(context).primaryColor;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        controller: _expansionTileController,
        title: Text(widget.visitDate.title.isNotEmpty ? widget.visitDate.title : 'Visit Record'),
        subtitle: Text('Date: $_year-$_month-$_day'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Visit Record'),
                content: const Text('Are you sure you want to delete this visit record?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onDelete();
                    },
                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title', isDense: true),
                      onEditingComplete: () => provider.updateLandmarkVisit(
                          widget.landmarkName, widget.index,
                          title: _titleController.text)),
                  const SizedBox(height: 8),
                  TextField(
                      controller: _memoController,
                      decoration: const InputDecoration(labelText: 'Memo', isDense: true),
                      onEditingComplete: () => provider.updateLandmarkVisit(
                          widget.landmarkName, widget.index,
                          memo: _memoController.text)),
                  const SizedBox(height: 12),

                  if (widget.availableLocations != null && widget.availableLocations!.length > 1) ...[
                    const Text("Locations included in this visit:",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: widget.availableLocations!.map((loc) {
                        final isChecked = widget.visitDate.visitedDetails.contains(loc.name);
                        return FilterChip(
                          label: Text(loc.name, style: const TextStyle(fontSize: 11)),
                          selected: isChecked,
                          selectedColor: themeColor.withOpacity(0.2),
                          checkmarkColor: themeColor,
                          onSelected: (bool selected) {
                            _toggleLocationInVisit(loc.name, selected);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: () => _pickImage(ImageSource.gallery)),
                      ..._currentPhotos
                          .asMap()
                          .entries
                          .map((e) => _buildPhotoPreview(e.value, e.key))
                          .toList(),
                    ]),
                  ),
                ]),
          )
        ],
      ),
    );
  }
}