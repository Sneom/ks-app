import 'package:flutter/material.dart';
import 'package:kisan/components/Get_Blogs.dart';
import 'package:kisan/main.dart';
import 'package:supabase/supabase.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> weatherData = [];

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    // Get today's date in the 'dd/MM/yyyy' format
    String todayDate = "" + DateFormat('dd/MM/yyyy').format(DateTime.now());
    // Fetch weather data for today's date
    final response =
        await supabase.from('weather_data').select().eq('date', todayDate);

    if (response.isEmpty) {
      print('Error fetching data');
    } else {
      setState(() {
        weatherData = response as List<Map<String, dynamic>>;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7A9D54),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const ClickableCategoryCard(
                icon: Icons.eco,
                title: 'Organic Farming',
                description: 'Explore sustainable farming practices.',
              ),
              const SizedBox(height: 16),
              const ClickableCategoryCard(
                icon: Icons.pets,
                title: 'Animal Husbandry',
                description: 'Learn about livestock and animal care.',
              ),
              const SizedBox(height: 16),
              const ClickableCategoryCard(
                icon: Icons.local_florist,
                title: 'Nourishment Garden',
                description: 'Create a beautiful and healthy garden.',
              ),
              const SizedBox(height: 16),
              const ClickableCategoryCard(
                icon: Icons.food_bank,
                title: 'Food Processing',
                description:
                    'Discover methods of food preservation and processing.',
              ),
              const SizedBox(height: 16),
              WeatherInformationWidget(weatherData: weatherData),
            ],
          ),
        ),
      ),
    );
  }
}

class WeatherInformationWidget extends StatelessWidget {
  final List<Map<String, dynamic>> weatherData;

  WeatherInformationWidget({required this.weatherData});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WeatherDetailScreen(weatherData: weatherData),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.blue, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Today\'s Weather',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
                if (weatherData.isNotEmpty)
                  ...weatherData.map(
                    (data) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${data['date']}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Icon(_getWeatherIcon(data['weather']),
                                size: 30, color: Colors.white),
                          ],
                        ),
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              const TextSpan(
                                text: 'Temperature: ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: '${data['temperature']}°C',
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              const TextSpan(
                                text: 'Chance of Rain: ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: '${data['rain_chances']}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              const TextSpan(
                                text: 'Wind Speed: ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: '${data['wind_speed']} km/hr',
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Todays Tip",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text('${data['tip']}',
                            style: const TextStyle(color: Colors.white)),
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

  IconData _getWeatherIcon(String weather) {
    switch (weather.toLowerCase()) {
      case 'sunny':
        return Icons.wb_sunny;
      case 'cloudy':
        return Icons.cloud;
      case 'rainy':
        return Icons.beach_access;
      // Add more cases for different weather conditions as needed
      default:
        return Icons.wb_sunny;
    }
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

class WeatherDetailScreen extends StatelessWidget {
  final List<Map<String, dynamic>> weatherData;

  WeatherDetailScreen({required this.weatherData});

  String formatTime(String time) {
    DateTime dummyDate = DateTime.parse('2024-01-01 $time');
    return DateFormat.jm().format(dummyDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Details'),
        backgroundColor: const Color(0xFF438C6E), // Adjusted color
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF68A88A), // Background gradient color
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (weatherData.isNotEmpty)
              ...weatherData.map(
                (data) => Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.grey[200]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildCardItem('Temperature',
                              '${data['temperature']}°C', Icons.thermostat),
                          buildCardItem('Sunrise',
                              '${formatTime(data['sunrise'])}', Icons.sunny),
                          buildCardItem('Sunset',
                              '${formatTime(data['sunset'])}', Icons.wb_sunny),
                          buildCardItem('Wind Speed',
                              '${data['wind_speed']} km/hr', Icons.speed),
                          buildCardItem('Wind Direction',
                              '${data['wind_direction']}', Icons.explore),
                          buildCardItem(
                              'Humidity', '${data['humidity']}%', Icons.water),
                          buildCardItem(
                              'Weather', '${data['weather']}', Icons.cloud),
                          buildCardItem('Rain Chances',
                              '${data['rain_chances']}%', Icons.beach_access),
                          buildCardItem(
                              'Tip', '${data['tip']}', Icons.lightbulb),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildCardItem(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue), // Adjusted icon color
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(value),
    );
  }
}
