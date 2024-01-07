import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kisan/components/Fetch_Blog.dart';
import 'package:kisan/components/Navigation.dart';

import '../main.dart';

class GetBlogss extends StatelessWidget {
  final String title;

  const GetBlogss({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmers App',
      theme: ThemeData(
        primarySwatch: Colors.green, // Adjust color based on agriculture theme
      ),
      home: GoogleDrive(title: title),
    );
  }
}

class GoogleDrive extends StatefulWidget {
  final String title;

  const GoogleDrive({Key? key, required this.title}) : super(key: key);

  @override
  _GoogleDriveState createState() => _GoogleDriveState(title: title);
}

class _GoogleDriveState extends State<GoogleDrive> {
  final String title;

  _GoogleDriveState({Key? key, required this.title}) : super();

  String docText = '';
  List<Map<String, String>> jsonData = [];

  @override
  void initState() {
    super.initState();
    fetchGoogleDocsText();
  }

  Future<void> fetchGoogleDocsText() async {
    String link = "";
    if (title.toLowerCase() == "organic farming") {
      link =
          "https://docs.google.com/document/d/1TAopV6MvmqEmEttnW0gB32IYtMcDb4vW_yKV9i1sIvg/export?format=txt";
    }

    final response = await http.get(Uri.parse(link));

    if (response.statusCode == 200) {
      setState(() {
        docText = response.body;
        jsonData = convertTextToJson(docText);
      });
    } else {
      setState(() {
        docText = 'Failed to fetch content';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Color(0xFFF2EE9D),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Navigation()),
            );
          },
        ),
        backgroundColor: Color(0xFF557A46),
        title: Text(
          '$title',
          style: const TextStyle(
              color: Color(0xFFF2EE9D), fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Color(0xFF7A9D54),
      body: jsonData.isEmpty
          ? Center(
              child: RefreshProgressIndicator(
                backgroundColor: Color(0xFF557A46),
                color: Color(0xFFF2EE9D),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: jsonData.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 5, // Add elevation for a card-like effect
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      jsonData[index]['title'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      jsonData[index]['description'] ?? '',
                      style: TextStyle(fontSize: 16),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FetchDriveData(
                            title: jsonData[index]['title'] ?? '',
                            description: jsonData[index]['description'] ?? '',
                            link: jsonData[index]['link'] ?? '',
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  List<Map<String, String>> convertTextToJson(String text) {
    List<String> lines = text.split('\n');
    List<Map<String, String>> jsonData = [];
    Map<String, String> currentEntry = {};

    for (String line in lines) {
      line = line.trim();
      if (line.isNotEmpty) {
        if (line.startsWith('"title"')) {
          currentEntry = {
            'title': line.split(':')[1].trim().replaceAll('"', ''),
          };
        } else if (line.startsWith('"description"')) {
          currentEntry['description'] =
              line.split(':')[1].trim().replaceAll('"', '');
        } else if (line.startsWith('"link"')) {
          currentEntry['link'] = line.split(': ')[1].trim().replaceAll('"', '');
          jsonData.add(currentEntry);
        }
      }
    }

    return jsonData;
  }
}
