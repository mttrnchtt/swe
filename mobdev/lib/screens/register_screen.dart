import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String role = 'Buyer'; // Default role selection
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController farmAddressController = TextEditingController();
  final TextEditingController farmSizeController = TextEditingController();
  List<String> selectedCrops = [];
  final List<String> cropsOptions = [
    'Rice',
    'Wheat',
    'Vegetables',
    'Fruits',
    'Seeds'
  ];

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image Header
            Stack(
              children: [
                Image.asset(
                  'assets/images/background.jpeg', // Replace with your asset path
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 40,
                  left: 20,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Back", style: TextStyle(color: Colors.white)),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: TextButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (role == 'Farmer') {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("Registration Pending"),
                              content: Text(
                                  "Your registration is pending admin's approval."),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("OK"),
                                ),
                              ],
                            ),
                          );
                        } else {
                          Navigator.pushNamed(context, '/dashboard');
                        }
                      }
                    },
                    child: Text("Next", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Role Selection
                    Text("Select Role",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text("Buyer"),
                            value: "Buyer",
                            groupValue: role,
                            onChanged: (value) {
                              setState(() {
                                role = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text("Farmer"),
                            value: "Farmer",
                            groupValue: role,
                            onChanged: (value) {
                              setState(() {
                                role = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: usernameController,
                      decoration: InputDecoration(labelText: "Username"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a username';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: "Email"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email';
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                            .hasMatch(value)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(labelText: "Phone Number"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a phone number';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(labelText: "Password"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        } else if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration:
                          InputDecoration(labelText: "Confirm Password"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        } else if (value != passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    if (role == 'Farmer') ...[
                      TextFormField(
                        controller: farmAddressController,
                        decoration: InputDecoration(labelText: "Farm Address"),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your farm address';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: farmSizeController,
                        decoration: InputDecoration(labelText: "Farm Size"),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your farm size';
                          }
                          return null;
                        },
                      ),
                      // Crop Selection
                      Text("Crops",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 8.0,
                        children: cropsOptions.map((crop) {
                          return FilterChip(
                            label: Text(crop),
                            selected: selectedCrops.contains(crop),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedCrops.add(crop);
                                } else {
                                  selectedCrops.remove(crop);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: true,
                          onChanged: (value) {},
                        ),
                        Expanded(
                          child: Text(
                            "I have read and agree with the Terms and Conditions",
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
