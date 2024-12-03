import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  final String role;
  final String accessToken; // Add accessToken parameter

  ProfilePage({required this.role, required this.accessToken});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Personal information controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Farm information controllers
  final TextEditingController farmNameController = TextEditingController();
  final TextEditingController farmLocationController = TextEditingController();
  final TextEditingController farmDescriptionController =
      TextEditingController();

  bool isAddingFarm = false; // Track whether the user is adding a new farm
  List<dynamic> farms = []; // Store the list of farms

  @override
  void initState() {
    super.initState();
    fetchFarms(); // Fetch farms when the page loads
  }

  // Fetch farms from the backend
  Future<void> fetchFarms() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/farm/'), // Replace with your endpoint
        headers: {
          'Authorization':
              'Bearer ${widget.accessToken}', // Include accessToken
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          farms = jsonDecode(response.body); // Parse and store farms
        });
        print('Fetched Farms: $farms');
      } else {
        print('Failed to fetch farms: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch farms.')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while fetching farms.')),
      );
    }
  }

  // Save personal information using PUT request
  Future<void> savePersonalInfo() async {
    final personalInfo = {
      'username': usernameController.text,
      'phone': phoneController.text,
      if (widget.role == 'buyer') 'address': addressController.text,
    };

    try {
      final response = await http.put(
        Uri.parse(
            'http://localhost:8000/auth/profile/'), // Replace with your endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${widget.accessToken}', // Include accessToken
        },
        body: jsonEncode(personalInfo),
      );

      if (response.statusCode == 200) {
        print('Personal Info Updated: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Personal information updated successfully!')),
        );
      } else {
        print('Failed to update personal info: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update personal information.')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  // Save farm information using POST request
  Future<void> saveFarmInfo() async {
    final farmInfo = {
      'name': farmNameController.text,
      'location': farmLocationController.text,
      'description': farmDescriptionController.text,
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/farm/'), // Replace with your endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${widget.accessToken}', // Include accessToken
        },
        body: jsonEncode(farmInfo),
      );
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      if (response.statusCode == 201) {
        print('Farm Created: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Farm created successfully!')),
        );

        // Reset the farm form fields
        farmNameController.clear();
        farmLocationController.clear();
        farmDescriptionController.clear();

        setState(() {
          isAddingFarm = false; // Hide farm creation form
        });

        // Refresh the list of farms
        fetchFarms();
      } else {
        print('Failed to create farm: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create farm. Please try again.')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Personal Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
              ),
              if (widget.role == 'buyer') ...[
                SizedBox(height: 10),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: "Address",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: savePersonalInfo,
                child: Text("Save Personal Information"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.green,
                ),
              ),
              if (widget.role == 'farmer') ...[
                SizedBox(height: 20),
                Text(
                  "Your Farms",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: farms.length,
                  itemBuilder: (context, index) {
                    final farm = farms[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(farm['name']),
                        subtitle: Text(farm['location']),
                        trailing: Text(farm['description'] ?? ''),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
                if (!isAddingFarm) ...[
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isAddingFarm = true; // Show farm creation form
                      });
                    },
                    child: Text("Add New Farm"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.green,
                    ),
                  ),
                ] else ...[
                  TextField(
                    controller: farmNameController,
                    decoration: InputDecoration(
                      labelText: "Farm Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: farmLocationController,
                    decoration: InputDecoration(
                      labelText: "Farm Location",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: farmDescriptionController,
                    decoration: InputDecoration(
                      labelText: "Farm Description",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: saveFarmInfo,
                    child: Text("Save Farm Information"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.green,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isAddingFarm = false; // Hide farm creation form
                      });
                    },
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
