import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class FetchDriveData extends StatefulWidget {
  final String title;
  final String description;
  final String link;

  const FetchDriveData({
    Key? key,
    required this.title,
    required this.description,
    required this.link,
  }) : super(key: key);

  @override
  _GoogleDriveState createState() => _GoogleDriveState(
        title: title,
        description: description,
        link: link,
      );
}

class _GoogleDriveState extends State<FetchDriveData> {
  final String title;
  final String description;
  final String link;

  _GoogleDriveState({
    required this.title,
    required this.description,
    required this.link,
  });

  String docHtml = '';
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGoogleDocsHtml();

    controller = WebViewController()
      ..loadRequest(
        Uri.parse(link),
      );
    controller.runJavaScript('window.scrollTo(0, 500);');
  }

  Future<void> fetchGoogleDocsHtml() async {
    try {
      final response = await http.get(Uri.parse(link));

      if (response.statusCode == 200) {
        setState(() {
          docHtml = response.body;
          isLoading = false;
        });

        // Scroll to a specific height after the WebView has loaded
      } else {
        setState(() {
          docHtml = 'Failed to fetch content';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        docHtml = 'Failed to fetch content';
        isLoading = false;
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF7A9D54),
      appBar: AppBar(
        backgroundColor: Color(0xFF557A46),
        title: Text(
          '$title',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFF2EE9D),
          ),
        ),
        foregroundColor: Color(0xFFF2EE9D),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -90,
            left: 0,
            right: 0,
            bottom: 0,
            child: WebViewWidget(
              controller: controller,
            ),
          ),
          if (isLoading)
            Center(
              child: RefreshProgressIndicator(
                backgroundColor: Color(0xFF557A46),
                color: Color(0xFFF2EE9D),
              ),
            ),
        ],
      ),
    );
  }
}
