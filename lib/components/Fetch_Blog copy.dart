import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;

class FetchDriveDatsa extends StatefulWidget {
  final String title;
  final String description;
  final String link;

  const FetchDriveDatsa(
      {Key? key,
      required this.title,
      required this.description,
      required this.link})
      : super(key: key);

  @override
  _GoogleDriveState createState() => _GoogleDriveState(
      key: key, title: title, description: description, link: link);
}

class _GoogleDriveState extends State<FetchDriveDatsa> {
  final String title;
  final String description;
  final String link;

  // Include the 'key' parameter and pass it to the superclass constructor
  _GoogleDriveState(
      {Key? key,
      required this.title,
      required this.description,
      required this.link})
      : super();

  String docHtml = '';

  @override
  void initState() {
    super.initState();
    fetchGoogleDocsHtml();
  }

  Future<void> fetchGoogleDocsHtml() async {
    final response = await http.get(Uri.parse(link));

    if (response.statusCode == 200) {
      setState(() {
        docHtml = response.body;
      });
    } else {
      setState(() {
        docHtml = 'Failed to fetch content';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
              child: Column(
            children: [
              Text(
                '$title',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              HtmlWidget(
                // You can add your custom styles here

                docHtml,
                textStyle:
                    TextStyle(fontSize: 16), // Adjust the font size as needed
              ),
            ],
          )),
        ),
      ),
    );
  }
}
