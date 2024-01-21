import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kisan/components/Language/Language_Texts.dart';
import 'package:kisan/components/Products/add_products.dart';
import 'package:kisan/components/Products/date_format.dart';
import 'package:kisan/components/Products/product_design.dart';
import 'package:kisan/components/Products/product_format.dart';
import 'package:kisan/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late ScrollController _scrollController;
  bool _isNearMeSearch = false;

  TextEditingController _searchController = TextEditingController();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  int _numberOfProductsToShow = 2; // Initial number of products to show
  bool _isLoading = false;
  String city = '', state = '', email = '';
  bool _isNearMe = true;
  bool _isMyProducts = true;
  bool _isFetchingLocation = false;
  String selectedLanguage = '';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    _loadSelectedLanguage();

    // Fetch initial products
    _fetchProducts();
  }

  Future<void> _loadSelectedLanguage() async {
    final preferences = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = preferences.getString('selectedLanguage') ?? 'english';
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (!_isLoading &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      // User has reached the end of the list, fetch more products
      if (_searchController.text.isEmpty) {
        // If not searching, fetch more products normally
        _fetchProducts();
      } else {
        // If searching, fetch more products related to the search term
        _fetchProducts(searchTerm: _searchController.text);
      }
    }
  }

  Future<void> _fetchProducts({String? searchTerm}) async {
    setState(() {
      _isLoading = true;
    });
    // Fetch products from 'products' table using Supabase
    final response = await supabase
        .from('products')
        .select()
        .ilike('city', '%$city%')
        .ilike('state', '%$state%')
        .ilike('email', '%$email%')
        .order('created_at', ascending: false)
        .range(_products.length, _products.length + _numberOfProductsToShow);

    // Map the response data to the Product class
    List<Product> fetchedProducts = response
        .map<Product>((data) => Product(
              product: data['product'] as String,
              description: data['description'] as String,
              price: data['price'] as String,
              tosell: data['type'] as String,
              name: data['name'] as String,
              date: data['created_at'],
              city: data['city'] as String,
              state: data['state'] as String,
              email: data['email'] as String,
              images: data['images'],
              id: data['id'] as String,
            ))
        .toList();

    // Add the fetched products to the list
    _products.addAll(fetchedProducts);

    // Update the state to trigger a rebuild
    setState(() {
      _isLoading = false;
      _filteredProducts = _searchController.text.isEmpty
          ? _products
          : _products
              .where((product) => product.product
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()))
              .toList();
    });
  }

  Future<void> _refreshProducts() async {
    // Clear the current products and fetch the initial set
    _products.clear();
    await _fetchProducts();
  }

  void _searchProducts(String query) {
    setState(() {
      _filteredProducts = _products
          .where((product) =>
              product.product.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> titles =
        LanguageTexts.marketTexts[selectedLanguage] ?? {};
    return Scaffold(
      backgroundColor: const Color(0xFF7A9D54),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 70.0,
            floating: true,
            pinned: true,
            shadowColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(color: Color(0xFF7A9D54)),
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 12.0, bottom: 8.0, left: 16.0, right: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 240, 240, 240),
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          child: Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 14.0),
                                child: Icon(
                                  Icons.search,
                                  color: Color(0xFF7A9D54),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  cursorColor: const Color(0xFF7A9D54),
                                  controller: _searchController,
                                  onChanged: _searchProducts,
                                  decoration: InputDecoration(
                                    hintText: '${titles['searchproducts']}',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 100,
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _isMyProducts = !_isMyProducts;
                                    });
                                    _isMyProducts
                                        ? _showAllProducts()
                                        : _showMyProducts();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: const Color(0xFFF2EE9D),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                  ),
                                  child: Text(
                                    _isMyProducts
                                        ? '${titles['myproducts']}'
                                        : '${titles['allproducts']}',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              if (_isFetchingLocation == false)
                                SizedBox(
                                  width: 100,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _isNearMe = !_isNearMe;
                                      });
                                      _isNearMe
                                          ? _showProductsNotNearMe()
                                          : _showProductsNearMe();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: const Color(0xFFF2EE9D),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                    ),
                                    child: Text(
                                      _isNearMe
                                          ? '${titles['nearme']}'
                                          : '${titles['notnearme']}',
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ),
                              if (_isFetchingLocation)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Row(
                                    children: [
                                      Text('${titles['fetching']}'),
                                      const SizedBox(width: 8.0),
                                      const CircularProgressIndicator(
                                        backgroundColor: Color(0xFF557A46),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Color(0xFFF2EE9D)),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(
                                width: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            child: RefreshIndicator(
              onRefresh: _refreshProducts,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _filteredProducts.length + 1,
                      itemBuilder: (context, index) {
                        if (index < _filteredProducts.length) {
                          return ProductCard(product: _filteredProducts[index]);
                        } else {
                          // This is the indicator for loading more products
                          return _isLoading
                              ? Container(
                                  height: 50.0, // Set height as needed
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      backgroundColor: Color(0xFF557A46),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xFFF2EE9D)),
                                    ),
                                  ),
                                )
                              : Container(); // You can customize the loading indicator
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF557A46),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AddProductScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showMyProducts() {
    final user = supabase.auth.currentUser;
    email = user!.email!;
    _refreshProducts();
  }

  void _showAllProducts() {
    email = '';
    _refreshProducts();
  }

  void _showProductsNotNearMe() {
    city = '';
    state = '';
    _isNearMe = true;
    _refreshProducts();
  }

  Future<void> _showProductsNearMe() async {
    try {
      setState(() {
        _isLoading = true;
        // Set a flag to indicate fetching location
        _isFetchingLocation = true;
      });

      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      city = placemarks.first.locality ?? '';
      state = placemarks.first.administrativeArea ?? '';
      print("city : $city  state : $state");

      _refreshProducts();

      _isNearMe = false;
    } catch (e) {
      print('Error getting current location: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _isFetchingLocation = false; // Reset the fetching location flag
      });
    }
  }
}

class ProductSearchDelegate extends SearchDelegate<String> {
  final List<Product> products;

  ProductSearchDelegate(this.products);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final filteredProducts = products
        .where((product) =>
            product.product.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(filteredProducts[index].product),
          onTap: () {
            close(context, filteredProducts[index].product);
          },
        );
      },
    );
  }
}
