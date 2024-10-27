import 'package:flutter/material.dart';
import 'plant.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class PlantDetailScreen extends StatefulWidget {
  final Plant plant;

  const PlantDetailScreen({Key? key, required this.plant}) : super(key: key);

  @override
  _PlantDetailScreenState createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  TimeOfDay? _wateringTime;

  @override
  void initState() {
    super.initState();
    _wateringTime = TimeOfDay(hour: 8, minute: 30);
    // Initialize watering time with a default value
  }

  Future<void> _selectWateringTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _wateringTime!,
    );
    if (pickedTime != null && pickedTime != _wateringTime) {
      setState(() {
        _wateringTime = pickedTime;
      });
      _addToGarden(context, pickedTime);

      // Convert DateTime to TZDateTime
      final now = tz.TZDateTime.now(tz.local);
      final scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      ).subtract(const Duration(minutes: 10)); // Notify 10 minutes before selected time
      // Schedule notification
      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      final InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'your channel id',
        'your channel name',
        'your channel description',
        importance: Importance.max,
        priority: Priority.high,
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Plant Watering Reminder',
        'Remember to water your plant!',
        scheduledTime,
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
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
    'Full sun, part shade': Icons.cloud,
    // Add more conditions here
  };

  void _addToGarden(BuildContext context, TimeOfDay wateringTime) {
    print("ADD TO GARDEN");
    // Add plant to garden logic here
    int hour = wateringTime.hour;
    int minute = wateringTime.minute;

    String hourString = hour.toString().padLeft(2, '0');
    String minuteString = minute.toString().padLeft(2, '0');
    String waterTimeString = '$hourString:$minuteString'; ///////////////////////////////////////////
    //String waterTimeString = "8:30";
    MethodChannel('com.example.app/login').invokeMethod(
      'addPlantToUserCollection',
      {
        'plantName': widget.plant.commonName.toLowerCase(),
        'plantScientificName': widget.plant.scientificName,
        'plantCycle': widget.plant.cycle.toLowerCase(),
        'plantWatering': widget.plant.watering,
        'plantSunlight': widget.plant.sunlight,
        'plantDefaultImage': widget.plant.defaultImage,
        'plantWateringTime': waterTimeString,
        //'floweringSeason': widget.plant.floweringSeason,
        //'attracts': widget.plant.attracts,
        //'wateringPeriod': widget.plant.wateringPeriod,
        //'depthWaterRequirement': widget.plant.depthWaterRequirement,
      },
    ).then((_) {
      // Show a snackbar with the message "Plant added!"
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Plant added!'),
        ),
      );
    });
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
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.5,
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
                  Text('Plant description:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.right,),
                  SizedBox(height: 8),
                  Text('Common Name: ${widget.plant.commonName}'),
                  Text('Scientific Name: ${widget.plant.scientificName.join(', ')}'),
                  Text('Cycle: ${widget.plant.cycle}'),
                  //Text('Atracts: ${widget.plant.attracts.join(', ')}'),
                  //Text('Flowering season: ${widget.plant.floweringSeason}'),
                  //Text('Watering period: ${widget.plant.wateringPeriod}'),
                  //Text('Water requirements: ${widget.plant.depthWaterRequirement}'),
                  Text(''),
                  Text('Properties:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.right,),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(wateringIcons[widget.plant.watering], color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Watering: ${widget.plant.watering}'),
                    ],
                  ),
                  Row(
                    children: [
                      // Check if the sunlight condition exists in the map
                      sunlightIcons.containsKey(widget.plant.sunlight[0])
                          ? Icon(
                              sunlightIcons[widget.plant.sunlight[0]],
                              color: Colors.yellow,
                            )
                          // If not found, display an icon representing partly cloudy weather
                          : Icon(
                          Icons.wb_sunny_outlined, color: Colors.yellow), // Sol
                          Icon(Icons.cloud_outlined, color: Colors.grey), // Nuvem,
                      SizedBox(width: 8),
                      Text('Sunlight: ${widget.plant.sunlight.join(', ')}'),
                    ],
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () =>_selectWateringTime(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.eco),
                          SizedBox(width: 8),
                          Text('Add to garden'),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 0, 0, 0),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
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






