import 'package:flutter/material.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/navbar.dart';

class FarmerDashboardScreen extends StatefulWidget {
  @override
  _FarmerDashboardScreenState createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  int _currentIndex = 0;

  final List<Map<String, String>> products = [
    {
      'name': 'Sweet corn',
      'price': '15\$',
      'category': 'Vegetables',
      'quantity': '130 kg',
      'image': 'assets/images/corn.jpeg',
    },
    {
      'name': 'Cherry tomatoes',
      'price': '25\$',
      'category': 'Fruits',
      'quantity': '130 kg',
      'image': 'assets/images/tomatoes.jpg',
    },
    {
      'name': 'Williams apples',
      'price': '12\$',
      'category': 'Fruits',
      'quantity': '130 kg',
      'image': 'assets/images/apples.jpg',
    },
    {
      'name': 'Wild blueberry',
      'price': '58\$',
      'category': 'Fruits',
      'quantity': '130 kg',
      'image': 'assets/images/blueberry.jpg',
    },
    {
      'name': 'Orange',
      'price': '10\$',
      'category': 'Fruits',
      'quantity': '130 kg',
      'image': 'assets/images/orange.jpg',
    },
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Add navigation logic based on the index
    if (index == 1) {
      // Navigate to orders
    } else if (index == 2) {
      // Navigate to messages
    } else if (index == 3) {
      // Navigate to notifications
    } else if (index == 4) {
      // Navigate to analytics
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Farmer Market System',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.green),
            onPressed: () {
              // Handle filter action
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            Container(
              margin: EdgeInsets.only(bottom: 16.0),
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),

            // Product Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 items per row
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.75, // Adjust card height
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(
                    name: product['name']!,
                    price: product['price']!,
                    category: product['category']!,
                    quantity: product['quantity']!,
                    image: product['image']!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Handle add listing
        },
        backgroundColor: Colors.green,
        label: Text('Add listing'),
        icon: Icon(Icons.add),
      ),
      bottomNavigationBar: Navbar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
