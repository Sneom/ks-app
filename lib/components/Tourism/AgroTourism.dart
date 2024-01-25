import 'package:flutter/material.dart';
import 'package:kisan/components/Tourism/AddSpots.dart';
import 'package:kisan/components/Tourism/DetailsPage.dart';
import 'package:kisan/components/Tourism/Format.dart';
import 'package:kisan/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Tourism extends StatefulWidget {
  const Tourism({Key? key}) : super(key: key);

  @override
  _TourismSpotPage createState() => _TourismSpotPage();
}

class _TourismSpotPage extends State<Tourism> {
  List<TourismSpot> tourismSpots = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTourismSpots();
  }

  Future<void> fetchTourismSpots() async {
    try {
      final response =
          await supabase.from('agro_tourism').select().eq('verified', 'TRUE');

      if (response.isEmpty) {
        print('No data available.');
      }

      List<TourismSpot> list = [];

      for (var row in response as List) {
        list.add(TourismSpot(
          id: row['id'] as String,
          name: row['name'] as String,
          imageURL: row['imageurl'] as String,
          description: row['description'] as String,
          location: row['location'] as String,
          galleryImages: (row['galleryimages'] as List).cast<String>(),
          // likes: row['likes'] as int,
          views: row['views'] as int,
        ));
      }

      setState(() {
        tourismSpots = list;
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Container(
                        child: GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                            childAspectRatio: 1.2,
                          ),
                          itemCount: tourismSpots.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                String cardId = tourismSpots[index].id;

                                if (!prefs.containsKey(cardId)) {
                                  prefs.setBool(cardId, true);

                                  setState(() {
                                    tourismSpots[index].views++;
                                  });
                                  int views = tourismSpots[index].views;

                                  final response = await supabase
                                      .from('agro_tourism')
                                      .update({
                                    'views': '${tourismSpots[index].views}'
                                  }).eq('id', '$cardId');
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TourismSpotDetailsPage(
                                      tourismSpot: tourismSpots[index],
                                    ),
                                  ),
                                );
                              },
                              child: TourismSpotCard(
                                  tourismSpot: tourismSpots[index]),
                            );
                          },
                        ),
                      ),
                    ),
            ),
            Positioned(
              bottom: 16.0,
              right: 16.0,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddTourismSpotScreen(),
                    ),
                  );
                },
                child: Icon(Icons.create),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
