import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

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

  Future<void> downloadPdf() async {
    final pdf = pw.Document();

    // Add content to the PDF
    pdf.addPage(pw.Page(build: (pw.Context context) {
      return pw.Center(
        child: pw.Text(docHtml),
      );
    }));

    try {
      // Get the application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/example.pdf';

      // Save the PDF to the documents directory
      await File(filePath).writeAsBytes(await pdf.save());

      // Notify the user that the PDF has been downloaded
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF downloaded successfully!'),
        ),
      );
    } catch (e) {
      print('Error saving PDF: $e');
    }
  }

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
        actions: [
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: downloadPdf,
          ),
        ],
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
              child: CircularProgressIndicator(
                backgroundColor: Color(0xFF557A46),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF2EE9D)),
              ),
            ),
        ],
      ),
    );
  }
}
