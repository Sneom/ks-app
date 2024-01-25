class TourismSpot {
  final String id;
  final String name;
  final String imageURL;
  final String description;
  final String location;
  final List<String> galleryImages;
  int likes;
  int views;

  TourismSpot({
    required this.id,
    required this.name,
    required this.imageURL,
    required this.description,
    required this.location,
    required this.galleryImages,
    this.likes = 0,
    this.views = 0,
  });
}
