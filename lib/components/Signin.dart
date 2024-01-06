import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kisan/components/Auth.dart';
import 'package:kisan/main.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SignInPage(),
    );
  }
}

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  String authStatus = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 6, 31, 44),
      body: Center(
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Kisan Sathi",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Siddhigiri Krishi Vigyan Kendra",
                  style: TextStyle(
                    color: Colors.lightGreen,
                  ),
                ),
                const SizedBox(height: 90),
                const Text(
                  "Log In To Continue",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _googleSignIn();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF1B4242),
                    onPrimary: Colors.white,
                    padding: EdgeInsets.all(20),
                  ),
                  icon: Image.asset('assets/google_logo.webp', height: 30),
                  label: Text('Login using Google',
                      style: TextStyle(fontSize: 18)),
                ),
                SizedBox(height: 15),
                Text(
                  authStatus,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _googleSignIn() async {
    try {
      const webClientId = '';
      const iosClientId = '';

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: iosClientId,
        serverClientId: webClientId,
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw 'Google Sign-In cancelled by user.';
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw 'Access Token or ID Token not found.';
      }

      // Use the correct provider name as per Supabase documentation
      final AuthResponse authResponse = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // Check if the sign-in was successful

      // Navigate to the home page (replace "HomePage" with your actual home page class)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AuthPage(),
        ),
      );

      // Handle sign-in failure
    } catch (error) {
      print('Google Sign-In Error: $error');
      // Handle the error appropriately (e.g., show a message to the user)
    }
  }
}
