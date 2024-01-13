import 'package:flutter/material.dart';
import 'package:kisan/components/Auth.dart';
import 'package:kisan/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GetLanguagePage extends StatefulWidget {
  const GetLanguagePage({Key? key}) : super(key: key);

  @override
  _GetLanguagePageState createState() => _GetLanguagePageState();
}

class _GetLanguagePageState extends State<GetLanguagePage> {
  String selectedLanguage = '';
  final _user = supabase.auth.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Language'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select your preferred language:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                buildLanguageRadio('English', 'english'),
                buildLanguageRadio('Hindi', 'hindi'),
                buildLanguageRadio('Marathi', 'marathi'),
                buildLanguageRadio('Telugu', 'telugu'),
                buildLanguageRadio('Tamil', 'tamil'),
                // Add more languages as needed
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Handle language selection logic here
                if (selectedLanguage.isNotEmpty) {
                  // Perform actions based on the selected language
                  _insertUserRecord();
                  print('Selected Language: $selectedLanguage');
                } else {
                  // Handle case when no language is selected
                  print('Please select a language');
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLanguageRadio(String label, String value) {
    return RadioListTile(
      title: Text(label),
      value: value,
      groupValue: selectedLanguage,
      onChanged: (String? value) {
        setState(() {
          selectedLanguage = value ?? '';
        });
      },
    );
  }

  Future<void> _insertUserRecord() async {
    final response = await supabase.from('users').upsert([
      {
        'name': _user?.userMetadata?['full_name'],
        'email': _user!.email ?? '',
        'phone': null,
        'profile': _user?.userMetadata?['avatar_url'],
        'location': null, // Set other fields as per your schema
        'language': selectedLanguage,
      },
    ]);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthPage()),
    );
  }
}
