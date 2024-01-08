import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kisan/components/Fetch_Blog.dart';
import 'package:kisan/components/Navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  late PageController _pageController;
  int _currentPage = 0;
  TextEditingController _noteController = TextEditingController();
  List<String> _notes = [];

  @override
  void initState() {
    super.initState();
    _fetchGoogleDocsText = fetchGoogleDocsText();
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
        future: _fetchGoogleDocsText,
        builder: (context, AsyncSnapshot<List<Map<String, String>>> snapshot) {
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
                              builder: (context) => Navigation(),
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
            List<Map<String, String>> jsonData = snapshot.data!;
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
                            builder: (context) => Navigation(),
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
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _showNoteDialog(
                                context, jsonData[_currentPage]['title'] ?? '');
                          },
                          child: Text(
                            'Add Note',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: const Color(0xFF557A46),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        child: _buildNotesList(
                            jsonData[_currentPage]['title'] ?? ''),
                      ),
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

  Widget _buildNotesList(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes for "$title":',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _notes
                .map((note) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _showEditNoteDialog(context, title, note);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _deleteNote(title, note);
                              },
                            ),
                          ],
                        ),
                      ],
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  void _showNoteDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Note'),
          content: TextField(
            controller: _noteController,
            decoration: InputDecoration(labelText: 'Enter your note'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _notes.add(_noteController.text);
                  _noteController.clear();
                });
                _saveNotes(title); // Save notes when adding a new note
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditNoteDialog(BuildContext context, String title, String note) {
    _noteController.text = note;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Note'),
          content: TextField(
            controller: _noteController,
            decoration: InputDecoration(labelText: 'Edit your note'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  int index = _notes.indexOf(note);
                  _notes[index] = _noteController.text;
                  _noteController.clear();
                });
                _saveNotes(title); // Save notes when editing a note
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteNote(String title, String note) {
    setState(() {
      _notes.remove(note);
    });
    _saveNotes(title); // Save notes when deleting a note
  }

  Widget buildCard(BuildContext context, Map<String, String> data, bool isRead,
      String note) {
    return Stack(
      children: [
        // Positioned(
        //   child: Image.asset(
        //     bgimage,
        //     fit: BoxFit.cover,
        //     width: double.infinity,
        //     height: double.infinity,
        //   ),
        // ),
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
                  //color: isRead ? Color(0xFFF2EE9D) : Colors.white,
                ),
              ),
              Text(
                "Created: ${data['created']}" ?? '',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  //color: isRead ? Color(0xFFF2EE9D) : Colors.white,
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
        } else if (line.startsWith('"created"')) {
          currentEntry['created'] =
              line.split(':')[1].trim().replaceAll('"', '');
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
