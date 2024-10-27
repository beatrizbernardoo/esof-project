import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

Future<String?> getFirebaseAccessToken() async {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  try {
    UserCredential userCredential = await _auth.signInAnonymously();

    // Obtenha o token de acesso do usuário autenticado
    String? accessToken = await userCredential.user?.getIdToken();
    return accessToken;
  } catch (e) {
    print('Erro ao obter o token de acesso do Firebase: $e');
    return null;
  }
}

/*
class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<String?> getDeviceToken() async {
    await _firebaseMessaging.requestPermission(alert: true, badge: true, sound: true);
    String? token = await _firebaseMessaging.getToken();
    return token;
  }
}
*/



Future<void> sendNotification() async {
  // FCMService fcmService = FCMService();
  //String? deviceToken = await fcmService.getDeviceToken();

  //String? accessToken = await getFirebaseAccessToken();
  final url = Uri.parse('https://fcm.googleapis.com/v1/projects/seed-you-later/messages:send');

  //String? fCMToken = await FirebaseMessaging.instance.getToken();
  String? accessToken = await getFirebaseAccessToken();


  final headers = <String, String>{
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };


  final data = <String, dynamic>{
    'message': {
      'token': 'DEVICE_FCM_TOKEN',
      'data': {
        'title': 'Título da Notificação',
        'body': 'Corpo da Notificação'
      },
      'android': {
        'priority': 'high'
      },
      'time_to_live': '2024-05-01T09:00:00Z'
    }
  };

  final response = await http.post(url, headers: headers, body: json.encode(data));
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  print("DIANA 5");
}
