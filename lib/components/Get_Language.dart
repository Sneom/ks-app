import 'package:flutter/material.dart';
import 'package:kisan/components/Auth.dart';
import 'package:kisan/components/Language/Language_Texts.dart';
import 'package:kisan/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetLanguagePage extends StatefulWidget {
  const GetLanguagePage({Key? key}) : super(key: key);

  @override
  _GetLanguagePageState createState() => _GetLanguagePageState();
}

class _GetLanguagePageState extends State<GetLanguagePage> {
  String selectedLanguage = 'english';
  final _user = supabase.auth.currentUser;

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  Future<void> _loadSelectedLanguage() async {
    final preferences = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = preferences.getString('selectedLanguage') ?? 'english';
      ;
    });
  }

  Future<void> _saveSelectedLanguage(String language) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('selectedLanguage', language);
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> titles =
        LanguageTexts.headerTitle[selectedLanguage] ?? {};
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 253, 209),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor:
            Color(0xFF557A46), // Set the green color for the app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${titles['selectlang']}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF557A46), // Set the green color for the text
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                buildLanguageCard('English', 'english', Icons.language),
                buildLanguageCard('हिंदी', 'hindi', Icons.language),
                buildLanguageCard('मराठी', 'marathi', Icons.language),
                buildLanguageCard('తెలుగు', 'telugu', Icons.language),
                buildLanguageCard('తమిళం', 'tamil', Icons.language),
                // Add more languages as needed
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (selectedLanguage.isNotEmpty) {
                  _insertOrUpdateUserRecord();
                  print('Selected Language: $selectedLanguage');
                } else {
                  print('Please select a language');
                }
              },
              child: Text(
                '${titles['submit']}',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                primary:
                    Color(0xFF557A46), // Set the green color for the button
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLanguageCard(String label, String value, IconData iconData) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
            8.0), // Set your desired border radius for the Card
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(8.0), // Same border radius as the Card
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
                8.0), // Set your desired border radius for the ListTile
            color: selectedLanguage == value ? Color(0xFFF2EE9D) : null,
          ),
          child: ListTile(
            title: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            leading: Icon(iconData, color: Color(0xFF557A46)),
            onTap: () {
              setState(() {
                selectedLanguage = value;
              });
            },
          ),
        ),
      ),
    );
  }

  Future<void> _insertOrUpdateUserRecord() async {
    final existingUser = await supabase
        .from('users')
        .select('email')
        .eq('email', "${_user?.email}");

    if (existingUser.isNotEmpty) {
      await supabase.from('users').update({'language': selectedLanguage}).eq(
        'email',
        _user?.email ?? '',
      );
    } else {
      await supabase.from('users').upsert([
        {
          'name': _user?.userMetadata?['full_name'],
          'email': _user!.email ?? '',
          'phone': null,
          'profile': _user?.userMetadata?['avatar_url'],
          'location': null,
          'language': selectedLanguage,
        },
      ]);
    }

    await _saveSelectedLanguage(selectedLanguage);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthPage()),
    );
  }
}
