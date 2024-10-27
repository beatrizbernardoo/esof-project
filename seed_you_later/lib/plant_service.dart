import 'dart:convert';
import 'package:http/http.dart' as http;
import 'plant.dart';

Future<List<Plant>> fetchPlants(int limit) async {
  List<Plant> allPlants = [];

  for (int page = 1; page <= limit; page++) {
    final response = await http.get(Uri.parse('https://perenual.com/api/species-list?key=sk-gxtw65fdd643c90c84828&page=$page'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<dynamic> plantData = jsonData['data'];
      allPlants.addAll(plantData.map((item) => Plant.fromJson(item)));
    } else {
      throw Exception('Failed to load plants: ${response.statusCode}');
    }
  }

  return allPlants;
}

/*
 for (var plantJson in plantData) {
        // Extract the ID of the plant
        int id = plantJson['id'];

        // Fetch additional details for the plant using its ID
        final detailsResponse = await http.get(Uri.parse('https://perenual.com/api/species/details/$id?key=sk-BarZ662fbe55f15f15285'));
        if (detailsResponse.statusCode == 200) {
          final detailsJson = jsonDecode(detailsResponse.body);

          Plant plant = Plant.fromJson({
            ...plantJson,
            'floweringSeason': detailsJson['flowering_season'],
            'attracts': detailsJson['attracts'],
            'wateringPeriod': detailsJson['watering_period'],
            'depthWaterRequirement': detailsJson['depth_water_requirement'],
          });
* */





