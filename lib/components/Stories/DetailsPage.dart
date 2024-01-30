import 'package:flutter/material.dart';
import 'package:kisan/components/Stories/AddStories.dart';
import 'package:kisan/components/Stories/Format.dart';

class FarmersSuccessStoriesCard extends StatelessWidget {
  final FarmersSuccessStories farmersSuccessStories;

  const FarmersSuccessStoriesCard({required this.farmersSuccessStories});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(15.0)),
            child: Image.network(
              "http://wddgaaiyqdiexmerxnue.supabase.co/storage/v1/object/public/farmer_stories_images/${farmersSuccessStories.imageURL}",
              fit: BoxFit.cover,
              height: 230.0,
            ),
          ),
          Container(
            color: Colors.blue, // Add your desired background color
            padding: const EdgeInsets.all(8.0),
            child: Text(
              farmersSuccessStories.name,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Text color
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.visibility,
                        color: Colors.green), // Visibility icon
                    const SizedBox(width: 4.0),
                    Text(
                      farmersSuccessStories.views.toString(),
                      style: const TextStyle(
                        color: Colors.black, // Views count text color
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.green), // Visibility icon
                    const SizedBox(width: 4.0),
                    Text(
                      "${_truncateLocation(farmersSuccessStories.location)}",
                      style: const TextStyle(
                        color: Colors.black, // Views count text color
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _truncateLocation(String location) {
    const maxChars = 35; // Set your desired character limit
    return location.length > maxChars
        ? '${location.substring(0, maxChars)}...'
        : location;
  }
}

class FarmersSuccessStoriesDetailsPage extends StatefulWidget {
  final FarmersSuccessStories farmersSuccessStories;

  const FarmersSuccessStoriesDetailsPage({required this.farmersSuccessStories});

  @override
  _FarmersSuccessStoriesDetailsPageState createState() =>
      _FarmersSuccessStoriesDetailsPageState();
}

class _FarmersSuccessStoriesDetailsPageState
    extends State<FarmersSuccessStoriesDetailsPage> {
  late PageController pageController;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.farmersSuccessStories.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                "http://wddgaaiyqdiexmerxnue.supabase.co/storage/v1/object/public/farmer_stories_images/${widget.farmersSuccessStories.imageURL}",
                height: 200.0,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Description:',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                widget.farmersSuccessStories.description,
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Location:',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                widget.farmersSuccessStories.location,
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Image Gallery:',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Container(
                height: 300,
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    PageView.builder(
                      itemCount:
                          widget.farmersSuccessStories.galleryImages.length,
                      controller: pageController,
                      onPageChanged: (index) {
                        setState(() {
                          currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          "http://wddgaaiyqdiexmerxnue.supabase.co/storage/v1/object/public/farmer_stories_images/${widget.farmersSuccessStories.galleryImages[index]}",
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                    if (currentPage > 0)
                      Positioned(
                        left: 16,
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0x80FFFFFF),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () {
                              pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ),
                      ),
                    if (currentPage <
                        widget.farmersSuccessStories.galleryImages.length - 1)
                      Positioned(
                        right: 16,
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0x80FFFFFF),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: () {
                              pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
