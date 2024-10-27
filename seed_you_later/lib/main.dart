import 'dart:async';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'plant.dart';
import 'plant_service.dart';
import 'weather_service.dart';
import 'weather_card.dart';
import 'package:flutter/services.dart';
import 'user_page.dart';
import 'userPlantDetailScreen.dart';
import 'plantListScreen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'notification.dart';


void main() {
  Firebase.initializeApp();
  runApp(MyApp());
}

/*
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print ('Title: ${message.notification?.title}');
}

Future<void> handleForegroundMessage(BuildContext context, RemoteMessage message) async {
  print('Received message while app is in foreground: ${message.notification?.title}');

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Nova Notificação: ${message.notification?.title ?? "Sem Título"}'),
      duration: Duration(seconds: 3),
    ),
  );
}



class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print('Token: $fCMToken');
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}
*/


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seed You Later',
      theme: ThemeData(
        primaryColor: Colors.green[900],
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(color: Colors.white),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}


class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Plant>> futurePlants;
  late Future<List<Plant>> futureUserPlants;
  bool showWeatherCard = false;
  bool orderByAlphabetical = false;
  Map<String, dynamic>? weatherData;
  String searchQuery = '';
  String? currentUserId;
  List<String> userPlants = [];
  List<String> artificialUserPlants = ["hogyoku japanese maple"];
  String selectedCity = '';
  int _selectedIndex = 0;
  TimeOfDay ? _wateringTime;

  void _removePlant(String plantId) async {
  try {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserId)
        .collection("plants")
        .doc(plantId)
        .delete();
    setState(() {
      futureUserPlants = getCurrentUserPlants();
    });
  } catch (error) {
    print("Error removing plant: $error");
  }
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

  late Timer _timer;
  @override
  void initState() {
    super.initState();
    futurePlants = fetchPlants(2);
    getCurrentUser();
    futureUserPlants = getCurrentUserPlants();
    _wateringTime = TimeOfDay(hour: 8, minute: 30);

    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      print("DIANA CHECK");
      checkNotification(context);
    });
    /*
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message while app is in foreground: ${message.notification?.body}');
      handleForegroundMessage(context, message);
    });

    sendNotification();
    */

  }
  Future<void> sendNotification(BuildContext context, String plantName) async {
    print('Received message while app is in foreground');

    Flushbar(
      margin: EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      backgroundColor: Color.fromARGB(255,180,207,236), //Colors.blueAccent,
      icon: Icon(
        Icons.water_drop,
        size: 35.0,
        color: Colors.blue,
      ),
      leftBarIndicatorColor: Colors.blue[300],
      title: 'Reminder',
      message: "Don't forget to water your $plantName!",
      titleColor: Colors.black54,
      messageColor: Colors.black54,
      titleSize: 20.0,
      messageSize: 18.0,
      duration: Duration(seconds: 10),
      flushbarPosition: FlushbarPosition.TOP,
    )..show(context);
  }

  Future<void> checkNotification(BuildContext context) async {
    List<Plant> plants = await getCurrentUserPlants();
    for(Plant plant in plants) {
      DateTime now = DateTime.now();
      String? currentTime = '${now.hour}:${now.minute}';
      String? waterTime = await getCurrentPlantWaterTime(plant.id, currentUserId);
      print("AAAAA: $currentTime - $waterTime");
      if (currentTime == waterTime) {
        sendNotification(context, plant.commonName);
      }
    }

  }

  Future<List<Plant>> getCurrentUserPlants() async {
    try {
      await Firebase.initializeApp(); // Initialize Firebase
      //await FirebaseApi().initNotifications();
      List<Plant> userPlants = [];

      QuerySnapshot userPlantsSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .collection("plants")
          .get();

      for (QueryDocumentSnapshot plantDoc in userPlantsSnapshot.docs) {
        DocumentSnapshot plantSnapshot = await FirebaseFirestore.instance
            .collection("users")
            .doc(currentUserId)
            .collection("plants")
            .doc(plantDoc.id)
            .get();

        if (plantSnapshot.exists) {
          String commonName = plantSnapshot.get('commonName');
          List<dynamic> scientificName = plantSnapshot.get('scientificName');
          String cycle = plantSnapshot.get('cycle');
          String watering = plantSnapshot.get('watering');
          List<dynamic> sunlight = plantSnapshot.get('sunlight');
          List<String> ola = [];
          Map<String, dynamic> dImage = plantSnapshot.get('defaultImage');
          /*
          String wateringTime2 = plantSnapshot.get('wateringTime');
          List<String> timeParts = wateringTime2.split(':');
          int hour = int.parse(timeParts[0]);
          int minute = int.parse(timeParts[1]);
          TimeOfDay wateringTime = TimeOfDay(hour: hour, minute: minute);
           */
          //String floweringSeason = plantSnapshot.get('floweringSeason');
          //List<dynamic> attracts = plantSnapshot.get('attracts');
          //String wateringPeriod = plantSnapshot.get('wateringPeriod');
          //Map<String, dynamic> depthWaterRequirement = plantSnapshot.get('depthWaterRequirement');
          userPlants.add(Plant(
            id: plantDoc.id,
            //id: 0,
            commonName: commonName,
            scientificName: scientificName.cast<String>(),
            cycle: cycle,
            watering: watering,
            sunlight: sunlight.cast<String>(),
            defaultImage: dImage,
              //wateringTime: wateringTime,
            //floweringSeason: floweringSeason,
            //attracts: attracts.cast<String>(),
            //wateringPeriod: wateringPeriod,
            //depthWaterRequirement : depthWaterRequirement,
          ));
        } else {
          print('Plant document ${plantDoc.id} does not exist');
        }
      }

      return userPlants;
    } catch (error) {
      print("Error fetching plants: $error");
      throw Exception("Error fetching plants: $error");
    }
  }

  Future<void> getCurrentUser() async {
    try {
      final String? id =
          await MethodChannel('com.example.app/login').invokeMethod('getCurrentUserId');
      setState(() {
        currentUserId = id;
      });
      print("CURRENT USER ID");
      print(currentUserId);
    } on PlatformException catch (e) {
      print("Failed to get current user: '${e.message}'.");
    }
  }

    Future<void> fetchWeather(String city) async {
    try {
      final data = await WeatherService.fetchWeather(city);
      setState(() {
        showWeatherCard = true;
        weatherData = data;
      });
    } catch (e) {
      print('Error fetching weather: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seed You Later', 
        style: TextStyle(
        fontFamily: 'Open Sans', // Defina o nome da fonte desejada
        fontSize: 20, // Tamanho do texto
        fontWeight: FontWeight.bold, // Peso da fonte
        ),),
        backgroundColor: const  Color.fromARGB(255, 90, 171, 93),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              // Open UserPage to select city
              final selectedCity = await Navigator.push<String>(
                context,
                MaterialPageRoute(builder: (context) => UserPage(onCityChanged: fetchWeather)),
              );

              if (selectedCity != null) {
                setState(() {
                  this.selectedCity = selectedCity;
                });
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [

          /*ElevatedButton(
              onPressed: () {
                setState(() {
                  orderByAlphabetical = !orderByAlphabetical;
                });
              },
              child: Text(orderByAlphabetical ? 'Sort by Ascending Order' : 'Sort by Alphabetical Order'),
          ),*/
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await fetchWeather(selectedCity);
                if (showWeatherCard && weatherData != null) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Weather'),
                        content: WeatherCard.fromJson(json.encode(weatherData)),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Weather Data Unavailable'),
                        content: Text('Weather data is not available at the moment.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              icon: weatherData != null && weatherData!['current'] != null && weatherData!['current']['condition'] != null
                  ? Image.network(
                      'https:' + (weatherData!['current']['condition']['icon'] as String),
                      width: 32,
                      height: 32,
                    )
                  : Icon(Icons.error), // Ou algum ícone padrão para indicar erro
              label: weatherData != null && weatherData!['current'] != null
                  ? Text('Meteorology   ${weatherData!['current']['temp_c']}°C')
                  : Text('Weather Unavailable'), 
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 64, 162, 173),
                foregroundColor: Colors.white,
              ),
            ),
          ),

            Expanded(
              child: _buildSelectedScreen(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_nature_rounded),
            label: 'My Garden',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline_rounded),
            label: 'Add Plant',
          ),
        ],
        selectedItemColor: const Color.fromARGB(255, 90, 171, 93),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }


  Widget _buildSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
