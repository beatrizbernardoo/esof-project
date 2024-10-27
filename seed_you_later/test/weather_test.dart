import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_you_later/weather_card.dart';

void main() {
  testWidgets('WeatherCard widget test', (WidgetTester tester) async {

    final weatherData = '''
      {
        "location": {
          "name": "New York",
          "region": "NY",
          "country": "USA"
        },
        "current": {
          "temp_c": 20.0,
          "humidity": 80,
          "condition": {
            "text": "Sunny",
            "icon": ""
          },
          "wind_kph": 10.0,
          "wind_degree": 180,
          "wind_dir": "S",
          "precip_mm": 5.0,
          "cloud": 50
        }
      }
    ''';

    // Build the WeatherCard widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeatherCard.fromJson(weatherData),
        ),
      ),
    );


    expect(find.text('New York, USA'), findsOneWidget);
    expect(find.text('20.0°C'), findsOneWidget);
    expect(find.text('Humidity:'), findsOneWidget);
    expect(find.text('80%'), findsOneWidget);
    expect(find.text('Wind Speed:'), findsOneWidget);
    expect(find.text('10.0 kph'), findsOneWidget);
    expect(find.text('Precipitation:'), findsOneWidget);
    expect(find.text('5.0 mm'), findsOneWidget);
  });

}
