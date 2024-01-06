import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kisan/components/Auth.dart';
import 'package:kisan/components/Signin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  GoogleSignIn googleSignIn = GoogleSignIn();
  await Supabase.initialize(
    url: '',
    anonKey: '',
  );

  runApp(MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: AuthPage());
  }
}
