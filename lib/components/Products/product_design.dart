import 'package:flutter/material.dart';
import 'package:kisan/components/Products/date_format.dart';
import 'package:kisan/components/Products/product_format.dart';
import 'package:kisan/main.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    String formattedDate = formatDate(product.date);

    return Card(
      elevation: 3,
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: Color(0xFFF2EE9D),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display Product Image here
            // Image.network(product.imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover),

            Text(
              product.product,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 8),
            Text(
              product.description,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Price: \₹${product.price}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              product.tosell ? 'Sell' : 'Rent per month',
              style: TextStyle(
                color: Colors.green,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Seller: ${product.name}",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Posted at: ${formattedDate}",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "${product.city}, ${product.state}",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),
            if (product.email != user?.email)
              ElevatedButton(
                onPressed: () {
                  // Implement buy button logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF557A46),
                  foregroundColor: Colors.white,
                  textStyle: TextStyle(fontSize: 16),
                ),
                child: Text('Buy Now'),
              ),
          ],
        ),
      ),
    );
  }
}
