import 'package:flutter/material.dart';
import 'product_card_page.dart';
import 'add_product_page.dart';
import 'navbar.dart';
import 'orders_page.dart';
import 'profile_page.dart';
import 'cart_page.dart';
import 'analytics_page.dart';
import 'chat_page.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;
  late String role; // Declare role

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve the role passed from the login screen
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null && args is String) {
      role = args; // Assign the role passed from the login screen
    } else {
      role = 'farmer'; // Default role in case role is not passed
    }
    print('User Role in didChangeDependencies: $role');
  }

  // Example products
  final List<Map<String, String>> allProducts = [
    {
      'name': 'Sweet corn',
      'price': '15',
      'category': 'Vegetables',
      'quantity': '150 kg',
      'farm': 'Coldwind Farm',
      'image': 'assets/images/corn.jpeg',
    },
    {
      'name': 'Cherry tomatoes',
      'price': '25',
      'category': 'Vegetables',
      'quantity': '210 kg',
      'farm': 'Coldwind Farm',
      'image': 'assets/images/tomatoes.jpg',
    },
    {
      'name': 'Blueberry',
      'price': '48',
      'category': 'Fruits',
      'quantity': '78 kg',
      'farm': 'Stepnogorsk',
      'availability': 'In stock',
      'image': 'assets/images/blueberry.jpg',
    },
    {
      'name': 'Processed Wheat',
      'price': '16',
      'category': 'Wheat',
      'quantity': '120 kg',
      'farm': 'Kokshetau',
      'availability': 'In stock',
      'image': 'assets/images/wheat.jpg',
    },
  ];

  List<Map<String, String>> filteredProducts = [];
  String searchQuery = "";
  String selectedCategory = "All";
  String selectedFarm = "All";
  double minPrice = 0;
  double maxPrice = 50;
  String sortOrder = "Cheap first";

  @override
  void initState() {
    super.initState();
    filteredProducts = allProducts; // Initially show all products
  }

  // Search products by name
  void searchProducts(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filterAndSortProducts();
    });
  }

  // Filter and sort products
  void filterAndSortProducts() {
    setState(() {
      filteredProducts = allProducts.where((product) {
        final productName = product['name']!.toLowerCase();
        final matchesSearch = productName.contains(searchQuery);

        // Check category filter
        final matchesCategory = selectedCategory == "All" ||
            product['category'] == selectedCategory;

        // Check farm filter
        final matchesFarm =
            selectedFarm == "All" || product['farm'] == selectedFarm;

        // Check price range filter
        final productPrice = double.tryParse(
              product['price']!.replaceAll('\$', ''), // Remove "$"
            ) ??
            0;
        final matchesPrice =
            productPrice >= minPrice && productPrice <= maxPrice;

        return matchesSearch && matchesCategory && matchesFarm && matchesPrice;
      }).toList();

      // Apply sorting
      if (sortOrder == "Cheap first") {
        filteredProducts.sort((a, b) {
          final priceA = double.tryParse(a['price']!.replaceAll('\$', '')) ?? 0;
          final priceB = double.tryParse(b['price']!.replaceAll('\$', '')) ?? 0;
          return priceA.compareTo(priceB);
        });
      } else if (sortOrder == "Expensive first") {
        filteredProducts.sort((a, b) {
          final priceA = double.tryParse(a['price']!.replaceAll('\$', '')) ?? 0;
          final priceB = double.tryParse(b['price']!.replaceAll('\$', '')) ?? 0;
          return priceB.compareTo(priceA);
        });
      }
    });
  }

  // Show filters modal
  void showFilters() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sort by
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Sort by"),
                  DropdownButton<String>(
                    value: sortOrder,
                    items: ["Cheap first", "Expensive first"].map((option) {
                      return DropdownMenuItem(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        sortOrder = value!;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Categories filter
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: "Categories",
                  border: OutlineInputBorder(),
                ),
                items: ["All", "Vegetables", "Fruits", "Wheat", "Seeds", "Rice"]
                    .map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              // Farm filter
              DropdownButtonFormField<String>(
                value: selectedFarm,
                decoration: InputDecoration(
                  labelText: "Farms",
                  border: OutlineInputBorder(),
                ),
                items: ["All", "Coldwind Farm", "Kokshetau", "Stepnogorsk"]
                    .map((farm) {
                  return DropdownMenuItem(
                    value: farm,
                    child: Text(farm),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedFarm = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              // Price range filter
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Price range"),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      // Min Price Input
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Min Price",
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              minPrice = double.tryParse(value) ?? 0;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      // Max Price Input
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Max Price",
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              maxPrice = double.tryParse(value) ?? 100;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Apply Filters Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the modal
                    },
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      filterAndSortProducts(); // Apply filters
                      Navigator.pop(context); // Close the modal
                    },
                    child: Text(
                      "Apply",
                      style: TextStyle(color: Colors.green),
                    ),
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
    // Retrieve the role passed from the login screen
    final role =
        ModalRoute.of(context)!.settings.arguments as String? ?? 'farmer';
    print('User Role in build: $role');

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
                  onPressed: showFilters,
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
              child: filteredProducts.isEmpty
                  ? Center(child: Text("No products found"))
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 3 / 4,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductCardPage(
                                  productDetails: product,
                                  role: role,
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
                                    child: Image.asset(
                                      product['image']!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
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
                                        "\$${product['price']}",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 4),
                                      Text(product['name']!,
                                          style: TextStyle(fontSize: 14)),
                                      SizedBox(height: 4),
                                      Text(
                                        "Farm: ${product['farm']}",
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
                    builder: (context) => AddProductPage(),
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
            // Home
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
                  builder: (context) => CartPage(),
                ),
              );
            }
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(role: role),
              ),
            );
          }
        },
        role: role,
      ),
    );
  }
}
