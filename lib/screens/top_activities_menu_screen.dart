import 'package:flutter/material.dart';
import 'package:jidoapp/screens/top_paintings_screen.dart';
import 'package:jidoapp/screens/disneyland_screen.dart';
import 'package:jidoapp/screens/universal_studios_screen.dart';
import 'package:jidoapp/screens/champions_league_teams_screen.dart';
import 'package:jidoapp/screens/film_festivals_screen.dart';
import 'package:jidoapp/screens/top_orchestras_screen.dart';

class TopActivitiesMenuScreen extends StatelessWidget {
  const TopActivitiesMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {
        'title': 'Best Paintings',
        'icon': Icons.palette_outlined,
        'gradient': [const Color(0xFFFF6B9D), const Color(0xFFC06C84)],
      },
      {
        'title': 'Film Festivals',
        'icon': Icons.local_movies_outlined,
        'gradient': [const Color(0xFF667EEA), const Color(0xFF764BA2)],
      },
      {
        'title': 'Disneyland',
        'icon': Icons.castle_outlined,
        'gradient': [const Color(0xFFf093fb), const Color(0xFFf5576c)],
      },
      {
        'title': 'Universal Studio',
        'icon': Icons.movie_filter_outlined,
        'gradient': [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
      },
      {
        'title': 'Champions League Winning Teams',
        'icon': Icons.emoji_events_outlined,
        'gradient': [const Color(0xFFffecd2), const Color(0xFFfcb69f)],
      },
      {
        'title': 'Best Orchestras',
        'icon': Icons.music_note_outlined,
        'gradient': [const Color(0xFF6B4EFF), const Color(0xFF8B6EFF)],
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Top Activities',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: Color(0xFF1a1a1a),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Explore the best experiences',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 32),

              Expanded(
                child: ListView.separated(
                  itemCount: menuItems.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return _buildMenuItem(
                      context,
                      title: item['title'] as String,
                      icon: item['icon'] as IconData,
                      gradient: item['gradient'] as List<Color>,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, {
        required String title,
        required IconData icon,
        required List<Color> gradient,
      }) {
    return GestureDetector(
      onTap: () {
        if (title == 'Best Paintings') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TopPaintingsScreen()));
        } else if (title == 'Film Festivals') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const FilmFestivalsScreen()));
        } else if (title == 'Disneyland') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const DisneylandScreen()));
        } else if (title == 'Universal Studio') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const UniversalStudiosScreen()));
        } else if (title == 'Champions League Winning Teams') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ChampionsLeagueTeamsScreen()));
        } else if (title == 'Best Orchestras') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TopOrchestrasScreen()));
        }
      },
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1a1a1a),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}