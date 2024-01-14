import 'package:flutter/material.dart';
import 'package:kisan/components/Products/date_format.dart';
import 'package:kisan/components/Products/product_format.dart';
import 'package:kisan/main.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

String profileImageUrl = "";
Map<String, String> profileImageMap = {};
Map<String, dynamic> images = {};

class ProductCards extends StatelessWidget {
  final Product product;

  const ProductCards({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    String formattedDate = formatDate(product.date);
    if (profileImageMap.isEmpty) {
      fetchProfile(product.email);
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: const Color(0xFFF2EE9D),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seller information and posted date section
            Row(
              children: [
                CircleAvatar(
                  backgroundImage:
                      NetworkImage("${profileImageMap[product.email]}"),
                  radius: 30,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${product.name}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${formattedDate}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Product details section
            Text(
              product.product,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.description,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Price: ₹${product.price}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${product.tosell}',
              style: const TextStyle(
                color: Colors.green,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${product.city}, ${product.state}",
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            // Image section

            if (product.images.isNotEmpty)
              Container(
                height: 300, // Adjust the height as needed
                child: PhotoViewGallery.builder(
                  itemCount: product.images.length,
                  builder: (context, index) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider: NetworkImage(
                        "http://wddgaaiyqdiexmerxnue.supabase.co/storage/v1/object/public/products_images/${product.images[index]}",
                      ),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2,
                    );
                  },
                  scrollPhysics: BouncingScrollPhysics(),
                  backgroundDecoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  pageController: PageController(),
                  onPageChanged: (index) {
                    // Handle page change if needed
                    print("Current Image: $index");
                  },
                ),
              ),
            // if (product.images.isNotEmpty)
            //   Row(
            //     children: [
            //       for (int index = 0; index < product.images.length; index++)
            //         Padding(
            //           padding: const EdgeInsets.all(4.0),
            //           child: Image.network(
            //             "http://wddgaaiyqdiexmerxnue.supabase.co/storage/v1/object/public/products_images/${product.images[index]}",
            //             width: 100, // Adjust the width as needed
            //           ),
            //         ),
            //     ],
            //   ),

            const SizedBox(height: 16),
            // Buy button
            if (product.email != user?.email)
              ElevatedButton(
                onPressed: () {
                  // Implement buy button logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF557A46),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('Buy Now'),
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> fetchProfile(String userEmail) async {
  try {
    final response = await supabase
        .from('users')
        .select('profile')
        .eq('email', userEmail)
        .single();

    profileImageUrl = response['profile'] as String;
    profileImageMap[userEmail] = profileImageUrl;

    print("Profile url : $response");
  } catch (error) {
    // Handle error
    print('Error fetching user profile: $error');
  }
}
