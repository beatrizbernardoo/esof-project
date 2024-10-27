import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:seed_you_later/weather_service.dart';


class ApiKey {
  static const String weatherApiKey = '1d4ad9c5c73948c1936220356242503';
}

class WeatherService {
  static Future<WeatherResponse> fetchWeather(String city) async {
    final response = await http.get(Uri.parse(
        'http://api.weatherapi.com/v1/current.json?key=${ApiKey.weatherApiKey}&q=$city'));

    if (response.statusCode == 200) {
      return WeatherResponse.fromJson(jsonDecode(response.body));
    } else {
      throw WeatherException('Failed to load weather: ${response.statusCode}');
    }
  }
}

class WeatherResponse {
  final String location;
  final String condition;

  WeatherResponse({required this.location, required this.condition});

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    return WeatherResponse(
      location: json['location']['name'],
      condition: json['current']['condition']['text'],
    );
  }
}

class WeatherException implements Exception {
  final String message;

  WeatherException(this.message);

  @override
  String toString() {
    return 'WeatherException: $message';
  }
}

void main() {
  group('WeatherService', () {
    test('fetchWeather should return WeatherResponse', () async {
      
      final weatherResponse = await WeatherService.fetchWeather('New York');
      expect(weatherResponse, isA<WeatherResponse>());
    });

    test('fetchWeather should throw WeatherException for invalid city', () async {
      expect(
        () async => await WeatherService.fetchWeather('InvalidCity'),
        throwsA(isA<WeatherException>()),
      );
    });
  });
}