import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kisan/components/Fetch_Blog.dart';
import 'package:kisan/components/Navigation.dart';

class GetBlogs extends StatelessWidget {
  final String title;

  const GetBlogs({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GoogleDrive(title: title),
    );
  }
}

class GoogleDrive extends StatefulWidget {
  final String title;

  const GoogleDrive({Key? key, required this.title}) : super(key: key);

  @override
  _GoogleDriveState createState() => _GoogleDriveState();
}

class _GoogleDriveState extends State<GoogleDrive> {
  late Future<List<Map<String, String>>> _fetchGoogleDocsText;

  @override
  void initState() {
    super.initState();
    _fetchGoogleDocsText = fetchGoogleDocsText();
  }

  Future<List<Map<String, String>>> fetchGoogleDocsText() async {
    String link = '';
    if (widget.title.toLowerCase() == 'organic farming') {
      link =
          'https://docs.google.com/document/d/1TAopV6MvmqEmEttnW0gB32IYtMcDb4vW_yKV9i1sIvg/export?format=txt';
    }

    final response = await http.get(Uri.parse(link));

    if (response.statusCode == 200) {
      return convertTextToJson(response.body);
    } else {
      throw Exception('Failed to fetch content');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7A9D54),
      body: FutureBuilder(
        future: _fetchGoogleDocsText,
        builder: (context, AsyncSnapshot<List<Map<String, String>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: RefreshProgressIndicator(
                backgroundColor: Color(0xFF557A46),
                color: Color(0xFFF2EE9D),
              ),
            );
          } else if (snapshot.hasError) {
            return Container(
              child: Stack(
                children: [
                  Positioned(
                    top: 40,
                    left: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF557A46).withOpacity(0.5),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: const Color(0xFFF2EE9D),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Navigation()),
                          );
                        },
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Could not get the requested data!!',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFFF2EE9D)),
                    ),
                  ),
                ],
              ),
            );
          } else {
            List<Map<String, String>> jsonData = snapshot.data!;
            return Stack(
              children: [
                PageView.builder(
                  itemCount: jsonData.length,
                  itemBuilder: (context, index) {
                    List<String> arr = [
                      'assets/organic-farming1.jpg',
                      'assets/organic-farming2.jpg',
                      'assets/organic-farming3.jpg',
                      'assets/organic-farming4.jpg',
                      'assets/organic-farming5.jpg'
                    ];
                    return buildCard(context, jsonData[index], arr[index]);
                  },
                ),
                Positioned(
                  top: 40,
                  left: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF557A46).withOpacity(0.5),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: const Color(0xFFF2EE9D),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Navigation()),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget buildCard(
      BuildContext context, Map<String, String> data, String bgimage) {
    return Stack(
      children: [
        Positioned(
          child: Image.asset(
            bgimage,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Container(
          color: Colors.black.withOpacity(0.5),
          width: double.infinity,
          height: double.infinity,
        ),
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['title'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                data['description'] ?? '',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FetchDriveData(
                            title: data['title'] ?? '',
                            description: data['description'] ?? '',
                            link: data['link'] ?? '',
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Read More',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: const Color(0xFF557A46),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
