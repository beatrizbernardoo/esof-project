import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart'; 


import 'package:seed_you_later/plant.dart';
import 'package:seed_you_later/plantDetailScreen.dart';

// Mock de http.Client
class MockClient extends Mock implements http.Client {}

void main() {
  group('Plant', () {
    test('fromJson creates Plant object', () {
      final plant = Plant.fromJson({
        'id': '1',
        'common_name': 'Plant Name',
        'scientific_name': ['Scientific Name'],
        'cycle': 'Cycle',
        'watering': 'Frequent',
        'sunlight': ['full sun'],
        'default_image': {'original_url': 'https://example.com/image.jpg'},
      });

      expect(plant.id, '1');
      expect(plant.commonName, 'Plant Name');
      expect(plant.scientificName, ['Scientific Name']);
      expect(plant.cycle, 'Cycle');
      expect(plant.watering, 'Frequent');
      expect(plant.sunlight, ['full sun']);
      expect(plant.defaultImage['original_url'], 'https://example.com/image.jpg');
    });
  });

}
