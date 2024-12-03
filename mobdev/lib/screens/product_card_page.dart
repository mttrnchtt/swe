import 'package:flutter/material.dart';

class ProductCardPage extends StatefulWidget {
  final Map<String, dynamic> productDetails;
  final String role; // Role: Farmer or Buyer

  const ProductCardPage({required this.productDetails, required this.role});

  @override
  _ProductCardPageState createState() => _ProductCardPageState();
}

class _ProductCardPageState extends State<ProductCardPage> {
  int selectedQuantity = 1; // Default quantity for buyers

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.productDetails['name'] ?? '', // Ensure key exists
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                Image.asset(
                  widget.productDetails['image'] ??
                      'assets/images/placeholder.png', // Add fallback image
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Information
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Farm",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(widget.productDetails['farm'] ?? ''),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Category",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(widget.productDetails['category'] ?? ''),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Price per kg",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(widget.productDetails['price'].toString() ?? ''),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Quantity",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(widget.productDetails['quantity'].toString() ?? ''),
                    ],
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "Description",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(widget.productDetails['description'] ?? ''),
                  SizedBox(height: 20),
                  // Action Buttons
                  if (widget.role == 'Farmer')
                    // Farmer-specific buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            print("Delete button tapped");
                            // Add delete product logic
                          },
                          icon: Icon(Icons.delete),
                          label: Text("Delete"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 245, 41, 106),
                            minimumSize: Size(120, 50),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            print("Edit button tapped");
                            // Add edit product logic
                          },
                          icon: Icon(Icons.edit),
                          label: Text("Edit"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 228, 228, 228),
                            minimumSize: Size(120, 50),
                          ),
                        ),
                      ],
                    )
                  else
                    // Buyer-specific actions
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Select Quantity (kg)",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (selectedQuantity > 1) {
                                  setState(() {
                                    selectedQuantity--;
                                  });
                                }
                              },
                              icon: Icon(Icons.remove_circle_outline),
                              color: Colors.green,
                            ),
                            Text(
                              "$selectedQuantity",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  selectedQuantity++;
                                });
                              },
                              icon: Icon(Icons.add_circle_outline),
                              color: Colors.green,
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Add product to cart logic
                            print(
                                "Added $selectedQuantity kg of ${widget.productDetails['name']} to the cart");

                            // Send data to the database (dummy for now)
                            /*
                              Database code here:
                              Example:
                              cart.add({
                                'product_id': widget.productDetails['id'],
                                'quantity': selectedQuantity,
                              });
                            */
                          },
                          icon: Icon(Icons.add_shopping_cart),
                          label: Text("Add to Cart"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: Size(double.infinity, 50),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
