// lib/screens/flights_menu_screen.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:typed_data';
import 'package:jidoapp/screens/airlines_list_screen.dart';
import 'package:jidoapp/screens/airports_screen.dart';
import 'package:jidoapp/screens/flight_hub_screen.dart';
import 'package:jidoapp/screens/flight_route_map_screen.dart';
import 'package:jidoapp/providers/airline_provider.dart';
import 'package:jidoapp/providers/airport_provider.dart';
import 'package:jidoapp/providers/country_provider.dart';
import 'package:jidoapp/models/airline_model.dart';
import 'package:provider/provider.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:jidoapp/models/airport_model.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;
import 'package:jidoapp/providers/flight_map_settings_provider.dart';

// 공유 기능 import 및 스크린샷 패키지
import 'package:jidoapp/screens/flights_share.dart';
import 'package:screenshot/screenshot.dart';

// MappedRoute 클래스는 flight_route_map_screen.dart에도 정의되어 있으므로
// 충돌 방지를 위해 이름을 변경하거나 공통 모델 파일로 분리하는 것이 좋으나,
// 여기서는 이 파일 내에서만 사용하는 클래스로 유지합니다.
class MenuMappedRoute {
  final String routeKey;
  final FlightLog representativeLog; // 대표 로그 (최신)
  final List<FlightLog> allLogs;     // 이 노선에 포함된 모든 로그
  final List<List<LatLng>> segments;

  MenuMappedRoute({
    required this.routeKey,
    required this.representativeLog,
    required this.allLogs,
    required this.segments,
  });
}

class FlightsMenuScreen extends StatefulWidget {
  const FlightsMenuScreen({super.key});

  @override
  State<FlightsMenuScreen> createState() => _FlightsMenuScreenState();
}

