import 'package:flutter/material.dart';
import 'package:kisan/components/Get_Language.dart';
import 'package:kisan/components/Navigation.dart';
import 'package:kisan/components/Signin.dart';
import 'package:kisan/main.dart';
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
            // User is signed in, check if the user record exists in the 'users' table
            return FutureBuilder(
              // Check if a user record exists in the 'users' table
              future: checkUserRecord(snapshot.data!.email as String),
              builder: (context, AsyncSnapshot<bool> userRecordSnapshot) {
                if (userRecordSnapshot.connectionState ==
                    ConnectionState.done) {
                  if (userRecordSnapshot.data == true) {
                    // User record exists, navigate to HomePage
                    return Navigation();
                  } else {
                    // User record does not exist, navigate to GetData page
                    return GetLanguagePage();
                  }
                } else {
                  // Still loading user record status
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              },
            );
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

  Future<bool> checkUserRecord(String email) async {
    final response =
        await supabase.from('users').select().eq('email', email).single();

    // If the user record exists, return true; otherwise, return false
    return response.isNotEmpty;
  }
}
