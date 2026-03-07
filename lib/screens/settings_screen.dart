// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:jidoapp/providers/city_provider.dart';
import 'package:jidoapp/providers/country_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io'; // For exiting the app

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _useWhiteBorders = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('themeMode') ?? 'system';
    _useWhiteBorders = prefs.getBool('useWhiteBorders') ?? false;

    if (mounted) {
      setState(() {
        _themeMode = ThemeMode.values.firstWhere(
              (e) => e.toString().split('.').last == themeString,
          orElse: () => ThemeMode.system,
        );
        _isLoading = false;
      });
    }
  }

  Future<void> _setThemeMode(ThemeMode? themeMode) async {
    if (themeMode == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', themeMode.toString().split('.').last);
    if (mounted) {
      setState(() {
        _themeMode = themeMode;
      });
    }
  }

  Future<void> _setUseWhiteBorders(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useWhiteBorders', value);
    if (mounted) {
      setState(() {
        _useWhiteBorders = value;
      });
    }
  }

  Future<void> _resetAllData(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Reset'),
          content: const Text(
              'Are you sure you want to reset all data? This will clear all your visited countries, cities, landmarks, trip logs, and other records. This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Reset Complete'),
            content: const Text(
                'All data has been reset. Please restart the app for the changes to take full effect.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  exit(0); // Force exit app
                },
                child: const Text('OK & Restart App'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access Providers
    final countryProvider = Provider.of<CountryProvider>(context);
    final cityProvider = Provider.of<CityProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Title replacement for AppBar
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            // Theme Settings
            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text('Theme'),
              trailing: DropdownButton<ThemeMode>(
                value: _themeMode,
                onChanged: _setThemeMode,
                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('System Default'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Light'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Dark'),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Include Territories Switch
            SwitchListTile(
              secondary: const Icon(Icons.public_off_outlined),
              title: const Text('Include Territories'),
              subtitle: const Text('Include territories in all statistics'),
              value: countryProvider.includeTerritories,
              onChanged: (bool value) {
                countryProvider.toggleIncludeTerritories();
              },
            ),
            const Divider(),

            // Border Color Settings
            SwitchListTile(
              secondary: const Icon(Icons.border_color_outlined),
              title: const Text('Use White Borders'),
              subtitle: const Text(
                  'Use white borders instead of dark borders for country boundaries'),
              value: _useWhiteBorders,
              onChanged: _setUseWhiteBorders,
            ),
            const Divider(),

            // Country Ranking Bar Color Settings
            SwitchListTile(
              secondary: const Icon(Icons.color_lens_outlined),
              title: const Text('Use Default Country Ranking Bar Color'),
              subtitle: const Text(
                  'Use a single primary color for all country ranking bars instead of continent-specific colors.'),
              value: countryProvider.useDefaultRankingBarColor,
              onChanged: (bool value) {
                countryProvider.setUseDefaultRankingBarColor(value);
              },
            ),
            const Divider(),

            // City Ranking Bar Color Settings
            SwitchListTile(
              secondary: const Icon(Icons.location_city_outlined),
              title: const Text('Use Default City Ranking Bar Color'),
              subtitle: const Text(
                  'Use a single primary color for all city ranking bars instead of continent-specific colors.'),
              value: cityProvider.useDefaultCityRankingBarColor,
              onChanged: (bool value) {
                cityProvider.setUseDefaultCityRankingBarColor(value);
              },
            ),
            const Divider(),

            // Reset All Data
            ListTile(
              leading: const Icon(Icons.warning_amber_rounded,
                  color: Colors.red),
              title: const Text('Reset All Data'),
              subtitle: const Text(
                  'Deletes all visited records, logs, and settings.'),
              onTap: () => _resetAllData(context),
            ),
          ],
        ),
      ),
    );
  }
}