import 'package:flutter/material.dart';
import 'package:kisan/components/Auth.dart';
import 'package:kisan/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    final profilePictureUrl = user?.userMetadata?['avatar_url'] ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF557A46), // Updated app bar color
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Updated text color
          ),
        ),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Color(0xFFECF0F1), // Updated background color
      body: ListView(
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(profilePictureUrl),
            ),
            title: Text(
              user?.userMetadata?['full_name'] ?? 'Unknown',
              style: TextStyle(
                color: Color(0xFF2C3E50), // Updated text color
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Text(
              user?.email ?? 'No Email',
              style: TextStyle(
                color: Color(0xFF7F8C8D), // Updated text color
                fontSize: 14,
              ),
            ),
          ),
          Divider(color: Color(0xFFBDC3C7)), // Updated divider color

          ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            leading: Icon(Icons.settings, color: Color(0xFF34495E)),
            title: Text(
              'Settings',
              style: TextStyle(
                  color: Color(0xFF2C3E50),
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            onTap: () {
              // Implement settings logic here
            },
          ),
          Divider(color: Color(0xFFBDC3C7)),

          ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            leading: Icon(Icons.logout, color: Color(0xFF34495E)),
            title: Text(
              'Logout',
              style: TextStyle(
                  color: Color(0xFF2C3E50),
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              await supabase.auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AuthPage()),
              );
            },
          ),
          Divider(color: Color(0xFFBDC3C7)),
        ],
      ),
    );
  }
}
