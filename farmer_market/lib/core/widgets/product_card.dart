import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String category;
  final String quantity;
  final String image;

  const ProductCard({
    required this.name,
    required this.price,
    required this.category,
    required this.quantity,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 2.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
            child: Image.asset(
              image,
              height: 100.0,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                  'Category: $category',
                  style: TextStyle(fontSize: 12.0, color: Colors.grey),
                ),
                Text(
                  'Quantity: $quantity',
                  style: TextStyle(fontSize: 12.0, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
