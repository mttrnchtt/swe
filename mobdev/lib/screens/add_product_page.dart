import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String selectedCategory = 'Vegetables'; // Default category
  String availabilityStatus = 'In stock'; // Default availability
  List<File> images = []; // List to store selected image files

  // Categories and availability options
  final List<String> categories = ['Vegetables', 'Fruits', 'Grains', 'Meat'];
  final List<String> availabilityOptions = ['In stock', 'Out of stock'];

  // Function to pick images from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        images.add(File(pickedImage.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Example: Sending data to the database or API
                  final newProduct = {
                    'name': productNameController.text,
                    'category': selectedCategory,
                    'price': priceController.text,
                    'quantity': quantityController.text,
                    'description': descriptionController.text,
                    'availability': availabilityStatus,
                    'images': images
                        .map((image) => image.path)
                        .toList(), // Paths to selected images
                  };

                  print("Sending data to the database: $newProduct");

                  // Simulate sending data to an API (replace with actual API call)
                  // Example:
                  // await sendProductToDatabase(newProduct);
                }
              },
              child: Text("Add", style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Picker
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        // Show dialog to choose between Camera and Gallery
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return SafeArea(
                              child: Wrap(
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.camera_alt),
                                    title: Text('Take a Photo'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      _pickImage(ImageSource.camera);
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.photo),
                                    title: Text('Choose from Gallery'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      _pickImage(ImageSource.gallery);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.add, size: 30),
                      ),
                    ),
                    SizedBox(width: 8),
                    ...images.map(
                      (image) => Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(right: 8),
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: FileImage(
                                    image), // Use FileImage for File objects
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  images.remove(image);
                                });
                              },
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.black.withOpacity(0.5),
                                child: Icon(Icons.close,
                                    size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Product Name
                TextFormField(
                  controller: productNameController,
                  decoration: InputDecoration(
                    labelText: "Product name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a product name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Category
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((category) {
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
                // Price
                TextFormField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: "Price per kg",
                    prefixText: '\$',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Quantity
                TextFormField(
                  controller: quantityController,
                  decoration: InputDecoration(
                    labelText: "Quantity",
                    suffixText: 'kg',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a quantity';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Description
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Availability
                DropdownButtonFormField<String>(
                  value: availabilityStatus,
                  decoration: InputDecoration(
                    labelText: "Availability",
                    border: OutlineInputBorder(),
                  ),
                  items: availabilityOptions.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      availabilityStatus = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
