import 'package:flutter/material.dart';
import 'package:kisan/components/Tourism/AddSpots.dart';
import 'package:kisan/components/Tourism/Format.dart';

class TourismSpotCard extends StatelessWidget {
  final TourismSpot tourismSpot;

  const TourismSpotCard({required this.tourismSpot});

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
              "http://wddgaaiyqdiexmerxnue.supabase.co/storage/v1/object/public/products_images/${tourismSpot.imageURL}",
              fit: BoxFit.cover,
              height: 230.0,
            ),
          ),
          Container(
            color: Colors.blue, // Add your desired background color
            padding: const EdgeInsets.all(8.0),
            child: Text(
              tourismSpot.name,
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
                      tourismSpot.views.toString(),
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
                      "${_truncateLocation(tourismSpot.location)}",
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

class TourismSpotDetailsPage extends StatefulWidget {
  final TourismSpot tourismSpot;

  const TourismSpotDetailsPage({required this.tourismSpot});

  @override
  _TourismSpotDetailsPageState createState() => _TourismSpotDetailsPageState();
}

class _TourismSpotDetailsPageState extends State<TourismSpotDetailsPage> {
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
        title: Text(widget.tourismSpot.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                "http://wddgaaiyqdiexmerxnue.supabase.co/storage/v1/object/public/products_images/${widget.tourismSpot.imageURL}",
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
                widget.tourismSpot.description,
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
                widget.tourismSpot.location,
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
                      itemCount: widget.tourismSpot.galleryImages.length,
                      controller: pageController,
                      onPageChanged: (index) {
                        setState(() {
                          currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          "http://wddgaaiyqdiexmerxnue.supabase.co/storage/v1/object/public/products_images/${widget.tourismSpot.galleryImages[index]}",
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
                        widget.tourismSpot.galleryImages.length - 1)
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



//   TourismSpot(
//     name: 'Farm A',
//     imageURL:
//         'https://media.istockphoto.com/id/1280715716/photo/germany-stuttgart-magical-orange-sunset-sky-above-ripe-grain-field-nature-landscape-in-summer.jpg?s=2048x2048&w=is&k=20&c=-uLf9T2_JrczY6vSysfzITZgCDzAvbFpH50Akr7lPXU=',
//     description: 'Beautiful farm with various crops and animals.',
//     location:
//         'City X, Country Ydsfsdfsdfsddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd',
//     likes: 2,
//     views: 2,
//     galleryImages: [
//       'https://media.istockphoto.com/id/1280715716/photo/germany-stuttgart-magical-orange-sunset-sky-above-ripe-grain-field-nature-landscape-in-summer.jpg?s=2048x2048&w=is&k=20&c=-uLf9T2_JrczY6vSysfzITZgCDzAvbFpH50Akr7lPXU=',
//       'https://media.istockphoto.com/id/1280715716/photo/germany-stuttgart-magical-orange-sunset-sky-above-ripe-grain-field-nature-landscape-in-summer.jpg?s=2048x2048&w=is&k=20&c=-uLf9T2_JrczY6vSysfzITZgCDzAvbFpH50Akr7lPXU=',
//       'https://media.istockphoto.com/id/1280715716/photo/germany-stuttgart-magical-orange-sunset-sky-above-ripe-grain-field-nature-landscape-in-summer.jpg?s=2048x2048&w=is&k=20&c=-uLf9T2_JrczY6vSysfzITZgCDzAvbFpH50Akr7lPXU=',
//     ],
//   ),

//   TourismSpot(
//     name: 'Organic Orchard',
//     imageURL:
//         'https://media.istockphoto.com/id/1280715716/photo/germany-stuttgart-magical-orange-sunset-sky-above-ripe-grain-field-nature-landscape-in-summer.jpg?s=2048x2048&w=is&k=20&c=-uLf9T2_JrczY6vSysfzITZgCDzAvbFpH50Akr7lPXU=',
//     description: 'Explore a diverse collection of organic fruits.',
//     location: 'Town Z, Country W',
//     likes: 5,
//     views: 5,
//     galleryImages: [
//       'https://media.istockphoto.com/id/1280715716/photo/germany-stuttgart-magical-orange-sunset-sky-above-ripe-grain-field-nature-landscape-in-summer.jpg?s=2048x2048&w=is&k=20&c=-uLf9T2_JrczY6vSysfzITZgCDzAvbFpH50Akr7lPXU=',
//       'https://media.istockphoto.com/id/1280715716/photo/germany-stuttgart-magical-orange-sunset-sky-above-ripe-grain-field-nature-landscape-in-summer.jpg?s=2048x2048&w=is&k=20&c=-uLf9T2_JrczY6vSysfzITZgCDzAvbFpH50Akr7lPXU=',
//       'https://media.istockphoto.com/id/1280715716/photo/germany-stuttgart-magical-orange-sunset-sky-above-ripe-grain-field-nature-landscape-in-summer.jpg?s=2048x2048&w=is&k=20&c=-uLf9T2_JrczY6vSysfzITZgCDzAvbFpH50Akr7lPXU=',
//     ],
//   ),
//   TourismSpot(
//     name: 'dfsdfsd Orchard',
//     imageURL:
//         'https://media.istockphoto.com/id/1280715716/photo/germany-stuttgart-magical-orange-sunset-sky-above-ripe-grain-field-nature-landscape-in-summer.jpg?s=2048x2048&w=is&k=20&c=-uLf9T2_JrczY6vSysfzITZgCDzAvbFpH50Akr7lPXU=',
//     description: 'Explore a diverse collection of organic fruits.',
//     location: 'Town Z, Country W',
//     likes: 5,
//     views: 5,
//     galleryImages: [
//       'https://media.istockphoto.com/id/1280715716/photo/germany-stuttgart-magical-orange-sunset-sky-above-ripe-grain-field-nature-landscape-in-summer.jpg?s=2048x2048&w=is&k=20&c=-uLf9T2_JrczY6vSysfzITZgCDzAvbFpH50Akr7lPXU=',
//       'https://media.istockphoto.com/id/1280715716/photo/germany-stuttgart-magical-orange-sunset-sky-above-ripe-grain-field-nature-landscape-in-summer.jpg?s=2048x2048&w=is&k=20&c=-uLf9T2_JrczY6vSysfzITZgCDzAvbFpH50Akr7lPXU=',
//       'https://media.istockphoto.com/id/1280715716/photo/germany-stuttgart-magical-orange-sunset-sky-above-ripe-grain-field-nature-landscape-in-summer.jpg?s=2048x2048&w=is&k=20&c=-uLf9T2_JrczY6vSysfzITZgCDzAvbFpH50Akr7lPXU=',
//     ],
//   ),
//   // Add more tourism spots as needed
// ];
