import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'weather_service.dart'; // Import your weather service here
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';


class UserPage extends StatefulWidget {
  final Function(String) onCityChanged;

  const UserPage({Key? key, required this.onCityChanged}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  String selectedCity = 'London'; // Default city

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        actions: <Widget>[
        ]
          
      ),
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.add_location, color: Colors.white),
                backgroundColor: Colors.green,
              ),
              title: Text('Select City'),
              trailing: DropdownButton<String>(
                value: selectedCity,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCity = newValue!;
                    widget.onCityChanged(selectedCity); // Call the callback function
                  });
                },
                items: <String>['London', 'New York', 'Paris', 'Tokyo', 'Los Angeles', 'Beijing', 
                'Moscow', 'Berlin', 'Istanbul', 'Shanghai', 'Rio de Janeiro', 'Cairo', 'Delhi', 
                'Mexico City', 'Mumbai', 'Buenos Aires', 'Sydney', 'Rome', 'Seoul', 'Jakarta', 'Dhaka', 
                'Karachi', 'Sao Paulo', 'Manila', 'Istanbul', 'Lagos', 'Porto', 'Tehran', 'Bangkok',
                 'Jakarta', 'Kinshasa', 'Lima', 'Seoul', 'Bogotá', 'Johannesburg', 'Baghdad', 'Ho Chi Minh City', 
                 'Santiago', 'Kuala Lumpur', 'Madrid', 'Toronto', 'Miami', 'Hong Kong', 'Singapore', 'Dubai', 'Sydney',
                  'Chicago', 'Melbourne', 'Riyadh', 'Abu Dhabi', 'Oslo', 'Copenhagen', 'Stockholm', 'Amsterdam', 'Vienna', 
                  'Brussels', 'Munich', 'Zurich', 'Frankfurt', 'Geneva', 'Barcelona', 'Prague', 'Budapest', 'Warsaw', 'Lisbon',
                   'Athens', 'Edinburgh', 'Glasgow', 'Dublin', 'Manchester', 'Birmingham', 'Liverpool', 'Leeds', 'Bristol', 'New Delhi',
                    'Kolkata', 'Chennai', 'Pune', 'Hyderabad', 'Ahmedabad', 'Bangalore', 'Surat', 'Johannesburg', 'Cape Town', 'Durban',
                     'Pretoria', 'Port Elizabeth', 'Bloemfontein', 'Kimberley', 'Venice', 'Florence', 'Milan', 'Naples', 'Turin', 'Bologna',
                      'Genoa', 'Palermo', 'Florence', 'Helsinki', 'Reykjavik']

                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.person, color: Colors.white),
                backgroundColor: Colors.green,
              ),
              title: Text('Edit Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfilePage()),
                );
              },
            ),
            ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.logout, color: Colors.white),
                backgroundColor: Colors.green,
              ),
              title: Text('Logout'),
              onTap: () {
                MethodChannel('com.example.app/login').invokeMethod('logout');
                Navigator.pop(context);
              },
            ),
          ],
        ).toList(),
      ),
    );
  }
}



class EditProfilePage extends StatelessWidget {
 // final TextEditingController _nameController = TextEditingController();
  //final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentEmailController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        title: Text('Change password', style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Current Email'),
            TextField(
              controller: _currentEmailController,
              decoration: InputDecoration(
                labelText: 'Enter Current Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
           /* SizedBox(height: 10),
            Text('Change Email'),
            TextField(
             // controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Enter New Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
            ),*/
            SizedBox(height: 10),
            Text('Current Password'),
            TextField(
              controller: _currentPasswordController,
              /*decoration: InputDecoration(
                labelText: 'Enter New Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
              ),*/
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Enter Current Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
            SizedBox(height: 10),
            Text('New Password'),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Enter New Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () async {
               //   String newName = _nameController.text.trim();
              //    String newEmail = _emailController.text.trim();
                  String currentEmail = _currentEmailController.text.trim();
                  String currentPassword = _currentPasswordController.text.trim();
                  String newPassword = _newPasswordController.text.trim();
                  
                  try {
                    AuthCredential credential = EmailAuthProvider.credential(email: currentEmail, password: currentPassword);
                    await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(credential);
    
                    await FirebaseAuth.instance.currentUser!.updatePassword(newPassword);
    
                    _currentEmailController.clear();
                    _currentPasswordController.clear();
                    _newPasswordController.clear();
    
                    ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password updated successfully')),
                    );
                    } catch (error) {
 
                    print('Error updating password: $error');

                    ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating password: $error')),
                    );
                    }
              }, 

                child: Text('Apply changes', style: TextStyle(color: Colors.white)),
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 21, 181, 37)!)),
              ),
            ),
            SizedBox(height: 20),
            Text('Delete Account'),
            Text('The data from your account will be deleted.'),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Adicione a lógica para deletar a conta aqui
                },
                child: Text('Delete Account', style: TextStyle(color: Colors.red)),
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.pink[100]!),
                minimumSize: MaterialStateProperty.all<Size>(Size(double.infinity, 48)), ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

