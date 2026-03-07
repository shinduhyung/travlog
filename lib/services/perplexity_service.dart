// lib/services/perplexity_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;

class PerplexityService {
  final String _apiKey = dotenv.env['PERPLEXITY_API_KEY'] ?? 'NO_KEY';
  final String _apiUrl = 'https://api.perplexity.ai/chat/completions'; // Perplexity API 엔드포인트

  Future<Map<String, double>?> getCityCoordinates(String cityName) async {
    if (_apiKey == 'NO_KEY') {
      developer.log("Perplexity API Key not found in .env file.", name: 'PerplexityService');
      return null;
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    };

    final body = jsonEncode({
      "model": "llama-3-sonar-small-32k-online", // 온라인 검색이 가능한 모델 사용
      "messages": [
        {"role": "system", "content": "You are a helpful assistant. When asked for city coordinates, provide only the latitude and longitude in a JSON object format. For example, if asked for 'London', respond with {\"latitude\": 51.5074, \"longitude\": -0.1278}. If you cannot find, return an empty JSON {}. Ensure the coordinates are accurate for the geographical center of the city."},
        {"role": "user", "content": "What are the latitude and longitude for $cityName?"}
      ],
      "max_tokens": 50, // 짧은 응답을 위해 max_tokens 제한
      "temperature": 0.1, // 정확한 답변을 위해 낮은 온도 설정
    });

    try {
      final response = await http.post(Uri.parse(_apiUrl), headers: headers, body: body);
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        final content = responseBody['choices'][0]['message']['content'];
        developer.log('[DEBUG Perplexity Service] Raw API response content for $cityName: $content', name: 'PerplexityService');

        try {
          final Map<String, dynamic> coords = jsonDecode(content);
          if (coords.containsKey('latitude') && coords.containsKey('longitude')) {
            return {
              'latitude': coords['latitude'],
              'longitude': coords['longitude'],
            };
          }
        } catch (e) {
          developer.log('Failed to parse coordinates JSON from Perplexity response: $e, content: $content', name: 'PerplexityService');
        }
        return null;
      } else {
        developer.log('Perplexity API Error for $cityName: Status Code ${response.statusCode}, Body: ${response.body}', name: 'PerplexityService');
        return null;
      }
    } catch (e) {
      developer.log('Error connecting to Perplexity API for $cityName: $e', name: 'PerplexityService');
      return null;
    }
  }
}