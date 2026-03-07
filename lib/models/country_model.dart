// lib/models/country_model.dart

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class Country {
  final String name;
  final String isoA2;
  final String isoA3;
  final String? continent;
  final String? subregion;
  int populationEst;
  final int gdpMd;
  final List<List<List<LatLng>>> polygonsData;
  final double area;
  final double avgTemp;
  final double avgPrecipitation;
  final int islandCount;
  final int coastlineLength;
  final int lakeCount;
  final int elevationHighest;
  final int elevationAverage;
  final double centroidLat;
  final double northLat;
  final double southLat;
  final double capitalLat;
  final String? climateZone;
  final bool isTerritory;

  // Popularity Score (-7 to +7)
  final int countryPopularity;

  // Existing Indicators
  final double? fertilityRate;
  final double? homicideRate;
  final double? lifeExpectancy;
  final double? immigrantRate;
  final double? hdi;
  final double? obesityRate;
  final double? PwrIndx;
  final double? militaryExpenditure;
  final int? armedForcesPersonnel;
  final int? nukesTotal;
  final int? aircraftCarriersTotal;
  final int? navyShipsTotal;
  final int? totalAircraft;
  final int? tanksTotal;
  final double? iq;
  final double? maleHeight;
  final double? femaleHeight;
  final double? novel;
  final double? democracy;
  final int? summerGold;
  final int? summerTotal;
  final int? winterGold;
  final int? winterTotal;

  // Health & Society Indicators
  final double? hivPrevalence;
  final double? alzheimersCaseRate;
  final double? cancerRate;
  final double? opiateUsage;
  final double? covidVaccinationRate;
  final int? specialistDoctorPay;
  final double? hospitalBeds;

  // New Health Indicators (Alcohol, Smoking, Firearms)
  final double? alcoholConsumption;
  final double? smokersPercent;
  final double? firearmOwnership;

  // Other Indicators
  final double? tertiaryEducation;
  final double? sexRatio;
  final double? malePatternBaldness;

  // War Casualties
  final int? ww1Casualties;
  final int? ww2Casualties;

  // Age Related Indicators
  final double? medianAge;
  final double? ageAtFirstMarriage;
  final double? avgAgeFirstBirth;

  // Technology & Social Media
  final double? internetPenetration;
  final double? internetSpeed;
  final double? internetUsers;
  final double? facebookUsers;
  final double? instagramUsers;
  final double? youtubeUsers;

  // Religion Population
  final int? hinduPop;
  final int? sikhPop;
  final int? jewishPop;
  final int? muslimPop;
  final int? christianPop;
  final int? buddhistPop;

  // Catholic Hierarchy
  final int? popeCount;
  final int? cardinalCount;

  final Color? themeColor;

  static const Set<String> _territoryCodes = {
    'FO', 'GG', 'IM', 'JE', 'AX', 'AI', 'VG', 'FK', 'KY', 'CW', 'PR', 'SX',
    'MF', 'BL', 'TC', 'VI', 'BM', 'GL', 'PM', 'NF', 'NC', 'GU', 'MP', 'AS',
    'CK', 'PF', 'NU', 'PN', 'WF', 'HK', 'MO', 'AW', 'MS', 'GI'
  };

  Country({
    required this.name,
    required this.isoA2,
    required this.isoA3,
    this.continent,
    this.subregion,
    required this.populationEst,
    required this.gdpMd,
    required this.polygonsData,
    required this.area,
    required this.avgTemp,
    required this.avgPrecipitation,
    required this.islandCount,
    required this.coastlineLength,
    required this.lakeCount,
    required this.elevationHighest,
    required this.elevationAverage,
    required this.centroidLat,
    required this.northLat,
    required this.southLat,
    required this.capitalLat,
    this.climateZone,
    required this.isTerritory,
    required this.countryPopularity,
    this.fertilityRate,
    this.homicideRate,
    this.lifeExpectancy,
    this.immigrantRate,
    this.hdi,
    this.obesityRate,
    this.PwrIndx,
    this.militaryExpenditure,
    this.armedForcesPersonnel,
    this.nukesTotal,
    this.aircraftCarriersTotal,
    this.navyShipsTotal,
    this.totalAircraft,
    this.tanksTotal,
    this.iq,
    this.maleHeight,
    this.femaleHeight,
    this.novel,
    this.democracy,
    this.summerGold,
    this.summerTotal,
    this.winterGold,
    this.winterTotal,
    this.hivPrevalence,
    this.alzheimersCaseRate,
    this.cancerRate,
    this.opiateUsage,
    this.covidVaccinationRate,
    this.specialistDoctorPay,
    this.hospitalBeds,
    this.alcoholConsumption,
    this.smokersPercent,
    this.firearmOwnership,
    this.tertiaryEducation,
    this.sexRatio,
    this.malePatternBaldness,
    this.medianAge,
    this.ageAtFirstMarriage,
    this.avgAgeFirstBirth,
    this.internetPenetration,
    this.internetSpeed,
    this.internetUsers,
    this.facebookUsers,
    this.instagramUsers,
    this.youtubeUsers,
    this.hinduPop,
    this.sikhPop,
    this.jewishPop,
    this.muslimPop,
    this.christianPop,
    this.buddhistPop,
    this.popeCount,
    this.cardinalCount,
    this.ww1Casualties,
    this.ww2Casualties,
    this.themeColor,
  });

  factory Country.fromJson(
      Map<String, dynamic> feature, {
        required double area,
        required double avgTemp,
        required double avgPrecipitation,
        required int islandCount,
        required int coastlineLength,
        required int lakeCount,
        required int elevationHighest,
        required int elevationAverage,
        required double centroidLat,
        required double northLat,
        required double southLat,
        required double capitalLat,
        required int countryPopularity,
        String? climateZone,
        double? fertilityRate,
        double? homicideRate,
        double? lifeExpectancy,
        double? immigrantRate,
        double? hdi,
        double? obesityRate,
        double? PwrIndx,
        double? militaryExpenditure,
        int? armedForcesPersonnel,
        int? nukesTotal,
        int? aircraftCarriersTotal,
        int? navyShipsTotal,
        int? totalAircraft,
        int? tanksTotal,
        double? iq,
        double? maleHeight,
        double? femaleHeight,
        double? novel,
        double? democracy,
        int? summerGold,
        int? summerTotal,
        int? winterGold,
        int? winterTotal,
        double? hivPrevalence,
        double? alzheimersCaseRate,
        double? cancerRate,
        double? opiateUsage,
        double? covidVaccinationRate,
        int? specialistDoctorPay,
        double? hospitalBeds,
        double? alcoholConsumption,
        double? smokersPercent,
        double? firearmOwnership,
        double? tertiaryEducation,
        double? sexRatio,
        double? malePatternBaldness,
        double? medianAge,
        double? ageAtFirstMarriage,
        double? avgAgeFirstBirth,
        double? internetPenetration,
        double? internetSpeed,
        double? internetUsers,
        double? facebookUsers,
        double? instagramUsers,
        double? youtubeUsers,
        int? hinduPop,
        int? sikhPop,
        int? jewishPop,
        int? muslimPop,
        int? christianPop,
        int? buddhistPop,
        int? popeCount,
        int? cardinalCount,
        int? ww1Casualties,
        int? ww2Casualties,
        Color? themeColor,
      }) {
    final properties = feature['properties'] as Map<String, dynamic>;
    final geometry = feature['geometry'] as Map<String, dynamic>;

    final List<List<List<LatLng>>> polygonsData = [];
    final coordinates = geometry['coordinates'] as List;

    void addPolygon(List polygonCoords) {
      final List<List<LatLng>> polygonRings = [];
      for (var ring in polygonCoords) {
        final List<LatLng> points = (ring as List)
            .map((point) => LatLng(
          ((point as List)[1] as num).toDouble(),
          ((point as List)[0] as num).toDouble(),
        ))
            .toList();
        polygonRings.add(points);
      }
      polygonsData.add(polygonRings);
    }

    if (geometry['type'] == 'Polygon') {
      addPolygon(coordinates);
    } else if (geometry['type'] == 'MultiPolygon') {
      for (var polygon in coordinates) {
        addPolygon(polygon as List);
      }
    }

    final isoA2 = properties['iso_a2'] as String;

    return Country(
      name: properties['name'] as String,
      isoA2: isoA2,
      isoA3: properties['iso_a3_eh'] ?? properties['iso_a3'] ?? 'N/A',
      continent: properties['continent'] as String?,
      subregion: properties['subregion'] as String?,
      populationEst: 0,
      gdpMd: (properties['gdp_md_est'] as num? ?? 0).toInt(),
      polygonsData: polygonsData,
      area: area,
      avgTemp: avgTemp,
      avgPrecipitation: avgPrecipitation,
      islandCount: islandCount,
      coastlineLength: coastlineLength,
      lakeCount: lakeCount,
      elevationHighest: elevationHighest,
      elevationAverage: elevationAverage,
      centroidLat: centroidLat,
      northLat: northLat,
      southLat: southLat,
      capitalLat: capitalLat,
      climateZone: climateZone,
      isTerritory: _territoryCodes.contains(isoA2),
      countryPopularity: countryPopularity,
      fertilityRate: fertilityRate,
      homicideRate: homicideRate,
      lifeExpectancy: lifeExpectancy,
      immigrantRate: immigrantRate,
      hdi: hdi,
      obesityRate: obesityRate,
      PwrIndx: PwrIndx,
      militaryExpenditure: militaryExpenditure,
      armedForcesPersonnel: armedForcesPersonnel,
      nukesTotal: nukesTotal,
      aircraftCarriersTotal: aircraftCarriersTotal,
      navyShipsTotal: navyShipsTotal,
      totalAircraft: totalAircraft,
      tanksTotal: tanksTotal,
      iq: iq,
      maleHeight: maleHeight,
      femaleHeight: femaleHeight,
      novel: novel,
      democracy: democracy,
      summerGold: summerGold,
      summerTotal: summerTotal,
      winterGold: winterGold,
      winterTotal: winterTotal,
      hivPrevalence: hivPrevalence,
      alzheimersCaseRate: alzheimersCaseRate,
      cancerRate: cancerRate,
      opiateUsage: opiateUsage,
      covidVaccinationRate: covidVaccinationRate,
      specialistDoctorPay: specialistDoctorPay,
      hospitalBeds: hospitalBeds,
      alcoholConsumption: alcoholConsumption,
      smokersPercent: smokersPercent,
      firearmOwnership: firearmOwnership,
      tertiaryEducation: tertiaryEducation,
      sexRatio: sexRatio,
      malePatternBaldness: malePatternBaldness,
      medianAge: medianAge,
      ageAtFirstMarriage: ageAtFirstMarriage,
      avgAgeFirstBirth: avgAgeFirstBirth,
      internetPenetration: internetPenetration,
      internetSpeed: internetSpeed,
      internetUsers: internetUsers,
      facebookUsers: facebookUsers,
      instagramUsers: instagramUsers,
      youtubeUsers: youtubeUsers,
      hinduPop: hinduPop,
      sikhPop: sikhPop,
      jewishPop: jewishPop,
      muslimPop: muslimPop,
      christianPop: christianPop,
      buddhistPop: buddhistPop,
      popeCount: popeCount,
      cardinalCount: cardinalCount,
      ww1Casualties: ww1Casualties,
      ww2Casualties: ww2Casualties,
      themeColor: themeColor,
    );
  }
}