futureUserPlants = getCurrentUserPlants();
        return _buildMyGardenScreen(futureUserPlants);
      case 1:
        return PlantListScreen();
      default:
        return Container();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

 Widget _buildMyGardenScreen(Future<List<Plant>> futureUserPlants) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'My Garden',
        style: TextStyle(color: Color.fromARGB(255, 60, 165, 67), fontSize: 24.0, 
          fontWeight: FontWeight.bold, )
        , 
      ),
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.green[900]),
    ),
    body: Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 202, 198, 198),
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search for plants...',
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              orderByAlphabetical = !orderByAlphabetical;
            });
          },
          style: ElevatedButton.styleFrom(
            side: BorderSide(width: 1, color: Colors.green),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sort,
                color: Colors.green,
              ),
              SizedBox(width: 8),
              Text(
                orderByAlphabetical ? 'Sort by Ascending Order' : 'Sort by Alphabetical Order',
                style: TextStyle(
                  color: Colors.green, // Cor do texto
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Plant>>(
            future: futureUserPlants,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No plants found.');
              } else {
                List<Plant> plants = snapshot.data!;
                if (orderByAlphabetical) {
                  plants.sort((a, b) => a.commonName.compareTo(b.commonName));
                }
                final List<Plant> filteredPlants = plants
                    .where((plant) => plant.commonName.toLowerCase().contains(searchQuery.toLowerCase()))
                    .toList();

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemCount: filteredPlants.length,
                  itemBuilder: (context, index) {
                    final plant = filteredPlants[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserPlantDetailScreen(
                              plant: plant,
                              currentUserId: currentUserId,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                plant.defaultImage['original_url'] ?? '',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.sunny);
                                },
                              ),
                            ),
                            Positioned(
                              left: 8,
                              top: 8,
                              child: GestureDetector(
                                onTap: () {
                                  _removePlant(plant.id);
                                },
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red,
                                  ),
                                  child: Icon(Icons.delete, color: Colors.white),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  plant.commonName.split(" ").take(2).join(" "),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    ),
  );
}}

