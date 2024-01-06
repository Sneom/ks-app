import 'package:flutter/material.dart';
import 'package:kisan/components/Navigation.dart';
import 'package:kisan/main.dart';
import 'package:kisan/components/Signin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      // Check if a user is already authenticated
      future: Future.value(supabase.auth.currentUser),
      builder: (context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data != null) {
            // User is signed in, navigate to HomePage
            return Navigation();
          } else {
            // User is not signed in, navigate to SignInPage
            return SignInPage();
          }
        } else {
          // Still loading authentication status
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
