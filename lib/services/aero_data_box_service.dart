// lib/services/aero_data_box_service.dart

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:jidoapp/models/flight_info.dart';

class AeroDataBoxService {
  final String? _apiKey = dotenv.env['AERODATABOX_API_KEY'];
  final String _baseUrl = 'https://aerodatabox.p.rapidapi.com';

  Future<FlightInfo?> getFlightInfo(String flightNumber, String date) async {
    if (_apiKey == null) {
      throw Exception('AERODATABOX_API_KEY not found in .env file');
    }

    final String url = '$_baseUrl/flights/number/$flightNumber/$date?withAircraft=false&withLocation=false';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'X-RapidAPI-Key': _apiKey!,
        'X-RapidAPI-Host': 'aerodatabox.p.rapidapi.com',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> flights = json.decode(response.body);
      if (flights.isNotEmpty) {
        final Map<String, dynamic> flightData = flights[0];

        // ⭐⭐⭐ 바로 이 부분입니다! 콘솔 출력을 위해 코드를 다시 추가했습니다. ⭐⭐⭐
        print('AeroDataBox API Raw Response Data for flight[0]:');
        print(json.encode(flightData));

        return FlightInfo.fromAeroDataBoxJson(flightData);
      }
      return null;
    } else {
      throw Exception('Failed to load flight info: ${response.body}');
    }
  }
}