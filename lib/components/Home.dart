import 'package:flutter/material.dart';
import 'package:kisan/components/Get_Blogs.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF7A9D54),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
            // crossAxisAlignment: CrossAxisAlignment.stretch, // Remove this line
            children: [
              // Text(
              //   "Learn Farming Methods",
              //   style: TextStyle(
              //       fontSize: 25,
              //       fontWeight: FontWeight.bold,
              //       color: Colors.white),
              // ),
              SizedBox(height: 16),
              ClickableCategoryCard(
                icon: Icons.eco,
                title: 'Organic Farming',
                description: 'Explore sustainable farming practices.',
              ),
              SizedBox(height: 16),
              ClickableCategoryCard(
                icon: Icons.pets,
                title: 'Animal Husbandry',
                description: 'Learn about livestock and animal care.',
              ),
              SizedBox(height: 16),
              ClickableCategoryCard(
                icon: Icons.local_florist,
                title: 'Nourishment Garden',
                description: 'Create a beautiful and healthy garden.',
              ),
              SizedBox(height: 16),
              ClickableCategoryCard(
                icon: Icons.food_bank,
                title: 'Food Processing',
                description:
                    'Discover methods of food preservation and processing.',
              ),
            ],
          ),
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
      child: CategoryCard(
        icon: icon,
        title: title,
        description: description,
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const CategoryCard({
    required this.icon,
    required this.title,
    required this.description,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
