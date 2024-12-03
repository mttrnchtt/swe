import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String role = 'buyer'; // Default role selection
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'username': usernameController.text,
      'email': emailController.text,
      'phone_number': phoneController.text,
      'password': passwordController.text,
      'role': role, // Either "buyer" or "farmer"
      if (role == 'buyer') 'address': addressController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(
            'http://127.0.0.1:8000/auth/register/'), // Replace with your actual backend endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      // Print the entire response
      print('Response: ${response.body}');
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> userData = jsonDecode(response.body);

        // Safely handle response data
        final username = userData['username'] ?? 'Unknown';
        final email = userData['email'] ?? 'No email provided';

        print('Username: $username');
        print('Email: $email');

        // Display success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration Successful!')),
        );

        // Navigate to the dashboard or show email verification instructions
        if (role == 'farmer') {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Registration Pending"),
              content: Text("Your registration is pending admin's approval."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                ),
              ],
            ),
          );
        } else {
          Navigator.pushNamed(context, '/dashboard'); // Navigate to dashboard
        }
      } else {
        // Print error response data
        final Map<String, dynamic> errorResponse = jsonDecode(response.body);
        print('Error Response: $errorResponse');

        // Safely handle error response
        final errorDetail = errorResponse['detail'] ?? 'Unknown error';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorDetail')),
        );
      }
    } catch (e) {
      // Handle network or other errors
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the login page
          },
        ),
        title: Text(
          'Register',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                        value: "buyer",
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
                        value: "farmer",
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
                // Form Fields
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: "Username"),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter a username';
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
                    if (value == null || value.isEmpty)
                      return 'Please enter a phone number';
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
                  decoration: InputDecoration(labelText: "Confirm Password"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    } else if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                if (role == 'buyer')
                  TextFormField(
                    controller: addressController,
                    decoration: InputDecoration(labelText: "Address"),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter your address';
                      return null;
                    },
                  ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: registerUser,
                  child: Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
