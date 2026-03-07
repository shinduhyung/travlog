// lib/screens/flight_records_stats_screen.dart

import 'package:flutter/material.dart';

class FlightRecordsStatsScreen extends StatelessWidget {
  const FlightRecordsStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flight Records')),
      body: const Center(
        child: Text('Flight Records Screen'),
      ),
    );
  }
}