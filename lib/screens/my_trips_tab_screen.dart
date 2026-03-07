// lib/screens/my_trips_tab_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jidoapp/providers/auth_provider.dart';
import 'package:jidoapp/screens/profile_screen.dart';
import 'package:jidoapp/providers/badge_provider.dart';
import 'package:jidoapp/screens/badges_screen.dart';
import 'package:jidoapp/screens/calendar_screen.dart';
import 'package:jidoapp/screens/passport_screen.dart';
import 'package:jidoapp/screens/settings_screen.dart';
import 'package:jidoapp/screens/visa_screen.dart';
import 'package:jidoapp/screens/trip_log_list_screen.dart';
import 'package:jidoapp/screens/recommendations_screen.dart';
import 'package:jidoapp/screens/favorites_screen.dart';
import 'package:jidoapp/screens/traveler_type_selector_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyTripsTabScreen extends StatefulWidget {
  const MyTripsTabScreen({super.key});

  @override
  State<MyTripsTabScreen> createState() => _MyTripsTabScreenState();
}

class _MyTripsTabScreenState extends State<MyTripsTabScreen> {
  String? _travelerType;
  String? _travelerTypeIconName;

  static const Color mint = Color(0xFF00CDB5);
  static const Color darkMint = Color(0xFF009688);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color blue = Color(0xFF6366F1);
  static const Color red = Color(0xFFEF4444);
  static const Color orange = Color(0xFFF97316);
  static const Color skyBlue = Color(0xFF0EA5E9);
  static const Color pink = Color(0xFFEC4899);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTravelerType();
    });
  }

  Future<void> _loadTravelerType() async {
    final prefs = await SharedPreferences.getInstance();
    String? typeName;
    final aiJson = prefs.getString('ai_analysis_result');
    if (aiJson != null) {
      try {
        final parsed = jsonDecode(aiJson) as Map<String, dynamic>;
        final types = (parsed['summary']?['persona_scores'] as List? ?? [])
            .cast<Map<String, dynamic>>();
        if (types.isNotEmpty) {
          types.sort((a, b) =>
              (b['score'] as num).compareTo(a['score'] as num));
          typeName = types.first['label'] as String?;
        }
      } catch (e) {
        debugPrint('Error parsing AI result: $e');
      }
    }
    typeName ??= prefs.getString('traveler_type');
    if (mounted) {
      setState(() {
        _travelerType = typeName;
        _travelerTypeIconName = _getIconNameForType(typeName);
      });
    }
  }

  String? _getIconNameForType(String? typeName) {
    if (typeName == null || typeName.isEmpty) return null;
    final map = {
      'Identity Seeker': 'self_improvement_outlined',
      'Sensory Immersionist': 'camera_roll_outlined',
      'Efficiency Maximizer': 'speed_outlined',
      'Cultural Decoder': 'museum_outlined',
      'Joy Collector': 'celebration_outlined',
      'Inner Sanctuary Seeker': 'spa_outlined',
      'Wildlife & Earth Enthusiast': 'forest_outlined',
      'Global Connector': 'people_alt_outlined',
      'Freedom Drifter': 'directions_car_filled_outlined',
      'Achievement Hunter': 'emoji_events_outlined',
    };
    return map[typeName];
  }

  IconData _getTravelerTypeIcon() {
    switch (_travelerTypeIconName) {
      case 'self_improvement_outlined':
        return Icons.self_improvement_outlined;
      case 'camera_roll_outlined':
        return Icons.camera_roll_outlined;
      case 'speed_outlined':
        return Icons.speed_outlined;
      case 'museum_outlined':
        return Icons.museum_outlined;
      case 'celebration_outlined':
        return Icons.celebration_outlined;
      case 'spa_outlined':
        return Icons.spa_outlined;
      case 'forest_outlined':
        return Icons.forest_outlined;
      case 'people_alt_outlined':
        return Icons.people_alt_outlined;
      case 'directions_car_filled_outlined':
        return Icons.directions_car_filled_outlined;
      case 'emoji_events_outlined':
        return Icons.emoji_events_outlined;
      default:
        return Icons.person_outline;
    }
  }

  // ⭐️ [UPDATE] New Level Logic synced with BadgesScreen
  String _getCurrentLevel(int points) {
    if (points >= 600) return 'Legend';
    if (points >= 400) return 'Worldmaster';
    if (points >= 200) return 'Globetrotter';
    if (points >= 100) return 'Adventurer';
    if (points >= 50) return 'Nomad';
    if (points >= 10) return 'Explorer';
    return 'Rookie';
  }

  // ⭐️ [UPDATE] New Color Theme synced with BadgesScreen
  Color _getLevelColor(String level) {
    switch (level) {
      case 'Rookie':
        return const Color(0xFF8B4513); // Brown
      case 'Explorer':
        return const Color(0xFFFFA726); // Orange/Yellow
      case 'Nomad':
        return const Color(0xFF66BB6A); // Green
      case 'Adventurer':
        return const Color(0xFF26A69A); // Mint
      case 'Globetrotter':
        return const Color(0xFF5C6BC0); // Navy/Indigo
      case 'Worldmaster':
        return const Color(0xFFAB47BC); // Purple
      case 'Legend':
        return const Color(0xFFEC407A); // Pink
      default:
        return const Color(0xFF8B4513);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            // ==================================================================
            // 1. Header with Pure Image Background
            // ==================================================================
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                    image: DecorationImage(
                      image: AssetImage('assets/icons/app_logo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Container(
                    height: 220,
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Travelog',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        fontFamily: 'Pretendard',
                        height: 1.0,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 10.0,
                            color: Color.fromARGB(120, 0, 0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // ==================================================================
                // 2. Profile Card (Overlapping Effect)
                // ==================================================================
                Padding(
                  padding: const EdgeInsets.only(top: 220, left: 24, right: 24),
                  child: _buildProfileSection(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildMainFeatures(context),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                        color: darkMint,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'My Documents',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildDocumentsSection(context),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildSettingsCard(context),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;
        return Consumer<BadgeProvider>(
          builder: (context, badgeProvider, _) {
            // ⭐️ Calculate Points
            final totalPoints = badgeProvider.achievements
                .where((a) => a.isUnlocked)
                .map((a) => a.points)
                .fold(0, (sum, points) => sum + points);

            // ⭐️ Determine Level & Color
            final currentLevel = _getCurrentLevel(totalPoints);
            final levelColor = _getLevelColor(currentLevel);

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ProfileScreen())),
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.grey.shade100, width: 2),
                              image: user?.photoURL != null
                                  ? DecorationImage(
                                image: NetworkImage(user!.photoURL!),
                                fit: BoxFit.cover,
                              )
                                  : null,
                              color: Colors.grey.shade100,
                            ),
                            child: user?.photoURL == null
                                ? Icon(Icons.person,
                                color: Colors.grey.shade400, size: 30)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user?.displayName ?? 'Hello, Traveler',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87)),
                                const SizedBox(height: 4),
                                Text(
                                    user?.email ?? 'Sign in to sync',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade500,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.arrow_forward_ios,
                                size: 14, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: Colors.grey.shade100, height: 1),
                  const SizedBox(height: 20),

                  // Traveler Type Row
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TravelerTypeSelectorScreen(),
                        ),
                      );
                      _loadTravelerType();
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: mint.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(_getTravelerTypeIcon(),
                                  color: darkMint, size: 24)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Traveler Type',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade500)),
                                const SizedBox(height: 2),
                                Text(
                                    _travelerType?.isNotEmpty == true
                                        ? _travelerType!
                                        : 'Analyze DNA',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: _travelerType?.isNotEmpty == true
                                            ? Colors.black87
                                            : Colors.grey.shade400)),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios,
                              size: 14, color: Colors.grey.shade300),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ⭐️ [UPDATE] Achievements Rank Row
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const BadgesScreen())),
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          // Level Icon Image
                          Container(
                            width: 48,
                            height: 48,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: levelColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: levelColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            // Using Asset Image instead of Icon
                            child: Image.asset(
                              'assets/badge_levels/${currentLevel.toLowerCase()}.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Rank',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade500)),
                                const SizedBox(height: 2),
                                Text(
                                  currentLevel,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: levelColor), // Apply level color
                                ),
                              ],
                            ),
                          ),
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: Colors.grey.shade200)),
                              child: Text('$totalPoints pts',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: levelColor))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMainFeatures(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildFeatureCard(
                    context,
                    'Trip Log',
                    '',
                    Icons.auto_stories_rounded,
                    orange,
                        () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const TripLogListScreen())))),
            const SizedBox(width: 12),
            Expanded(
                child: _buildFeatureCard(
                    context,
                    'Discover',
                    '',
                    Icons.explore_rounded,
                    skyBlue,
                        () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RecommendationsScreen())))),
            const SizedBox(width: 12),
            Expanded(
                child: _buildFeatureCard(
                    context,
                    'Favorites',
                    '',
                    Icons.favorite_rounded,
                    pink,
                        () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const FavoritesScreen())))),
          ],
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
            context,
            'Calendar',
            'Plan your next adventure',
            Icons.calendar_month_rounded,
            red,
                () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CalendarScreen())),
            isWide: true),
      ],
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, String subtitle,
      IconData icon, Color color, VoidCallback onTap,
      {bool isWide = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        EdgeInsets.symmetric(vertical: 20, horizontal: isWide ? 20 : 12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ]),
        child: isWide
            ? Row(children: [
          Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 24)),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87)),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500)),
                    ]
                  ])),
          Icon(Icons.arrow_forward_ios,
              size: 14, color: Colors.grey.shade300)
        ])
            : Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24)),
          const SizedBox(height: 12),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87)),
        ]),
      ),
    );
  }

  Widget _buildDocumentsSection(BuildContext context) {
    return Row(children: [
      Expanded(
          child: _buildDocCard(
              context,
              'Passport',
              Icons.book_rounded,
              purple,
                  () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PassportScreen())))),
      const SizedBox(width: 12),
      Expanded(
          child: _buildDocCard(
              context,
              'Visa',
              Icons.article_rounded,
              mint,
                  () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const VisaScreen())))),
    ]);
  }

  Widget _buildDocCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ]),
            child: Column(children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              Text(title,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87))
            ])));
  }

  Widget _buildSettingsCard(BuildContext context) {
    return GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SettingsScreen())),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ]),
            child: Row(children: [
              Icon(Icons.settings_outlined,
                  color: Colors.grey.shade700, size: 24),
              const SizedBox(width: 16),
              const Expanded(
                  child: Text('Settings',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87))),
              Icon(Icons.arrow_forward_ios,
                  size: 14, color: Colors.grey.shade300)
            ])));
  }
}