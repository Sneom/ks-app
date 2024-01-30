import 'package:flutter/material.dart';
import 'package:kisan/components/Stories/AddStories.dart';
import 'package:kisan/components/Stories/DetailsPage.dart';
import 'package:kisan/components/Stories/Format.dart';
import 'package:kisan/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Stories extends StatefulWidget {
  const Stories({Key? key}) : super(key: key);

  @override
  _FarmersSuccessStoriesPage createState() => _FarmersSuccessStoriesPage();
}

class _FarmersSuccessStoriesPage extends State<Stories> {
  List<FarmersSuccessStories> farmersSuccessStories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFarmersSuccessStories();
  }

  Future<void> fetchFarmersSuccessStories() async {
    try {
      final response = await supabase
          .from('farmer_success_stories')
          .select()
          .eq('verified', 'TRUE');

      if (response.isEmpty) {
        print('No data available.');
      }

      List<FarmersSuccessStories> list = [];

      for (var row in response as List) {
        list.add(FarmersSuccessStories(
          id: row['id'] as String,
          name: row['name'] as String,
          imageURL: row['imageurl'] as String,
          description: row['description'] as String,
          location: row['location'] as String,
          galleryImages: (row['galleryimages'] as List).cast<String>(),
          views: row['views'] as int,
        ));
      }

      setState(() {
        farmersSuccessStories = list;
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
        child: Column(
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
                          itemCount: farmersSuccessStories.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                String cardId = farmersSuccessStories[index].id;

                                if (!prefs.containsKey(cardId)) {
                                  prefs.setBool(cardId, true);

                                  setState(() {
                                    farmersSuccessStories[index].views++;
                                  });
                                  int views =
                                      farmersSuccessStories[index].views;

                                  final response = await supabase
                                      .from('farmer_success_stories')
                                      .update({
                                    'views':
                                        '${farmersSuccessStories[index].views}'
                                  }).eq('id', '$cardId');
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FarmersSuccessStoriesDetailsPage(
                                      farmersSuccessStories:
                                          farmersSuccessStories[index],
                                    ),
                                  ),
                                );
                              },
                              child: FarmersSuccessStoriesCard(
                                  farmersSuccessStories:
                                      farmersSuccessStories[index]),
                            );
                          },
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddFarmersSuccessStoriesScreen(),
            ),
          );
        },
        child: Icon(Icons.create),
      ),
    );
  }
}
