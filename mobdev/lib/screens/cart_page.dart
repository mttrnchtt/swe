import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CartPage extends StatefulWidget {
  final String accessToken; // Add accessToken parameter

  CartPage({required this.accessToken});
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Example Cart Items (mock data, can be replaced with database queries)
  List<Map<String, dynamic>> cartItems = [
    {'name': 'Apples', 'price': 27, 'quantity': 2},
    {'name': 'Cucumber', 'price': 19, 'quantity': 3}, // 1 kg of tomatoes
  ];

  static const double deliveryFee = 12.0; // Fixed delivery fee

  Future<void> addToCart(Map<String, dynamic> product, int quantity) async {
    try {
      // Debugging: Print the data before sending to the server
      print('Adding to cart:');
      print('Product ID: ${product['id']}');
      print('Quantity: $quantity');

      final response = await http.post(
        Uri.parse(
            'http://localhost:8000/marketplace/cart/'), // Your cart add endpoint
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'product_id': product['id'],
          'quantity': quantity,
        }),
      );

      // Debugging: Print the response status and body
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('Product added to cart');
        // Refresh the cart after adding
      } else {
        print('Failed to add product to cart: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product to cart')),
        );
      }
    } catch (e) {
      print('Error adding product to cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while adding to cart')),
      );
    }
  }

  // Calculate total price
  double calculateTotal() {
    double total = deliveryFee; // Start with the delivery fee
    for (var item in cartItems) {
      total += item['price'] * item['quantity'];
    }
    return total;
  }

  // Show confirmation bottom sheet
  void showConfirmationDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Confirm Purchase",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 16),
              Text(
                "Delivery Address:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("Kabanbay 53"), // Mock address
              Divider(),
              Text(
                "Total Payment:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("\$${calculateTotal().toStringAsFixed(2)}"),
              Divider(),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close bottom sheet
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      print("Purchase confirmed");
                      // Add purchase logic here (e.g., database entry)
                      setState(() {
                        cartItems.clear(); // Clear cart after purchase
                      });
                      Navigator.pop(context); // Close bottom sheet
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text("Confirm"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Shopping Cart",
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: cartItems.isEmpty
          ? Center(child: Text("Your cart is empty"))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(item['name']),
                            subtitle: Text(
                                "${item['quantity']} kg x \$${item['price']}"),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  cartItems.removeAt(index); // Remove item
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Delivery Fee:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("\$${deliveryFee.toStringAsFixed(2)}"),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        "\$${calculateTotal().toStringAsFixed(2)}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: showConfirmationDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text("Buy Now"),
                  ),
                ],
              ),
            ),
    );
  }
}
