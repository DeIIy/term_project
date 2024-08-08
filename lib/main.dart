import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'login_screen.dart';

void main() {
 runApp(MyApp());
}

class MyApp extends StatelessWidget {
 @override
 Widget build(BuildContext context) {
  return MaterialApp(
   debugShowCheckedModeBanner: false,
   title: 'Recipe AI',
   theme: ThemeData(
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
   ),
   home: RegisterScreen(),
  );
 }
}

class RegisterScreen extends StatefulWidget {
 @override
 _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
 Map<String, dynamic> userData = {
  'username': '',
  'password': '',
  'religion': '',
  'lifestyle': '',
  'allergy': '',
 };

 final dbHelper = DatabaseHelper();

 void _register() async {
  if (userData.containsValue('')) {
   String errorMessage = '';
   userData.forEach((key, value) {
    if (value.isEmpty) errorMessage += '${key.capitalize()}, ';
   });
   errorMessage = errorMessage.substring(0, errorMessage.length - 2);
   errorMessage += ' fields are empty.';

   showDialog(
    context: context,
    builder: (_) => AlertDialog(
     title: Text('Error', style: TextStyle(color: Colors.blue)),
     content: Text(errorMessage, style: TextStyle(color: Colors.blue)),
     actions: <Widget>[
      TextButton(
       onPressed: () {
        Navigator.pop(context);
       },
       child: Text('Close', style: TextStyle(color: Colors.blue)),
      ),
     ],
    ),
   );
  } else {
   bool usernameAvailable = await dbHelper.isUsernameAvailable(userData['username']);
   if (!usernameAvailable) {
    showDialog(
     context: context,
     builder: (_) => AlertDialog(
      title: Text('Error', style: TextStyle(color: Colors.blue)),
      content: Text('This username is already taken by another user.', style: TextStyle(color: Colors.blue)),
      actions: <Widget>[
       TextButton(
        onPressed: () {
         Navigator.pop(context);
        },
        child: Text('Close', style: TextStyle(color: Colors.blue)),
       ),
      ],
     ),
    );
   } else {
    String userDetails = '''
            Username: ${userData['username']}
            Password: ${userData['password']}
            Religion: ${userData['religion']}
            Lifestyle: ${userData['lifestyle']}
            Allergy: ${userData['allergy']}
            ''';
    showDialog(
     context: context,
     builder: (_) => AlertDialog(
      title: Text('Registered User Details', style: TextStyle(color: Colors.blue)),
      content: Text(userDetails, style: TextStyle(color: Colors.blue)),
      actions: <Widget>[
       TextButton(
        onPressed: () {
         Navigator.pop(context);
        },
        child: Text('Close', style: TextStyle(color: Colors.blue)),
       ),
      ],
     ),
    );

    int result = await dbHelper.insertRegister(userData);
    print('User inserted: $result');
   }
  }
 }

 @override
 Widget build(BuildContext context) {
  return Scaffold(
   appBar: AppBar(),
   body: SingleChildScrollView(
    child: Padding(
     padding: const EdgeInsets.all(16.0),
     child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
       TextFormField(
        decoration: InputDecoration(labelText: 'Username', labelStyle: TextStyle(color: Colors.blue)),
        onChanged: (value) {
         setState(() {
          userData['username'] = value;
         });
        },
       ),
       SizedBox(height: 10),
       TextFormField(
        decoration: InputDecoration(labelText: 'Password', labelStyle: TextStyle(color: Colors.blue)),
        obscureText: true,
        onChanged: (value) {
         setState(() {
          userData['password'] = value;
         });
        },
       ),
       SizedBox(height: 10),
       _buildCheckboxRow('Religion', ['Islam', 'Judaism', 'Hinduism', 'Other'], 'religion'),
       _buildCheckboxRow('Lifestyle', ['Vegan', 'Vegetarian', 'Other'], 'lifestyle'),
       _buildCheckboxRow('Allergy', ['Peanut', 'Egg', 'Hazelnut', 'No allergy'], 'allergy'),
       SizedBox(height: 20),
       ElevatedButton(
        onPressed: _register,
        child: Text('Register', style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
       ),
       SizedBox(height: 10),
       ElevatedButton(
        onPressed: () {
         Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
         );
        },
        child: Text('Login', style: TextStyle(color: Colors.white, fontSize: 16)),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlueAccent),
       ),
      ],
     ),
    ),
   ),
  );
 }

 Widget _buildCheckboxRow(String title, List<String> options, String key) {
  return Row(
   children: <Widget>[
    Expanded(
     child: Checkbox(
      value: userData[key].isNotEmpty,
      onChanged: (value) {
       if (value!) {
        _showOptionsDialog(title, options, key);
       } else {
        setState(() {
         userData[key] = '';
        });
       }
      },
     ),
    ),
    Expanded(
     child: Text(title, style: TextStyle(color: Colors.blue)),
    ),
   ],
  );
 }

 void _showOptionsDialog(String title, List<String> options, String key) {
  showDialog(
   context: context,
   builder: (_) => AlertDialog(
    title: Text('Select $title', style: TextStyle(color: Colors.blue)),
    content: Column(
     mainAxisSize: MainAxisSize.min,
     children: options.map((option) {
      return ListTile(
       title: Text(option, style: TextStyle(color: Colors.blue)),
       onTap: () {
        setState(() {
         userData[key] = option;
        });
        Navigator.pop(context);
       },
      );
     }).toList(),
    ),
    actions: <Widget>[
     TextButton(
      onPressed: () {
       Navigator.pop(context);
      },
      child: Text('Close', style: TextStyle(color: Colors.blue)),
     ),
    ],
   ),
  );
 }
}

extension StringExtension on String {
 String capitalize() {
  return '${this[0].toUpperCase()}${this.substring(1)}';
 }
}