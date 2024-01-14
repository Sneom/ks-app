class Product {
  final String id;
  final String name;
  final String product;
  final String email;
  final String city;
  final String state;
  final String description;
  final String date;
  final String price;
  final String tosell;
  final List<dynamic> images;

  Product(
      {required this.id,
      required this.name,
      required this.product,
      required this.email,
      required this.city,
      required this.state,
      required this.date,
      required this.tosell,
      required this.images,
      required this.description,
      required this.price});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
        id: json['id'],
        name: json['name'],
        product: json['product'],
        city: json['city'],
        state: json['state'],
        description: json['description'],
        price: json['price'],
        images: json['images'],
        date: json['created_at'],
        tosell: json['type'],
        email: json['email']);
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      product: map['product'] as String,
      description: map['description'] as String,
      price: map['price'] as String,
      tosell: map['type'] as String,
      name: map['name'] as String,
      date: map['created_at'],
      images: map['images'],
      city: map['city'] as String,
      state: map['state'] as String,
      email: map['email'] as String,
      id: map['id'] as String,
    );
  }
}
