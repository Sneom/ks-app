import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kisan/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TourismSpot {
  final String name;
  final String imageURL;
  final String description;
  final String location;
  final List<String> galleryImages;
  int likes;
  int views;

  TourismSpot({
    required this.name,
    required this.imageURL,
    required this.description,
    required this.location,
    required this.galleryImages,
    this.likes = 0,
    this.views = 0,
  });
}

class AddTourismSpotScreen extends StatefulWidget {
  @override
  _AddTourismSpotScreenState createState() => _AddTourismSpotScreenState();
}

class _AddTourismSpotScreenState extends State<AddTourismSpotScreen> {
  String spotName = '';
  String spotImageURL = '';
  String spotDescription = '';
  String spotLocation = '';
  List<String> spotGalleryImages = [];
  int spotLikes = 0;
  int spotViews = 0;

  final ImagePicker picker = ImagePicker();

  Future<void> getSpotImage() async {
    final XFile? selectedImage =
        await picker.pickImage(source: ImageSource.gallery);

    if (selectedImage != null) {
      setState(() {
        spotImageURL = selectedImage.path;
      });
    }
  }

  Future<void> addGalleryImages() async {
    List<XFile> selectedImages = await picker.pickMultiImage();

    if (selectedImages != null && selectedImages.isNotEmpty) {
      setState(() {
        spotGalleryImages.addAll(selectedImages.map((image) => image.path));
      });
    }
  }

  void removeGalleryImage(int index) {
    setState(() {
      spotGalleryImages.removeAt(index);
    });
  }

  void submitTourismSpot() async {
    if (spotName.isEmpty || spotDescription.isEmpty || spotLocation == null) {
      // Validate the required fields before submitting
      return;
    }

    final user = supabase.auth.currentUser;
    String iconURL = "";
    List<String> imageUrls = [];

    if (spotImageURL.isNotEmpty) {
      String filename =
          '${user?.email}/${DateTime.now().millisecondsSinceEpoch}${spotImageURL.split('/').last}';
      final String storageResponse = await supabase.storage
          .from('products_images')
          .upload(
            filename,
            File(spotImageURL),
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      iconURL = filename;
    }

    if (spotGalleryImages.isNotEmpty) {
      for (int i = 0; i < spotGalleryImages.length; i++) {
        String filename =
            '${user?.email}/${DateTime.now().millisecondsSinceEpoch}${spotGalleryImages[i].split('/').last}';
        final String storageResponse =
            await supabase.storage.from('products_images').upload(
                  filename,
                  File(spotGalleryImages[i]),
                  fileOptions:
                      const FileOptions(cacheControl: '3600', upsert: false),
                );
        imageUrls.add(filename);
      }
    }

    final spotData = {
      'name': spotName,
      'description': spotDescription,
      'location': spotLocation.toString(),
      'imageurl': iconURL,
      'galleryimages': imageUrls,
    };

    final response = await supabase.from('agro_tourism').upsert([
      spotData,
    ]);
    Navigator.pop(context);
    if (response.error != null) {
      // Handle the error, e.g., show an error message
      print('Error inserting data: ${response.error!.message}');
    } else {
      // Successfully inserted the data
      print('Data inserted successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Tourism Spot'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    spotName = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Spot Name',
                  prefixIcon: Icon(Icons.place),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    spotDescription = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Spot Description',
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    spotLocation = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Spot Location',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: getSpotImage,
                icon: const Icon(Icons.add_a_photo),
                label: const Text('Add Spot Image'),
              ),
              if (spotImageURL.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Spot Image:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Image.file(
                      File(spotImageURL),
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: addGalleryImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Add Gallery Images'),
              ),
              if (spotGalleryImages.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Spot Gallery Images:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (int i = 0; i < spotGalleryImages.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Image.file(
                                    File(spotGalleryImages[i]),
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      removeGalleryImage(i);
                                    },
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: submitTourismSpot,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
