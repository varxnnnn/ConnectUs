import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CreateClubPage extends StatefulWidget {
  final String collegeCode;

  const CreateClubPage({Key? key, required this.collegeCode}) : super(key: key);

  @override
  _CreateClubPageState createState() => _CreateClubPageState();
}

class _CreateClubPageState extends State<CreateClubPage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _aimController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  bool _isCreating = false;
  String _selectedCategory = 'Dance'; // Default category
  XFile? _logoImage; // To hold the selected logo image

  final List<String> categories = [
    'Dance',
    'Singing',
    'Coding',
    'Sports',
    'Event Managing',
    'Culturals',
    'Arts',
    'Drama',
    'Music',
    'Debate',
  ];

  static const Color primaryColor = Color(0xFF1F2628);
  static const Color secondaryColor = Color(0xFFF9AA33);
  static const Color grayColor = Color(0xFF4A6572);
  static const Color darkColor = Colors.white;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _logoImage = pickedFile; // Store the selected image
    });
  }

  Future<void> _createClubRequest() async {
    if (_nameController.text.isEmpty || _aimController.text.isEmpty || _descriptionController.text.isEmpty || _logoImage == null) {
      Fluttertoast.showToast(msg: "Please fill all fields and select a logo", backgroundColor: Colors.red);
      return;
    }

    setState(() {
      _isCreating = true; // Set loading state to true
    });

    try {
      // Upload the image to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref();
      final logoRef = storageRef.child('club_logos/${_logoImage!.name}');
      await logoRef.putFile(File(_logoImage!.path));

      // Get the download URL of the uploaded image
      final logoUrl = await logoRef.getDownloadURL();

      // Get admin details from Firestore using adminId
      final adminDoc = await FirebaseFirestore.instance.collection('allUsers').doc(FirebaseAuth.instance.currentUser!.uid).get();

      if (adminDoc.exists) {
        var adminData = adminDoc.data()!;

        // Generate a unique ID for the club using Firestore's auto-generated document ID
        final clubRef = FirebaseFirestore.instance.collection('users')
            .doc(widget.collegeCode)
            .collection('clubRequests')
            .doc(); // Firestore auto-generates a document ID

        final clubId = clubRef.id; // Get the generated club ID

        // Add the club request to Firestore under the 'clubRequests' collection
        await clubRef.set({
          'clubId': clubId,  // Save the generated clubId
          'name': _nameController.text,
          'category': _selectedCategory,
          'aim': _aimController.text.isEmpty ? 'No aim provided' : _aimController.text, // Default to 'No aim provided' if empty
          'description': _descriptionController.text,
          'logoUrl': logoUrl, // Save the logo URL
          'adminId': FirebaseAuth.instance.currentUser!.uid,
          'adminName': adminData['name'], // Admin name from Firestore
          'adminProfilePic': adminData['profilePictureUrl'], // Admin profile picture from Firestore
          'adminRollNumber': adminData['rollNumber'], // Admin's roll number from Firestore
          'adminBranch': adminData['branch'], // Admin's branch from Firestore
          'createdAt': FieldValue.serverTimestamp(), // Timestamp when the request was created
        });

        Fluttertoast.showToast(msg: "Request sent to admin for approval!", backgroundColor: Colors.green);
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(msg: "Admin details not found", backgroundColor: Colors.red);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e", backgroundColor: Colors.red);
    } finally {
      setState(() {
        _isCreating = false; // Set loading state to false when done
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Club'),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Add space before inputs
              const SizedBox(height: 20),

              // Club Logo Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: grayColor),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      _logoImage != null ? _logoImage!.name : 'Select Club Logo',
                      style: TextStyle(color: _logoImage != null ? darkColor : grayColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Club Name Input
              _buildUnderlineTextField(_nameController, 'Club Name'),
              const SizedBox(height: 10),

              // Category Dropdown
              _buildCategoryDropdown(),
              const SizedBox(height: 10),

              // Aim Input
              _buildUnderlineTextField(_aimController, 'Aim'),
              const SizedBox(height: 10),

              // Description Input
              _buildUnderlineTextField(_descriptionController, 'Description', maxLines: 3),
              const SizedBox(height: 30),

              // Submit Button or Circular Progress Indicator
              _isCreating
                  ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(secondaryColor), // Set loading color to secondary
              ) // Show loading spinner when creating
                  : GestureDetector(
                onTap: _createClubRequest,
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: secondaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: const Text(
                      "Create Club",
                      style: TextStyle(
                        color: darkColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnderlineTextField(TextEditingController controller, String hintText, {int maxLines = 1, bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: grayColor),
        filled: true,
        fillColor: Colors.transparent,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: grayColor),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: secondaryColor, width: 2),
        ),
      ),
      style: const TextStyle(color: darkColor),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.transparent,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: grayColor),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: secondaryColor, width: 2),
        ),
      ),
      items: categories.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category, style: TextStyle(color: darkColor)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value!;
        });
      },
    );
  }
}
