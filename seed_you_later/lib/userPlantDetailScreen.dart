import 'package:flutter/material.dart';
import 'plant.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:url_launcher/url_launcher.dart'; // Import for opening the map URL




class UserPlantDetailScreen extends StatefulWidget {
  final Plant plant;
  final String? currentUserId;

  const UserPlantDetailScreen({Key? key, required this.plant, required this.currentUserId}) : super(key: key);

  @override
  _UserPlantDetailScreenState createState() => _UserPlantDetailScreenState();
}

class _UserPlantDetailScreenState extends State<UserPlantDetailScreen> {
  TimeOfDay? _wateringTime;
  //String _status = '';
  String _selectedStatus = 'Alive';

  @override
  void initState() {
    super.initState();
    _wateringTime = TimeOfDay(hour: 8, minute: 30);
    _selectedStatus = 'Alive';
    _loadWateringTime();
    _loadStatus();
  }

  Future<void> _loadWateringTime() async {
    String? watTime = await getCurrentPlantWaterTime(widget.plant.id, widget.currentUserId);
    if (watTime != null) {
      setState(() {
        _wateringTime = parseTimeStringToTimeOfDay(watTime);
      });
    } else {
      // Handle case when watering time is null or not found
    }
  }
  Future<void> _loadStatus() async {
    String? stat = await getCurrentPlantStatus(widget.plant.id, widget.currentUserId);
    if (stat != null) {
      setState(() {
        _selectedStatus = stat;
        //if (stat == "Alive")
        //  Image.asset('assets/images/status1.png');
      });
    } else {
      //
    }
  }

  Map<String, IconData> wateringIcons = {
    'Average': Icons.opacity,
    'Frequent': Icons.shower,
    // Add more conditions here
  };

  // Map for sunlight conditions
  Map<String, IconData> sunlightIcons = {
    'full sun': Icons.wb_sunny,
    'Part shade': Icons.cloud,
    // Add more conditions here
  };

  TimeOfDay parseTimeStringToTimeOfDay(String timeString) {
    List<String> parts = timeString.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<String?> getCurrentPlantWaterTime(String plantId,String? currentUserId) async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp();

      // Get the document snapshot for the plant with the given ID
      DocumentSnapshot plantSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .collection("plants")
          .doc(plantId)
          .get();

      // Check if the document exists
      if (plantSnapshot.exists) {
        // Get the watering time from the plant document
        String? wateringTime = plantSnapshot.get('wateringTime');

        // Return the watering time
        return wateringTime;
      } else {
        // Plant document doesn't exist
        print('Plant document $plantId does not exist');
        return null;
      }
    } catch (error) {
      print("Error fetching plant watering time: $error");
      throw Exception("Error fetching plant watering time: $error");
    }
  }
  Future<String?> getCurrentPlantStatus(String plantId,String? currentUserId) async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp();

      // Get the document snapshot for the plant with the given ID
      DocumentSnapshot plantSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .collection("plants")
          .doc(plantId)
          .get();

      // Check if the document exists
      if (plantSnapshot.exists) {
        // Get the status from the plant document
        String? status = plantSnapshot.get('status');

        // Return the status
        return status;
      } else {
        // Plant document doesn't exist
        print('Plant document $plantId does not exist');
        return null;
      }
    } catch (error) {
      print("Error fetching plant status: $error");
      throw Exception("Error fetching plant status: $error");
    }
  }

  Future<void> _updateWateringTime(String newWateringTime) async {
    try {
      await Firebase.initializeApp();

      // Update the watering time of the plant in the database
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.currentUserId)
          .collection("plants")
          .doc(widget.plant.id)
          .update({'wateringTime': newWateringTime});

      // Show a confirmation message or handle success as needed
    } catch (error) {
      print("Error updating watering time: $error");
      // Handle error updating watering time
    }
    _loadWateringTime();
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      await Firebase.initializeApp();

      // Update the watering time of the plant in the database
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.currentUserId)
          .collection("plants")
          .doc(widget.plant.id)
          .update({'status': newStatus});

      // Show a confirmation message or handle success as needed
    } catch (error) {
      print("Error updating status : $error");
      // Handle error updating status
    }
    _loadStatus();
  }

  Future<void> _selectWateringTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _wateringTime!,
    );
    if (pickedTime != null && pickedTime != _wateringTime) {
      String newWateringTimeString = "${pickedTime.hour}:${pickedTime.minute}";

      // Update watering time in the database
      await _updateWateringTime(newWateringTimeString);

      // Show a confirmation message or handle success as needed
    }
  }

  Widget dropDown(BuildContext context) {
    return DropdownButton<String>(
      value: _selectedStatus,
      onChanged: (String? newValue) {
        setState(() {
          _selectedStatus = newValue!;
          _updateStatus(_selectedStatus);
        });
      },
      items: <String>[
        'Alive', 
        'Dead', 
        'Needs Care', 
        'Thriving'
      ].map((String value) {
        IconData iconData;
        Color iconColor;
        switch (value) {
          case 'Alive':
            iconData = Icons.favorite; // Ícone para "Alive"
            iconColor = Colors.yellow; // Cor para "Alive"
            break;
          case 'Dead':
            iconData = Icons.grass; // Ícone para "Dead"
            iconColor = Colors.grey; // Cor para "Dead"
            break;
          case 'Needs Care':
            iconData = Icons.warning; // Ícone para "Needs Care"
            iconColor = Colors.blue; // Cor para "Needs Care"
            break;
          case 'Thriving':
            iconData = Icons.spa; // Ícone para "Thriving"
            iconColor = Colors.pink; // Cor para "Thriving"
            break;
          default:
            iconData = Icons.error; // Ícone padrão
            iconColor = Colors.black; // Cor padrão
        }
        return DropdownMenuItem<String>(
          value: value,
          child: Row(
            children: [
              Icon(
                iconData,
                color: iconColor, // Cor do ícone
              ),
              SizedBox(width: 8), // Espaçamento entre o ícone e o texto
              Text(value),
            ],
          ),
        );
      }).toList(),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plant.commonName),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(widget.plant.defaultImage['original_url'] ?? ''),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Plant description:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(height: 10),
                  Text('Common Name: ${widget.plant.commonName}'),
                  Text('Scientific Name: ${widget.plant.scientificName.join(', ')}'),
                  Text('Cycle: ${widget.plant.cycle}'),
                  Text(''),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Properties:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.right,),
                      Text('                 Status:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.left,),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: dropDown(context),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(wateringIcons[widget.plant.watering], color: Colors.blue),
                      SizedBox(width: 10),
                      Text('Watering: ${widget.plant.watering}'),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(sunlightIcons[widget.plant.sunlight[0]], color: Colors.yellow),
                      SizedBox(width: 10),
                      Text('Sunlight: ${widget.plant.sunlight.join(', ')}'),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 10),
                      Text('   '),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _selectWateringTime(context),
                        icon: Icon(Icons.access_time),
                        label: Text('Set Timer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 46, 169, 120),
                          foregroundColor: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text('Watering time:  ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.right,),
                      Text(' '),
                      _wateringTime != null ? Text('${_wateringTime!.format(context)}') : Text(''), // Adicionei uma verificação aqui
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

