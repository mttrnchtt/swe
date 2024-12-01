import 'package:flutter/material.dart';

class OrdersPage extends StatelessWidget {
  final String role; // Role: Farmer or Buyer

  OrdersPage({required this.role});

  // Dummy data for orders
  final List<Map<String, dynamic>> orders = [
    {
      'id': 1,
      'product': 'Corn',
      'price': '15\$',
      'category': 'Vegetables',
      'quantity': '200 kg',
      'deliveryFee': '5\$',
      'address': 'Kabanbay 53, D10',
      'status': 'Pending', // Status: Pending, Ongoing, Completed
      'buyer': 'Ulana Z',
      'contact': '+1234567890',
      'image': 'assets/images/corn.jpeg',
    },
    {
      'id': 2,
      'product': 'Tomatoes',
      'price': '25\$',
      'category': 'Fruits',
      'quantity': '130 kg',
      'deliveryFee': '7\$',
      'address': 'Uly Dala 47',
      'status': 'Ongoing',
      'buyer': 'Aa Bb',
      'contact': '+0987654321',
      'image': 'assets/images/tomatoes.jpg',
    },
    {
      'id': 3,
      'product': 'Processed Wheat',
      'price': '16\$',
      'category': 'Wheat',
      'quantity': '500 kg',
      'deliveryFee': '10\$',
      'address': 'Mangilihk 6',
      'status': 'Completed',
      'buyer': 'John Aa',
      'contact': '+1122334455',
      'image': 'assets/images/wheat.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: Current and Completed
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: Text(
            "Orders",
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.green,
            tabs: [
              Tab(text: "Current"),
              Tab(text: "Completed"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Current Orders Tab
            ListView(
              children: orders
                  .where((order) =>
                      (role == 'Farmer' && order['status'] != 'Completed') ||
                      (role == 'Buyer' && order['status'] != 'Completed'))
                  .map((order) => OrderCard(order: order, role: role))
                  .toList(),
            ),
            // Completed Orders Tab
            ListView(
              children: orders
                  .where((order) => order['status'] == 'Completed')
                  .map((order) => OrderCard(order: order, role: role))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final String role;

  OrderCard({required this.order, required this.role});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    order['image'],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['product'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Category: ${order['category']}",
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Quantity: ${order['quantity']}",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Text(
                  order['price'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            role == 'Farmer'
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Buyer: ${order['buyer']}",
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        "Contact: ${order['contact']}",
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        "Delivery Address: ${order['address']}",
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      order['status'] == 'Pending'
                          ? Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Decline Order Logic
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  child: Text("Decline"),
                                ),
                                SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    // Accept Order Logic
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green),
                                  child: Text("Proceed"),
                                ),
                              ],
                            )
                          : order['status'] == 'Ongoing'
                              ? ElevatedButton(
                                  onPressed: () {
                                    // Track Order Logic
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green),
                                  child: Text("Track"),
                                )
                              : Container(),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Delivery Address: ${order['address']}",
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      order['status'] == 'Completed'
                          ? ElevatedButton(
                              onPressed: () {
                                // Show Receipt Logic
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              child: Text("Show the receipt"),
                            )
                          : Container(),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
