import 'package:flutter/material.dart';
import 'package:kisan/components/Language/Language_Texts.dart';
import 'package:kisan/components/Navigation.dart';
import 'package:kisan/components/Products/date_format.dart';
import 'package:kisan/components/Products/product_format.dart';
import 'package:kisan/main.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';

String profileImageUrl = "";
Map<String, String> profileImageMap = {};

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late PageController pageController;
  int currentPage = 0;
  String selectedLanguage = '';

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();

    pageController = PageController();
  }

  Future<void> _loadSelectedLanguage() async {
    final preferences = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = preferences.getString('selectedLanguage') ?? 'english';
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    String formattedDate = formatDate(widget.product.date);
    fetchProfile(widget.product.email);
    Map<String, String> titles =
        LanguageTexts.marketTexts[selectedLanguage] ?? {};
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
                      NetworkImage("${profileImageMap[widget.product.email]}"),
                  radius: 30,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${widget.product.name}",
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
              widget.product.product,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.product.description,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              '${titles['price']}: ₹${widget.product.price}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.product.tosell}',
              style: const TextStyle(
                color: Colors.green,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${titles[widget.product.city]}, ${titles[widget.product.state]}",
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            // const SizedBox(height: 16),
            // Image section
            if (widget.product.images.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImageGallery(
                            images: widget.product.images,
                            initialIndex: currentPage,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      // Adjust the height as needed
                      height: 300,
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          PhotoViewGallery.builder(
                            itemCount: widget.product.images.length,
                            builder: (context, index) {
                              return PhotoViewGalleryPageOptions(
                                imageProvider: NetworkImage(
                                  "http://wddgaaiyqdiexmerxnue.supabase.co/storage/v1/object/public/products_images/${widget.product.images[index]}",
                                ),
                                minScale: PhotoViewComputedScale.contained,
                                maxScale: PhotoViewComputedScale.covered * 2,
                                heroAttributes: PhotoViewHeroAttributes(
                                  tag: widget.product.images[index],
                                ),
                              );
                            },
                            scrollPhysics: const BouncingScrollPhysics(),
                            backgroundDecoration: const BoxDecoration(),
                            pageController: pageController,
                            onPageChanged: (index) {
                              setState(() {
                                currentPage = index;
                              });
                            },
                            loadingBuilder: (context, event) {
                              return const Center(
                                child: CircularProgressIndicator(),
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
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                ),
                              ),
                            ),
                          if (currentPage < widget.product.images.length - 1)
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
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${currentPage + 1} of ${widget.product.images.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            const SizedBox(height: 16),
            // Buy button
            if (widget.product.email != user?.email)
              ElevatedButton(
                onPressed: () {
                  // Implement buy button logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF557A46),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: Text('${titles['buynow']}'),
              ),
            if (widget.product.email == user?.email)
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("${titles['confirmDeletion']}"),
                        content: Text("${titles['areYouSure']}"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close the dialog
                            },
                            child: Text("${titles['cancel']}"),
                          ),
                          TextButton(
                            onPressed: () async {
                              // Perform the deletion logic here
                              await deleteProduct(widget.product.id);
                              Navigator.pop(context); // Close the dialog
                            },
                            child: Text("${titles['yes']}"),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: Text("${titles['delete']}"),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteProduct(String productId) async {
    try {
      // Delete images from Supabase Storage   "${widget.product.email}/$image",
      for (String image in widget.product.images) {
        await supabase.storage.from('products_images').remove(["$image"]);

        print("$image");
      }

      // Delete the product from Supabase database
      await supabase.from('products').delete().eq('id', productId);

      // Navigate to the refreshed page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Navigation(
            page: 1,
          ),
        ),
      );
    } catch (error) {
      // Handle error
      print('Error deleting product: $error');
    }
  }
}

Future<void> fetchProfile(String userEmail) async {
  if (!profileImageMap.containsKey(userEmail)) {
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
  } else {
    print("Contains");
  }
}

class FullScreenImageGallery extends StatelessWidget {
  final List<dynamic> images;
  final int initialIndex;

  FullScreenImageGallery({
    required this.images,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhotoViewGallery.builder(
        itemCount: images.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(
              "http://wddgaaiyqdiexmerxnue.supabase.co/storage/v1/object/public/products_images/${images[index]}",
            ),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        backgroundDecoration: const BoxDecoration(
          color: Colors.black,
        ),
        pageController: PageController(initialPage: initialIndex),
      ),
    );
  }
}
