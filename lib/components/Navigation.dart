import 'package:flutter/material.dart';
import 'package:kisan/components/Auth.dart';
import 'package:kisan/components/Get_Blogs.dart';
import 'package:kisan/components/Fetch_Blog.dart';
import 'package:kisan/components/Home.dart';
import 'package:kisan/components/Products/agri_products.dart';
import 'package:kisan/components/Profile.dart';
import 'package:kisan/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Navigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthChecker(),
    );
  }
}

bool isAdmin = false;

class AuthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      // Check if a user is already authenticated
      future: Future.value(supabase.auth.currentUser),
      builder: (context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data != null) {
            // User is signed in, navigate to HomePage
            return MyHomePage();
          } else {
            // User is not signed in, navigate to SignInPage
            return AuthPage();
          }
        } else {
          // Still loading authentication status
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  late PageController _pageController;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF557A46),
        title: const Text(
          'Kisan Sathi', // Add the heading in the center
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF2EE9D),
          ),
        ),
        centerTitle: true,
        actions: [
          // Add a user profile icon on the left side
          IconButton(
            icon: const Icon(Icons.account_circle),
            color: const Color(0xFFF2EE9D),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [const HomePage(), ProductListPage()],
      ),
      bottomNavigationBar: supabase.auth.currentUser != null
          ? BottomNavigationBar(
              backgroundColor: const Color(
                  0xFF557A46), // Set the color of the navigation bar

              currentIndex: _currentIndex,
              selectedItemColor: const Color(0xFFF2EE9D),
              unselectedItemColor: Colors.white,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                  _pageController.jumpToPage(index);
                });
              },
              items: const [
                BottomNavigationBarItem(
                  backgroundColor: Color(0xFF557A46),
                  icon: Icon(
                    Icons.home,
                  ),
                  label: 'Learn',
                ),
                BottomNavigationBarItem(
                  backgroundColor: Color(0xFF557A46),
                  icon: Icon(Icons.store),
                  label: 'Market',
                ),
                BottomNavigationBarItem(
                  backgroundColor: Color(0xFF557A46),
                  icon: Icon(Icons.cloud),
                  label: 'Weather',
                ),
                BottomNavigationBarItem(
                  backgroundColor: Color(0xFF557A46),
                  icon: Icon(Icons.feedback),
                  label: 'Feedback',
                )
              ],
            )
          : null, // Set to null to hide the bottom navigation bar
    );
  }
}
