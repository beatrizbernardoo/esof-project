import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Plant {
  String id;
  final String commonName;
  final List<String> scientificName;
  final String cycle;
  final String watering;
  final List<String> sunlight;
  final Map<String, dynamic> defaultImage;
  TimeOfDay wateringTime = TimeOfDay(hour: 8, minute: 30);
  String status = "Alive";
  //final String floweringSeason;
  //final List<String> attracts;
  //final String wateringPeriod;
  //final Map<String, dynamic>? depthWaterRequirement;
  
  Plant({
    required this.id,
    required this.commonName,
    required this.scientificName,
    required this.cycle,
    required this.watering,
    required this.sunlight,
    required this.defaultImage,
    //required this.floweringSeason,
    //required this.attracts,
    //required this.wateringPeriod,
    //required this.depthWaterRequirement,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: (json['id'].toString()) ?? "",
      commonName: json['common_name'] ?? '',
      scientificName: List<String>.from(json['scientific_name'] ?? []),
      cycle: json['cycle'] ?? '',
      watering: json['watering'] ?? '',
      sunlight: List<String>.from(json['sunlight'] ?? []),
      defaultImage: Map<String, dynamic>.from(json['default_image'] ?? {}),
      //floweringSeason: json['flowering_season'] ?? "",
      //attracts: List<String>.from(json['attracts'] ?? []),
      //wateringPeriod: json['watering_period'] ?? "",
      //depthWaterRequirement: Map<String, dynamic>.from(json['depth_water_requirement'] ?? {}),
    );
  }

}


