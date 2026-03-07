// lib/main_screen.dart

import 'package:flutter/material.dart';
import 'package:jidoapp/screens/cities_menu_screen.dart';
import 'package:jidoapp/screens/countries_menu_screen.dart';
import 'package:jidoapp/screens/explore_menu_screen.dart';
import 'package:jidoapp/screens/flights_menu_screen.dart';
import 'package:jidoapp/screens/my_trips_tab_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const MyTripsTabScreen(), // 1. My Trips (Index 0)
    const CountriesMenuScreen(), // 2. Countries
    const CitiesMenuScreen(), // 3. Cities
    const ExploreMenuScreen(), // 4. Explore
    FlightsMenuScreen(), // 5. Flights
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<IconData> _icons = [
    Icons.card_travel, // 1. My Trips
    Icons.public, // 2. Countries
    Icons.add_location_alt_rounded, // 3. Cities
    Icons.explore, // 4. Explore
    Icons.flight_takeoff_rounded, // 5. Flights
  ];

  final List<String> _labels = [
    'My Trips', // 1. My Trips
    'Countries', // 2. Countries
    'Cities', // 3. Cities
    'Explore', // 4. Explore
    'Flights', // 5. Flights
  ];

  final Color mintColor = const Color(0xFF3DDAD7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false, // 하단은 bottomNavigationBar에서 처리
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 8,
            ),
            child: SizedBox(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_icons.length, (index) {
                  final isSelected = _selectedIndex == index;

                  return GestureDetector(
                    onTap: () => _onItemTapped(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? mintColor.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _icons[index],
                            size: isSelected ? 28 : 24,
                            color: isSelected ? mintColor : Colors.grey,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _labels[index],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected ? mintColor : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}