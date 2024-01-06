import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GetBlogss extends StatelessWidget {
  final String title;

  const GetBlogss({Key? key, required this.title}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Docs Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DisplayCardsPage(jsonData),
        ),
      );
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
        title: Text('Google Docs Content'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [],
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, String>> convertTextToJson(String text) {
    // Replace this logic with your own parsing logic
    // This is a simple example, you might need to handle line breaks, etc.
    List<String> lines = text.split('\n');
    List<Map<String, String>> jsonData = [];
    Map<String, String> currentEntry = {};

    for (String line in lines) {
      line = line.trim();
      if (line.isNotEmpty) {
        if (line.startsWith('"title"')) {
          currentEntry = {
            'title': line.split(':')[1].trim().replaceAll('"', '')
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

class DisplayCardsPage extends StatelessWidget {
  final List<Map<String, String>> jsonData;

  DisplayCardsPage(this.jsonData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Display Cards'),
      ),
      body: ListView.builder(
        itemCount: jsonData.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(jsonData[index]['title'] ?? ''),
              subtitle: Text(jsonData[index]['description'] ?? ''),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsPage(
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
}

class DetailsPage extends StatelessWidget {
  final String title;
  final String description;
  final String link;

  DetailsPage(
      {required this.title, required this.description, required this.link});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: $title',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Description: $description',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Link: $link',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
