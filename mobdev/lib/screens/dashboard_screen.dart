import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Import your other pages here
import 'product_card_page.dart';
import 'add_product_page.dart';
import 'navbar.dart';
import 'orders_page.dart';
import 'profile_page.dart';
import 'cart_page.dart';
import 'analytics_page.dart';
import 'chat_page.dart';
import 'navbar.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;
  late String role; // Declare role
  late String accessToken;

  List<Map<String, dynamic>> products = []; // List to store products

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    role = args['role'];
    accessToken = args['accessToken'];

    fetchProducts(); // Fetch products when the dashboard loads
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:8000/marketplace/products/'), // Adjust the URL
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          products = responseData.cast<Map<String, dynamic>>();
        });
        //print('Fetched Products: $products');
      } else {
        print('Failed to fetch products: ${response.body}');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  // Search products by name
  void searchProducts(String query) {
    setState(() {
      query = query.toLowerCase();
      products = products.where((product) {
        return product['name'].toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Filter Products"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add filtering options here
                Text("Category:"),
                TextField(
                  decoration: InputDecoration(hintText: "Enter category"),
                  onChanged: (value) {
                    // Update category filter logic
                  },
                ),
                SizedBox(height: 10),
                Text("Price Range:"),
                Row(
                  children: [
                    Text("Min Price:"),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(hintText: "Min price"),
                        onChanged: (value) {
                          // Update price filter logic
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text("Max Price:"),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(hintText: "Max price"),
                        onChanged: (value) {
                          // Update price filter logic
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // You can perform the filtering logic here
                Navigator.pop(context);
              },
              child: Text("Apply Filter"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the filter dialog
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Farmer Market System",
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.filter_alt),
                  onPressed: () {
                    _showFilterDialog(context);
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: searchProducts,
            ),
            SizedBox(height: 20),
            // Product List
            Expanded(
              child: products.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 3 / 4,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final productName = product['name'] ??
                            'No Name'; // Provide default value
                        final productPrice =
                            product['price'] ?? '0.0'; // Providez default price
                        final productFarm =
                            product['farm'] ?? 'Unknown Farm'; // Default farm
                        final productImage = product['image'] ??
                            ''; // Default image or empty string

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductCardPage(
                                  productDetails: product,
                                  role: role,
                                  //accessToken: accessToken,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(8.0),
                                    ),
                                    child: productImage.isNotEmpty
                                        ? Image.network(
                                            productImage,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Icon(Icons.broken_image,
                                                  size: 50);
                                            },
                                          )
                                        : Container(
                                            color: Colors.grey,
                                            child: Center(
                                              child: Icon(
                                                  Icons.image_not_supported,
                                                  size: 50),
                                            ),
                                          ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "\$${productPrice}",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        productName,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Farm: $productFarm",
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: role == 'farmer'
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddProductPage(
                      accessToken: accessToken,
                    ),
                  ),
                );
              },
              backgroundColor: Colors.green,
              child: Icon(Icons.add),
              tooltip: "Add Product",
            )
          : null,
      bottomNavigationBar: CustomNavbar(
        selectedIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });

          // Navigation logic for each tab
          if (index == 0) {
            // Home - No action needed here as we're already on home
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  chatId: 'buyer123_farmer456',
                  userId: 'buyer123',
                  receiverId: 'farmer456',
                ),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrdersPage(role: role),
              ),
            );
          } else if (index == 3) {
            if (role == 'farmer') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnalyticsPage(),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(
                    accessToken: accessToken,
                  ),
                ),
              );
            }
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(
                  role: role,
                  accessToken: accessToken, // Pass the access token here
                ),
              ),
            );
          }
        },
        role: role,
      ),
    );
  }
}
