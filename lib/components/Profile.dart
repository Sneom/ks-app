import 'package:flutter/material.dart';
import 'package:kisan/components/Auth.dart';
import 'package:kisan/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the user information from Supabase
    final user = supabase.auth.currentUser;

    // Get the Google profile picture URL
    final profilePictureUrl = user?.userMetadata?['avatar_url'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: ListView(
        children: [
          // User Details
          ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(profilePictureUrl),
            ),
            title: Text(user?.userMetadata?['full_name'] ?? 'Unknown'),
            subtitle: Text(user?.email ?? 'No Email'),
          ),
          Divider(),

          // Settings Option
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              // Implement settings logic here
            },
          ),
          Divider(),

          // Logout Option
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () async {
              await supabase.auth.signOut();

              // Navigate to the login or authentication page
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => AuthPage()));
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}
