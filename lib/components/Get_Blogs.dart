import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kisan/components/Navigation.dart';
import 'package:kisan/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

// import 'package:flutter_html/flutter_html.dart';

class GetBlogs extends StatelessWidget {
  final String title;

  const GetBlogs({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SupabaseBlogs(title: title),
    );
  }
}

class SupabaseBlogs extends StatefulWidget {
  final String title;

  const SupabaseBlogs({Key? key, required this.title}) : super(key: key);

  @override
  _SupabaseBlogsState createState() => _SupabaseBlogsState();
}

class _SupabaseBlogsState extends State<SupabaseBlogs> {
  late Future<List<Map<String, dynamic>>> _fetchSupabaseBlogs;
  late PageController _pageController;
  int _currentPage = 0;
  TextEditingController _noteController = TextEditingController();
  List<String> _notes = [];

  @override
  void initState() {
    super.initState();
    _fetchSupabaseBlogs = fetchSupabaseBlogs();
    _pageController = PageController();

    // Load saved notes during widget initialization
    _loadNotes(widget.title);
  }

  Future<void> _loadNotes(String title) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedNotes = prefs.getStringList(title);

    if (savedNotes != null) {
      setState(() {
        _notes = savedNotes;
      });
    }
  }

  Future<void> _saveNotes(String title) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(title, _notes);
  }

  Future<List<Map<String, dynamic>>> fetchSupabaseBlogs() async {
    final response = await supabase
        .from('blogs')
        .select('*')
        .eq('category', widget.title)
        .order('created_at', ascending: false);

    if (response.isEmpty) {
      throw Exception('Failed to fetch content from Supabase');
    }

    return response as List<Map<String, dynamic>>;
  }

  Future<bool> checkIfRead(String title) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(title);
  }

  Future<void> markAsRead(String title) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(title, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7A9D54),
      body: FutureBuilder(
        future: _fetchSupabaseBlogs,
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Color(0xFF557A46),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF2EE9D)),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
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
                              builder: (context) => Navigation(
                                page: 0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Could not get the requested data!!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFFF2EE9D),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          } else {
            List<Map<String, dynamic>> jsonData = snapshot.data!;
            return Stack(
              children: [
                AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    return PageView.builder(
                      controller: _pageController,
                      itemCount: jsonData.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return FutureBuilder<bool>(
                          future: checkIfRead(jsonData[index]['title'] ?? ''),
                          builder: (context, snapshot) {
                            bool isRead = snapshot.data ?? false;
                            String note =
                                ""; // Add this line to get the note for the current title
                            return buildCard(
                              context,
                              jsonData[index],
                              isRead,
                              note,
                            );
                          },
                        );
                      },
                    );
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
                          MaterialPageRoute(
                            builder: (context) => Navigation(
                              page: 0,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Post ${_currentPage + 1} of ${jsonData.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget buildCard(BuildContext context, Map<String, dynamic> data, bool isRead,
      String note) {
    String _formatDateTime(String dateTimeString) {
      DateTime dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd MMM yyyy').format(dateTime);
    }

    return Stack(
      children: [
        Container(
          color: Colors.black.withOpacity(0.5),
          width: double.infinity,
          height: double.infinity,
        ),
        Positioned(
          top: 100,
          left: 16,
          right: 16,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['title'] ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: isRead ? Color(0xFFF2EE9D) : Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                data['description'] ?? '',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              Text(
                "Created: ${_formatDateTime(data['created_at'])}" ?? '',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                isRead ? "Read" : "Not Read",
                style: TextStyle(
                  fontSize: 16,
                  color: isRead ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      markAsRead(data['title'] ?? '');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlogContentWidget(
                              htmlContent: data['content'] ?? ''),
                        ),
                      );
                    },
                    child: Text(
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
}

class BlogContentWidget extends StatelessWidget {
  final String htmlContent;

  const BlogContentWidget({Key? key, required this.htmlContent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("ASDASDASDADS $htmlContent");
    return Scaffold(
      appBar: AppBar(
          // title: Text('Blog Content'),
          ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 15, 8, 8),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(1.0, 1.0, 1.0),
            child: HtmlWidget(
              htmlContent,
              textStyle: TextStyle(fontSize: 8.0, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}
