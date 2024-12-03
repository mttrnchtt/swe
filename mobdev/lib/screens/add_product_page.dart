import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddProductPage extends StatefulWidget {
  final String accessToken;

  AddProductPage({required this.accessToken});

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  // Form controllers
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productPriceController = TextEditingController();
  final TextEditingController productQuantityController =
      TextEditingController();
  final TextEditingController productDescriptionController =
      TextEditingController();

  String? selectedFarm;
  List<dynamic> farms = [];

  String? selectedCategory;
  final List<String> categories = [
    'fruits',
    'vegetables',
    'dairy',
    'meat',
    'grains',
    'others',
  ];

  File? selectedImage;

  @override
  void initState() {
    super.initState();
    fetchFarms(); // Fetch farms when the page loads
  }

  // Fetch farms owned by the user
  Future<void> fetchFarms() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:8000/farm/'), // Change to your server IP if needed
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          farms = jsonDecode(response.body);
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

  // Select an image using ImagePicker
  Future<void> selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  // Save product using POST request with multipart/form-data
  Future<void> saveProduct() async {
    if (selectedFarm == null || selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    // Debug: Check the fields before making the request
    print('Product Name: ${productNameController.text}');
    print('Category: $selectedCategory');
    print('Price: ${productPriceController.text}');
    print('Quantity: ${productQuantityController.text}');
    print('Description: ${productDescriptionController.text}');
    print('Farm: $selectedFarm');

    try {
      final uri = Uri.parse('http://localhost:8000/farm/products/');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer ${widget.accessToken}'
        // Fields for product details
        ..fields['name'] = productNameController.text
        ..fields['category'] = selectedCategory!
        ..fields['price'] = productPriceController.text
        ..fields['quantity'] = productQuantityController.text
        ..fields['description'] = productDescriptionController.text
        ..fields['farm'] = selectedFarm!; // Sending farm name (not ID)

      // Attach the selected image if available (make it optional)
      if (selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image', // Backend expects 'image' for image upload (make sure the field name matches backend)
            selectedImage!.path,
          ),
        );
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        print('Product Created Successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product added successfully!')),
        );

        // Clear the form fields
        productNameController.clear();
        productPriceController.clear();
        productQuantityController.clear();
        productDescriptionController.clear();
        setState(() {
          selectedFarm = null;
          selectedCategory = null;
          selectedImage = null; // Clear image selection
        });
      } else {
        final responseBody = await response.stream.bytesToString();
        print('Failed to add product: $responseBody');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product. Please try again.')),
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
        title: Text("Add Product"),
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
                "Product Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedFarm,
                items: farms.map<DropdownMenuItem<String>>((farm) {
                  return DropdownMenuItem<String>(
                    value: farm['name'], // Sending farm name now
                    child: Text(farm['name']), // Display farm name
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedFarm = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Select Farm",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories.map<DropdownMenuItem<String>>((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Select Category",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: productNameController,
                decoration: InputDecoration(
                  labelText: "Product Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: productPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Price (e.g., 10.50)",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: productQuantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Quantity",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: productDescriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: selectImage,
                child: Text("Select Image (Optional)"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.blue,
                ),
              ),
              if (selectedImage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Selected Image: ${selectedImage!.path}"),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveProduct,
                child: Text("Add Product"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
