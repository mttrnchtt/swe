import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String role; // User role: Farmer or Buyer
  const ProfilePage({required this.role});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // User personal information
  String name = "Ulana Zhussip";
  String email = "ulanazhusip@gmail.com";
  String phoneNumber = "+1234567890";
  String address = "Kabanbay 53, D10";
  String profilePicture = "assets/images/photo1.png";

  // Farms data for Farmers
  List<Map<String, String>> farms = [
    {
      "name": "Coldwind Farm",
      "size": "150 acres",
      "location": "Stepnogorsk",
      "crops": "Corn, Wheat"
    },
    {
      "name": "Green Valley",
      "size": "200 acres",
      "location": "Kokshetau",
      "crops": "Rice, Vegetables"
    },
  ];

  // Add or edit farm modal form
  void showFarmForm({Map<String, String>? farm}) {
    final nameController = TextEditingController(text: farm?['name'] ?? '');
    final sizeController = TextEditingController(text: farm?['size'] ?? '');
    final locationController =
        TextEditingController(text: farm?['location'] ?? '');
    final cropsController = TextEditingController(text: farm?['crops'] ?? '');

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16),
              Text(
                farm == null ? "Add New Farm" : "Edit Farm Info",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Farm Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: sizeController,
                decoration: InputDecoration(
                  labelText: "Farm Size",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: "Location",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: cropsController,
                decoration: InputDecoration(
                  labelText: "Crop Types",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (farm == null) {
                    // Add a new farm
                    setState(() {
                      farms.add({
                        "name": nameController.text,
                        "size": sizeController.text,
                        "location": locationController.text,
                        "crops": cropsController.text,
                      });
                    });
                  } else {
                    // Update existing farm
                    setState(() {
                      farm['name'] = nameController.text;
                      farm['size'] = sizeController.text;
                      farm['location'] = locationController.text;
                      farm['crops'] = cropsController.text;
                    });
                  }
                  Navigator.pop(context); // Close modal
                },
                child: Text(farm == null ? "Add Farm" : "Save Changes"),
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // Edit personal information form
  void showEditProfileForm() {
    final nameController = TextEditingController(text: name);
    final emailController = TextEditingController(text: email);
    final phoneController = TextEditingController(text: phoneNumber);
    final addressController = TextEditingController(text: address);

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16),
              Text(
                "Edit Personal Information",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: "Address",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    name = nameController.text;
                    email = emailController.text;
                    phoneNumber = phoneController.text;
                    address = addressController.text;
                  });
                  Navigator.pop(context); // Close modal
                },
                child: Text("Save Changes"),
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Profile",
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(profilePicture),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: showEditProfileForm,
                  child: Text("Edit Personal Information"),
                ),
              ),
              Divider(height: 40),
              // Farms Section for Farmers
              if (widget.role == 'Farmer')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "My Farms",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: farms.length,
                      itemBuilder: (context, index) {
                        final farm = farms[index];
                        return Card(
                          child: ListTile(
                            title: Text(farm['name']!),
                            subtitle: Text(
                                "Size: ${farm['size']}, Location: ${farm['location']}"),
                            trailing: IconButton(
                              icon: Icon(Icons.edit, color: Colors.green),
                              onPressed: () => showFarmForm(farm: farm),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => showFarmForm(),
                      child: Text("Add New Farm"),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
