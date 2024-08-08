import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'main.dart';

class ProfilePage extends StatefulWidget {
  final int userId;

  ProfilePage(this.userId);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  Map<String, dynamic>? userData;
  String? password;
  bool showPassword = false;
  bool loading = true;

  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmNewPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    Map<String, dynamic>? data = await dbHelper.getUserById(widget.userId);
    if (data != null) {
      setState(() {
        userData = data;
        password = userData!['password'];
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  void changePassword() async {
    String currentPassword = currentPasswordController.text;
    String newPassword = newPasswordController.text;
    String confirmNewPassword = confirmNewPasswordController.text;

    if (currentPassword == password && newPassword != currentPassword) {
      if (newPassword == confirmNewPassword) {
        // Update password in database
        int result = await dbHelper.updatePassword(widget.userId, newPassword);
        if (result == 1) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Password updated successfully'),
            duration: Duration(seconds: 2),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to update password'),
            duration: Duration(seconds: 2),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('New password and confirm password do not match'),
          duration: Duration(seconds: 2),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Current password is incorrect or new password is the same as current password'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  void deleteUser() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete User'),
          content: Text('Are you sure you want to delete this user?'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                int result = await dbHelper.deleteRegister(widget.userId);
                if (result == 1) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('User deleted successfully'),
                    duration: Duration(seconds: 2),
                  ));
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );// Go back to previous screen
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Failed to delete user'),
                    duration: Duration(seconds: 2),
                  ));
                }
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text('Profile Page', style: TextStyle(color: Colors.blue)),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : userData != null
          ? SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'User Profile',
              style: TextStyle(fontSize: 24, color: Colors.blue),
            ),
            SizedBox(height: 20),
            Text(
              'Username: ${userData!['username']}',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            SizedBox(height: 10),
            Text(
              'Religion: ${userData!['religion'] != null ? userData!['religion'] : 'Not specified'}',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            SizedBox(height: 10),
            Text(
              'Lifestyle: ${userData!['lifestyle'] != null ? userData!['lifestyle'] : 'Not specified'}',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            SizedBox(height: 10),
            Text(
              'Allergy: ${userData!['allergy'] != null ? userData!['allergy'] : 'Not specified'}',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Password: ',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                SizedBox(width: 10),
                Text(
                  // Sadece karakter uzunluğunu göster
                  showPassword ? password! : '${'*' * (password?.length ?? 0)}',
                  style: TextStyle(fontSize: 18, color: Colors.black45),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      // Şifreyi göster veya gizle
                      showPassword = !showPassword;
                    });
                  },
                  icon: Icon(Icons.visibility, color: Colors.black38),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Change Password', style: TextStyle(color: Colors.blue)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: currentPasswordController,
                          decoration: InputDecoration(labelText: 'Current Password', labelStyle: TextStyle(color: Colors.blue)),
                          obscureText: true,
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: newPasswordController,
                          decoration: InputDecoration(labelText: 'New Password', labelStyle: TextStyle(color: Colors.blue)),
                          obscureText: true,
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: confirmNewPasswordController,
                          decoration: InputDecoration(labelText: 'Confirm New Password', labelStyle: TextStyle(color: Colors.blue)),
                          obscureText: true,
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Cancel', style: TextStyle(color: Colors.blue)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          changePassword();
                          Navigator.of(context).pop();
                        },
                        child: Text('Confirm', style: TextStyle(color: Colors.blue)),
                      ),
                    ],
                  ),
                );
              },
              child: Text('Change Password', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: deleteUser,
              child: Text('Delete User', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Back to Home', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
          ],
        ),
      )
          : Center(child: Text('User not found', style: TextStyle(color: Colors.red))),
    );
  }
}