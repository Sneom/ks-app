import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kisan/main.dart';
import 'dart:io';
import 'package:supabase/supabase.dart';
import 'dart:typed_data'; // Import this

class AddProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String productName = '';
  String description = '';
  String selectedUnit = 'Per Day'; // Default value
  File? _image;
  String price = '0';

  final ImagePicker picker = ImagePicker();
  late final List<XFile> images;
  Future<void> getImage() async {
    // Pick an image.
    images = await picker.pickMultiImage();
    print("Images ${images[0].path}");
    print("Type ${images[0].name}");

    setState(() {
      if (images != null) {
        _image = File(images[0].path);
      }
    });
  }

  Future<void> uploadImagesAndSubmit() async {
    if (_image == null) {
      print("Null");
      return;
    }
    print("NotNull");
    final user = supabase.auth.currentUser;
    // Create a File object from the image bytes
    final avatarFile = File(images[0].path);

    final String storageResponse = await supabase.storage
        .from('products_images')
        .upload(
          '${user?.email}/${DateTime.now().millisecondsSinceEpoch}${images[0].name}',
          avatarFile,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    print("STORage Repre $storageResponse");
    if (storageResponse.isNotEmpty) {
      // final imageUrl = storageResponse.data['url'].toString();
      final imageUrl = storageResponse.toString();

      // Insert data into Supabase table
      final response = await supabase.from('products').upsert([
        {
          'name': user?.userMetadata?['full_name'],
          'email': user?.email,
          'product': productName,
          'description': description,
          'price': price,
          'type': selectedUnit,
          'city': 'Your City', // Replace with actual city value
          'state': 'Your State', // Replace with actual state value
          'images': [imageUrl],
          // Add other fields as needed
        },
      ]);

      if (response.error != null) {
        // Handle Supabase insertion error
        print('Supabase error: ${response.error!.message}');
      } else {
        // Data inserted successfully
        print('Data inserted successfully');
      }
    } else {
      // Handle Supabase Storage upload error
      print('Supabase Storage error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  productName = value;
                });
              },
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              onChanged: (value) {
                setState(() {
                  description = value;
                });
              },
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              onChanged: (value) {
                setState(() {
                  price = value;
                  print(price);
                });
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Price'),
            ),
            DropdownButton<String>(
              value: selectedUnit,
              onChanged: (value) {
                setState(() {
                  selectedUnit = value!;
                });
              },
              items: ['Per Day', 'Per Week', 'Per Month', 'To Sell']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              hint: Text('Select Unit'),
            ),
            ElevatedButton(
              onPressed: getImage,
              child: Text('Upload Image'),
            ),
            _image != null ? Image.file(_image!) : Text('No image selected.'),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: uploadImagesAndSubmit,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
