import 'package:flutter/material.dart';
import 'package:kisan/components/Auth.dart';
import 'package:kisan/components/Get_Blogs.dart';
import 'package:kisan/components/Fetch_Blog.dart';
import 'package:kisan/components/Home.dart';
import 'package:kisan/components/Products/add_products.dart';
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

class AuthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: Future.value(supabase.auth.currentUser),
      builder: (context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data != null) {
            return MyHomePage();
          } else {
            return AuthPage();
          }
        } else {
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
        backgroundColor: const Color(0xFF7A9D54), // Earthy green color
        title: const Text(
          'Kisan Sathi',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            color: Colors.white,
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
        //children: [AddProductScreen()],
      ),
      bottomNavigationBar: supabase.auth.currentUser != null
          ? BottomNavigationBar(
              backgroundColor: const Color(0xFF7A9D54), // Earthy green color
              currentIndex: _currentIndex,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white54,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                  _pageController.jumpToPage(index);
                });
              },
              items: const [
                BottomNavigationBarItem(
                  backgroundColor: Color(0xFF7A9D54),
                  icon: Icon(
                    Icons.home,
                  ),
                  label: 'Learn',
                ),
                BottomNavigationBarItem(
                  backgroundColor: Color(0xFF7A9D54),
                  icon: Icon(Icons.store),
                  label: 'Market',
                ),
                BottomNavigationBarItem(
                  backgroundColor: Color(0xFF7A9D54),
                  icon: Icon(Icons.cloud),
                  label: 'Weather',
                ),
                BottomNavigationBarItem(
                  backgroundColor: Color(0xFF7A9D54),
                  icon: Icon(Icons.feedback),
                  label: 'Feedback',
                )
              ],
            )
          : null,
    );
  }
}
