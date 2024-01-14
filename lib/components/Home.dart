import 'package:flutter/material.dart';
import 'package:kisan/components/Get_Blogs.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 12,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Farmers Hub"),
          backgroundColor: Colors.green[600], // Use earthy green color
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Sustainable Farming'),
              Tab(text: 'Livestock Care'),
              Tab(text: 'Garden Cultivation'),
              Tab(text: 'Food Preservation'),
              Tab(text: 'Buying and Selling'),
              Tab(text: 'Bank'),
              Tab(text: 'Daily Wages Workers'),
              Tab(text: 'Weather'),
              Tab(text: 'Farmers Scheme'),
              Tab(text: 'Tourism on Farming'),
              Tab(text: 'Success Stories'),
              Tab(text: 'Feedback'),
            ],
          ),
        ),
        backgroundColor: Color(0xFFE6E6E6),
        body: TabBarView(
          children: [
            ClickableCategoryCard(
              icon: Icons.spa,
              title: 'Organic Farming',
              description: 'Explore sustainable farming practices.',
            ),
            ClickableCategoryCard(
              icon: Icons.pets,
              title: 'Livestock Care',
              description: 'Learn about livestock and animal husbandry.',
            ),
            ClickableCategoryCard(
              icon: Icons.eco_outlined,
              title: 'Garden Cultivation',
              description: 'Create a beautiful and nourishing garden.',
            ),
            ClickableCategoryCard(
              icon: Icons.food_bank,
              title: 'Food Preservation',
              description:
                  'Discover methods of food preservation and processing.',
            ),
            // Add more ClickableCategoryCard widgets for other tabs
            // ...
            // Make sure to provide the relevant data for each category
          ],
        ),
      ),
    );
  }
}

class ClickableCategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const ClickableCategoryCard({
    required this.icon,
    required this.title,
    required this.description,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GetBlogs(title: title)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Icon(icon, size: 48, color: Colors.green),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
