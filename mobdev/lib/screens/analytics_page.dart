import 'package:flutter/material.dart';

class AnalyticsPage extends StatefulWidget {
  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  // Example inventory data
  final List<Map<String, dynamic>> inventoryData = [
    {
      'product': 'Sweet Corn',
      'monthlyData': {
        '2023': {'January': 120, 'February': 100, 'March': 90},
        '2024': {'January': 110, 'February': 95, 'March': 85},
      },
      'inStock': true,
    },
    {
      'product': 'Cherry Tomatoes',
      'monthlyData': {
        '2023': {'January': 200, 'February': 150, 'March': 130},
        '2024': {'January': 180, 'February': 140, 'March': 120},
      },
      'inStock': true,
    },
    {
      'product': 'Blueberry',
      'monthlyData': {
        '2023': {'January': 0, 'February': 0, 'March': 0},
        '2024': {'January': 0, 'February': 0, 'March': 0},
      },
      'inStock': false,
    },
  ];

  String selectedYear = '2023'; // Default selected year
  String selectedMonth = 'January'; // Default selected month

  // List of years and months for dropdowns
  final List<String> years = ['2023', '2024'];
  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    // Filter inventory data based on selected year and month
    final filteredData = inventoryData.map((item) {
      final product = item['product'];
      final monthlyData = item['monthlyData'][selectedYear];
      final stock = monthlyData[selectedMonth] ?? 0;
      return {'product': product, 'stock': stock};
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Analytics",
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Year and Month",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                // Dropdown for Year
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedYear,
                    decoration: const InputDecoration(
                      labelText: "Year",
                      border: OutlineInputBorder(),
                    ),
                    items: years.map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedYear = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Dropdown for Month
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedMonth,
                    decoration: const InputDecoration(
                      labelText: "Month",
                      border: OutlineInputBorder(),
                    ),
                    items: months.map((month) {
                      return DropdownMenuItem(
                        value: month,
                        child: Text(month),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMonth = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Inventory for Selected Month",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredData.length,
                itemBuilder: (context, index) {
                  final item = filteredData[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['product'],
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            "${item['stock']} kg",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
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
    );
  }
}
