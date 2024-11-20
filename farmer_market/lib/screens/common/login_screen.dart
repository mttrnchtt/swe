import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Top Image
          Image.asset(
            'assets/images/farm.jpg',
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Hardcoded Authentication Logic
                      final username = usernameController.text.trim();
                      final password = passwordController.text.trim();

                      if (username == 'farmer01' &&
                          password == 'farmer12345!') {
                        Navigator.pushNamed(context, '/farmer/dashboard');
                      } else if (username == 'buyer01' &&
                          password == 'buyer12345!') {
                        Navigator.pushNamed(context, '/buyer/dashboard');
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Invalid Credentials'),
                            content: Text('Incorrect username or password.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text('Continue'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text('Don’t have an account? Sign up'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
