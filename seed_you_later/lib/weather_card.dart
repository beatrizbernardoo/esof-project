import 'dart:convert';
import 'package:flutter/material.dart';

class WeatherCard extends StatelessWidget {
  final String locationName;
  final String region;
  final String country;
  final double temperature;
  final int humidity;
  final String conditionText;
  final String conditionIconUrl;
  final double windSpeed;
  final int windDegree;
  final String windDirection;
  final double precipitationMm;
  final int cloud;

  const WeatherCard({
    required this.locationName,
    required this.region,
    required this.country,
    required this.temperature,
    required this.humidity,
    required this.conditionText,
    required this.conditionIconUrl,
    required this.windSpeed,
    required this.windDegree,
    required this.windDirection,
    required this.precipitationMm,
    required this.cloud,
  });

  factory WeatherCard.fromJson(String jsonStr) {
    final Map<String, dynamic> data = json.decode(jsonStr);
    final locationData = data['location'];
    final currentData = data['current'];

    return WeatherCard(
      locationName: locationData['name'],
      region: locationData['region'],
      country: locationData['country'],
      temperature: currentData['temp_c'].toDouble(),
      humidity: currentData['humidity'],
      conditionText: currentData['condition']['text'],
      conditionIconUrl: currentData['condition']['icon'],
      windSpeed: currentData['wind_kph'],
      windDegree: currentData['wind_degree'],
      windDirection: currentData['wind_dir'],
      precipitationMm: currentData['precip_mm'],
      cloud: currentData['cloud'],
    );
  }

  Color _getCardColor() {
    if (temperature < 10) {
      return const Color.fromARGB(255, 73, 167, 244);
    } else if (temperature >= 10 && temperature < 25) {
      return Colors.yellow;
    } else if (temperature >= 25 && temperature < 36) {
      return const Color.fromARGB(255, 255, 162, 22);
    } else {
      return const Color.fromARGB(255, 251, 83, 72);
    }
  }

  Widget _buildConditionIcon() {
    if (conditionIconUrl.isNotEmpty) {
      return Image.network(
        'https:' + conditionIconUrl,
        width: 64,
        height: 64,
      );
    } else {
      return Icon(Icons.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Card(
        color: _getCardColor(),
        margin: EdgeInsets.all(2.0),
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weather:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '$locationName, $country',
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      _buildConditionIcon(),
                      SizedBox(width: 10),
                      Text(
                        '$temperature°C',
                        style: TextStyle(fontSize: 45),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text('Humidity:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text('$humidity%', style: TextStyle(fontSize: 12)),
                  SizedBox(height: 10),
                  Text('Wind Degree:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text('$windDegree°', style: TextStyle(fontSize: 12)),
                  SizedBox(height: 10),
                  Text('Condition:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text('$conditionText', style: TextStyle(fontSize: 12)),
                ],
              ),
              SizedBox(width: 10),
              Padding(
                padding: EdgeInsets.only(left: 12.0),
                child: Transform.translate(
                  offset: Offset(0, 120), 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 47),
                      Text('Wind Direction:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text('$windDirection', style: TextStyle(fontSize: 12)),
                      SizedBox(height: 10),
                      Text('Wind Speed:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text('$windSpeed kph', style: TextStyle(fontSize: 12)),
                      SizedBox(height: 10),
                      Text('Cloud:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text('$cloud%', style: TextStyle(fontSize: 12)),
                      SizedBox(height: 10),
                      Text('Precipitation:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text('$precipitationMm mm', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}