class _FlightsMenuScreenState extends State<FlightsMenuScreen>
    with TickerProviderStateMixin {
  final List<MenuMappedRoute> _mappedRoutes = [];
  Map<String, Airport> _airportMap = {};
  bool _isMapLoading = true;

  // 지도 캡처 및 공유 상태 관리 변수
  final ScreenshotController _mapScreenshotController = ScreenshotController();
  bool _isSharing = false;

  AnimationController? _lineAnimationController;
  Animation<double>? _gradientOffset;

  AnimationController? _markerAnimationController;
  Animation<double>? _markerPulse;

  @override
  void initState() {
    super.initState();

    _lineAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _gradientOffset =
    Tween<double>(begin: 0.0, end: 1.0).animate(_lineAnimationController!)
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });

    _markerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: false);

    _markerPulse = Tween<double>(begin: 0.5, end: 2.0).animate(
      CurvedAnimation(
        parent: _markerAnimationController!,
        curve: Curves.easeOutQuad,
      ),
    );
  }

  @override
  void dispose() {
    _lineAnimationController?.dispose();
    _markerAnimationController?.dispose();
    super.dispose();
  }

  // 공유 버튼 핸들러
  Future<void> _handleShare(BuildContext context) async {
    if (_isSharing) return;

    setState(() => _isSharing = true);

    try {
      // 1. 현재 화면의 지도를 캡처합니다.
      final Uint8List? mapImage = await _mapScreenshotController.capture();

      if (mapImage == null) throw Exception("Failed to capture map");

      if (!mounted) return;

      final airlineProvider = context.read<AirlineProvider>();
      final airportProvider = context.read<AirportProvider>();

      // 2. 분리된 파일(FlightsShare)의 기능을 호출하여 공유를 시작합니다.
      await FlightsShare.share(
        context: context,
        mapImage: mapImage,
        allLogs: airlineProvider.allFlightLogs,
        allAirports: airportProvider.allAirports,
      );

    } catch (e) {
      debugPrint("Flights Menu Share Error: $e");
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  double _calculateStrokeWidth(int times, bool useThickness) {
    if (!useThickness) return 1.5;
    if (times <= 1) return 1.5;
    const double minWidth = 1.5;
    const double targetTimes = 10.0;
    const double maxWidth = 4.0;
    if (times >= targetTimes) return maxWidth;
    final double log10 = math.log(targetTimes);
    final double A = (maxWidth - minWidth) / log10;
    final double logThickness = A * math.log(times.toDouble()) + minWidth;
    return math.min(math.max(logThickness, minWidth), maxWidth);
  }

  List<LatLng> _getGreatCirclePoints(LatLng start, LatLng end, {int steps = 20}) {
    if (start == end) return [start];
    double lat1 = start.latitudeInRad;
    double lon1 = start.longitudeInRad;
    double lat2 = end.latitudeInRad;
    double lon2 = end.longitudeInRad;
    double d = math.acos(math.sin(lat1) * math.sin(lat2) +
        math.cos(lat1) * math.cos(lat2) * math.cos(lon2 - lon1));
    if (d < 0.01) return [start, end];
    List<LatLng> points = [];
    for (int i = 0; i <= steps; i++) {
      double f = i / steps;
      double a = math.sin((1 - f) * d) / math.sin(d);
      double b = math.sin(f * d) / math.sin(d);
      double x = a * math.cos(lat1) * math.cos(lon1) +
          b * math.cos(lat2) * math.cos(lon2);
      double y = a * math.cos(lat1) * math.sin(lon1) +
          b * math.cos(lat2) * math.sin(lon2);
      double z = a * math.sin(lat1) + b * math.sin(lat2);
      double lat = math.atan2(z, math.sqrt(x * x + y * y));
      double lon = math.atan2(y, x);
      points.add(LatLng(lat * 180 / math.pi, lon * 180 / math.pi));
    }
    return points;
  }

  List<List<LatLng>> _splitGreatCircleForAntiMeridian(LatLng start, LatLng end) {
    final allPoints = _getGreatCirclePoints(start, end, steps: 50);
    int splitIndex = -1;
    for (int i = 0; i < allPoints.length - 1; i++) {
      double lonDiff = (allPoints[i + 1].longitude - allPoints[i].longitude).abs();
      if (lonDiff > 180) {
        splitIndex = i;
        break;
      }
    }
    if (splitIndex == -1) return [allPoints];
    final List<LatLng> segment1 = allPoints.sublist(0, splitIndex + 1);
    final List<LatLng> segment2 = allPoints.sublist(splitIndex + 1);
    final lastLon = segment1.last.longitude;
    final boundaryLon1 = lastLon > 0 ? 180.0 : -180.0;
    segment1.last = LatLng(segment1.last.latitude, boundaryLon1);
    final firstLon = segment2.first.longitude;
    final boundaryLon2 = firstLon > 0 ? 180.0 : -180.0;
    segment2.insert(0, LatLng(segment2.first.latitude, boundaryLon2));
    return [segment1, segment2];
  }

  void _prepareMapData() {
    if (!mounted) return;
    final airlineProvider = context.read<AirlineProvider>();
    final airportProvider = context.read<AirportProvider>();

    if (airlineProvider.allFlightLogs.isEmpty ||
        airportProvider.allAirports.isEmpty) {
      if (mounted) setState(() => _isMapLoading = false);
      return;
    }

    _airportMap = {
      for (var airport in airportProvider.allAirports)
        airport.iataCode: airport,
    };

    final allLogs = airlineProvider.allFlightLogs;

    final Map<String, List<FlightLog>> groupedRoutes = {};
    for (final log in allLogs) {
      final depIata = log.departureIata;
      final arrIata = log.arrivalIata;
      if (depIata != null && depIata.isNotEmpty && arrIata != null && arrIata.isNotEmpty) {
        final routeKey = '$depIata-$arrIata';
        groupedRoutes.putIfAbsent(routeKey, () => []).add(log);
      }
    }

    final List<MenuMappedRoute> mappedRoutes = [];

    for (final entry in groupedRoutes.entries) {
      final routeKey = entry.key;
      final logs = entry.value;

      logs.sort((a, b) {
        final dateA = DateTime.tryParse(a.date) ?? DateTime(1900);
        final dateB = DateTime.tryParse(b.date) ?? DateTime(1900);
        return dateB.compareTo(dateA);
      });
      final representativeLog = logs.first;

      final depIata = routeKey.split('-')[0];
      final arrIata = routeKey.split('-')[1];

      final Airport? depAirport = _airportMap[depIata];
      final Airport? arrAirport = _airportMap[arrIata];

      if (depAirport != null && arrAirport != null) {
        final LatLng depLatLng = LatLng(depAirport.latitude, depAirport.longitude);
        final LatLng arrLatLng = LatLng(arrAirport.latitude, arrAirport.longitude);
        final List<List<LatLng>> segments = _splitGreatCircleForAntiMeridian(depLatLng, arrLatLng);

        mappedRoutes.add(MenuMappedRoute(
          routeKey: routeKey,
          representativeLog: representativeLog,
          allLogs: logs,
          segments: segments,
        ));
      }
    }

    mappedRoutes.sort((a, b) {
      final dateA = DateTime.tryParse(a.representativeLog.date) ?? DateTime(1900);
      final dateB = DateTime.tryParse(b.representativeLog.date) ?? DateTime(1900);
      return dateB.compareTo(dateA);
    });

    if (mounted) {
      setState(() {
        _mappedRoutes.clear();
        _mappedRoutes.addAll(mappedRoutes);
        _isMapLoading = false;
      });
    }
  }

  Widget _buildHeroLogCard(BuildContext context, int count) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FlightHubScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 100,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2575FC).withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.flight_takeoff,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "FLIGHT HUB",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Logs, Maps & Stats",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    "$count",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withOpacity(0.6),
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ⭐️ [디자인 개선] 숫자(Count)를 포함하는 카드로 수정
  Widget _buildListSummaryCard(
      BuildContext context, {
        required String title,
        required String value,
        required String subLabel,
        required int count,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    final bool isAirports = title.toLowerCase() == "airports";
    final IconData displayIcon = isAirports ? Icons.flight_land : Icons.airlines;

    // Airport 이름에서 맨 뒤 "Airport" 제거 로직
    String displayValue = value;
    if (isAirports && value.isNotEmpty) {
      final words = value.split(' ');
      if (words.isNotEmpty && words.last.toLowerCase() == 'airport') {
        displayValue = words.sublist(0, words.length - 1).join(' ');
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // 왼쪽 컬러 스트립
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 6,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.6)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
                child: Row(
                  children: [
                    // 아이콘
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        displayIcon,
                        color: color,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 텍스트 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                title.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "$count",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            displayValue,
                            style: TextStyle(
                              fontSize: isAirports ? 16 : 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 화살표
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: color,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const accentBlue = Colors.blueAccent;
    const accentGreen = Colors.green;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        top: false,
        child: Consumer4<AirlineProvider, AirportProvider, CountryProvider, FlightMapSettingsProvider>(
          builder: (context, airlineProvider, airportProvider, countryProvider, settings, child) {

            if (airlineProvider.isLoading ||
                airportProvider.isLoading ||
                countryProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_isMapLoading) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _isMapLoading) _prepareMapData();
              });
            }

            // 총 비행 횟수 (숨김 처리 반영)
            final int flightCount = airlineProvider.allFlightLogs
                .where((log) => !settings.isLogHidden(log.id))
                .fold(0, (sum, log) => sum + log.times);

            // 현재 보이는 로그들
            final visibleLogs = airlineProvider.allFlightLogs
                .where((log) => !settings.isLogHidden(log.id))
                .toList();

            // ⭐️ [추가] 방문한 공항 수 계산 (숨김 로그 제외)
            final visitedAirportCodes = <String>{};
            for (var log in visibleLogs) {
              if (log.departureIata != null) visitedAirportCodes.add(log.departureIata!);
              if (log.arrivalIata != null) visitedAirportCodes.add(log.arrivalIata!);
            }
            final int visitedAirportsCount = visitedAirportCodes.length;

            // My Hub 및 최다 이용 공항 로직
            String mostUsedAirportName = "Select Your Hub";
            String airportSubLabel = "My Hub";

            final hubs = airportProvider.visitedAirports
                .where((iata) => airportProvider.isHub(iata))
                .toList();

            if (hubs.isNotEmpty) {
              hubs.sort((a, b) => airportProvider.getVisitCount(b).compareTo(airportProvider.getVisitCount(a)));
              final topHubIata = hubs.first;

              try {
                mostUsedAirportName = airportProvider.allAirports
                    .firstWhere((a) => a.iataCode == topHubIata)
                    .name;
              } catch (_) {
                mostUsedAirportName = topHubIata;
              }
            }

            // ⭐️ [추가] 탑승한 항공사 수 및 최다 이용 항공사 로직
            String mostUsedAirlineName = "-";
            final Map<String, int> airlineUsage = {};
            for (var log in visibleLogs) {
              if (log.airlineName != null && log.airlineName != 'Unknown') {
                airlineUsage[log.airlineName!] =
                    (airlineUsage[log.airlineName!] ?? 0) + log.times;
              }
            }
            if (airlineUsage.isNotEmpty) {
              mostUsedAirlineName =
                  airlineUsage.entries.reduce((a, b) => a.value > b.value ? a : b).key;
            }
            final int flownAirlinesCount = airlineUsage.length; // 이용한 항공사 수

            // 지도용 데이터 준비
            final List<Map<String, dynamic>> visibleRouteData = [];
            for (var route in _mappedRoutes) {
              final visibleLogsInRoute = route.allLogs
                  .where((log) => !settings.isLogHidden(log.id))
                  .toList();
              if (visibleLogsInRoute.isNotEmpty) {
                final visibleTotalTimes = visibleLogsInRoute.fold(0, (sum, log) => sum + log.times);
                visibleRouteData.add({
                  'route': route,
                  'visibleTotalTimes': visibleTotalTimes,
                });
              }
            }

            final visibleIataCodes = <String>{};
            for (final data in visibleRouteData) {
              final route = data['route'] as MenuMappedRoute;
              if (route.representativeLog.departureIata != null) {
                visibleIataCodes.add(route.representativeLog.departureIata!);
              }
              if (route.representativeLog.arrivalIata != null) {
                visibleIataCodes.add(route.representativeLog.arrivalIata!);
              }
            }

            final airportMarkers = visibleIataCodes.map((iata) {
              final airport = _airportMap[iata];
              if (airport == null || _markerPulse == null) return null;

              final bool isHubHighlighted = settings.showHubs && airportProvider.isHub(iata);

              return Marker(
                width: 20,
                height: 20,
                point: LatLng(airport.latitude, airport.longitude),
                child: Tooltip(
                  message: '${airport.name} (${airport.iataCode})',
                  child: isHubHighlighted
                      ? Stack(
                    alignment: Alignment.center,
                    children: [
                      FadeTransition(
                        opacity: ReverseAnimation(_markerAnimationController!),
                        child: ScaleTransition(
                          scale: _markerPulse!,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.pink.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.pink,
                          border: Border.all(color: Colors.white, width: 1.0),
                        ),
                      ),
                    ],
                  )
                      : Center(
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.deepPurple,
                        border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.0),
                      ),
                    ),
                  ),
                ),
              );
            }).whereType<Marker>().toList();

            final List<Color> animatedGradientColors = [];
            final int totalSteps = 20;
            final int chunkStepSize = 3;
            final double currentOffset = _gradientOffset?.value ?? 0.0;
            final int startStep = (currentOffset * totalSteps).floor();

            for (int i = 0; i < totalSteps; i++) {
              bool isColor1 = false;
              for (int j = 0; j < chunkStepSize; j++) {
                if ((startStep + j) % totalSteps == i) {
                  isColor1 = true;
                  break;
                }
              }
              animatedGradientColors.add(isColor1 ? settings.routeColor1 : settings.routeColor2);
            }

            final visiblePolylines = visibleRouteData.expand((data) {
              final route = data['route'] as MenuMappedRoute;
              final visibleTotalTimes = data['visibleTotalTimes'] as int;

              final double strokeWidth = _calculateStrokeWidth(visibleTotalTimes, settings.useThicknessByFrequency);
              return route.segments.map(
                    (points) => Polyline(
                  points: points,
                  strokeWidth: strokeWidth,
                  gradientColors: animatedGradientColors,
                ),
              );
            }).toList();

            return Container(
              color: const Color(0xFFF5F5F5),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [// 1. Map Section
                    SizedBox(
                      height: 320,
                      child: Stack(
                        children: [
                          Screenshot(
                            controller: _mapScreenshotController,
                            child: FlutterMap(
                              options: const MapOptions(
                                initialCenter: LatLng(25, 10),
                                initialZoom: 0.6,
                                interactionOptions: InteractionOptions(
                                  flags: InteractiveFlag.none,
                                ),
                                backgroundColor: Color(0xFFF5F5F5),
                              ),
                              children: [
                                PolygonLayer(
                                  polygons: countryProvider.allCountries
                                      .expand((country) {
                                    return country.polygonsData.map((polygonData) {
                                      return Polygon(
                                        points: polygonData.first,
                                        holePointsList: polygonData.length > 1
                                            ? polygonData.sublist(1)
                                            : null,
                                        color: Colors.white,
                                        borderColor: Colors.grey.shade300,
                                        borderStrokeWidth: 1.0,
                                        isFilled: true,
                                      );
                                    });
                                  }).toList(),
                                ),
                                PolylineLayer(
                                  polylines: visiblePolylines,
                                ),
                                MarkerLayer(
                                  markers: airportMarkers,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 100,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withOpacity(0.9),
                                    Colors.white.withOpacity(0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            top: 16,
                            right: 16,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () => _handleShare(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: _isSharing
                                        ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                                      ),
                                    )
                                        : const Icon(Icons.share, color: Colors.deepPurple, size: 22),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => const FlightRouteMapScreen()
                                        )
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.deepPurple.withOpacity(0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.add, color: Colors.white, size: 22),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. Main Content (List)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 0),

                          _buildHeroLogCard(context, flightCount),

                          // ⭐️ [변경] Airports 카드: 숫자 추가 및 디자인 개선
                          _buildListSummaryCard(
                            context,
                            title: "Airports",
                            value: mostUsedAirportName,
                            subLabel: airportSubLabel, // "My Hub"
                            count: visitedAirportsCount, // ⭐️ 방문 공항 수 전달
                            icon: Icons.connecting_airports,
                            color: accentBlue,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AirportsScreen(),
                              ),
                            ),
                          ),

                          // ⭐️ [변경] Airlines 카드: 숫자 추가 및 디자인 개선
                          _buildListSummaryCard(
                            context,
                            title: "Airlines",
                            value: mostUsedAirlineName,
                            subLabel: "Top Flown",
                            count: flownAirlinesCount, // ⭐️ 탑승 항공사 수 전달
                            icon: Icons.flight_takeoff,
                            color: accentGreen,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AirlinesListScreen(),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
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
    );
  }
}