import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:seed_you_later/plant.dart';
import 'package:seed_you_later/plant_service.dart';

class ApiKey {
  static String plantApiKey = 'k-gxtw65fdd643c90c84828';
}

class PlantException implements Exception {
  final String message;

  PlantException(this.message);

  @override
  String toString() {
    return 'PlantException: $message';
  }
}

Future<List<Plant>> fetchPlants(int limit) async {
  List<Plant> allPlants = [];

  for (int page = 1; page <= limit; page++) {
    final response = await http.get(Uri.parse('https://perenual.com/api/species-list?key=${ApiKey.plantApiKey}&page=$page'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<dynamic> plantData = jsonData['data'];
      allPlants.addAll(plantData.map((item) => Plant.fromJson(item)));
    } else {
      throw PlantException('Failed to load plants: ${response.statusCode}');
    }
  }

  return allPlants;
}

void main() {
  group('fetchPlants', () {
    test('fetchPlants should throw PlantException for invalid API key', () async {
      ApiKey.plantApiKey = 'invalid-key';
      expect(
        () async => await fetchPlants(1),
        throwsA(isA<PlantException>()),
      );
    });
  });
}
