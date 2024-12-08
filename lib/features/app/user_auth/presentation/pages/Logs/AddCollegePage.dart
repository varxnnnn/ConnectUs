import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddCollegePage extends StatefulWidget {
  const AddCollegePage({super.key});

  @override
  State<AddCollegePage> createState() => _AddCollegePageState();
}

class _AddCollegePageState extends State<AddCollegePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController _collegeNameController = TextEditingController();
  final TextEditingController _collegeCodeController = TextEditingController();
  final TextEditingController _adminIdController = TextEditingController();
  final TextEditingController _adminPasswordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  bool _isSaving = false;
  File? _logoFile;
  String? _logoUrl;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF041A2E),
      Color(0xFF193356),
      Color(0xFF041D33),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.1, 0.7, 1.0],
  );

  static const Color primaryColor = Color(0xFF0D6EC5);
  static const Color secondaryColor = Color(0xFF86B2D8);
  static const Color grayColor = Color(0xFFE9ECED);
  static const Color darkColor = Colors.white;

  @override
  void dispose() {
    _collegeNameController.dispose();
    _collegeCodeController.dispose();
    _adminIdController.dispose();
    _adminPasswordController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity, // Ensure the container takes full width
          height: MediaQuery.of(context).size.height, // Full height
          decoration: BoxDecoration(
            gradient: primaryGradient, // Gradient background
            image: DecorationImage(
              image: AssetImage("assets/your_background_image.png"), // Optional: Add a custom background image
              fit: BoxFit.cover, // Cover the full page
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Add College to Community!",
                    style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: secondaryColor),
                  ),
                  const SizedBox(height: 40),
                  // Add Logo text
                  const Text(
                    "Add Logo",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkColor),
                  ),
                  const SizedBox(height: 10),
                  // College logo picker
                  GestureDetector(
                    onTap: _pickLogo,
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: grayColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _logoFile == null
                          ? const Icon(Icons.add_a_photo, color: primaryColor)
                          : Image.file(
                        _logoFile!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildUnderlineTextField(_collegeNameController, 'College Name'),
                  const SizedBox(height: 10),
                  _buildUnderlineTextField(_collegeCodeController, 'College Code'),
                  const SizedBox(height: 10),
                  _buildUnderlineTextField(_adminIdController, 'Admin ID'),
                  const SizedBox(height: 10),
                  _buildUnderlineTextField(_adminPasswordController,
                      'Admin Password',
                      obscureText: true),
                  const SizedBox(height: 10),
                  _buildUnderlineTextField(_emailController, 'Email'),
                  const SizedBox(height: 10),
                  _buildUnderlineTextField(_bioController, 'Bio'),
                  const SizedBox(height: 60),
                  GestureDetector(
                    onTap: _saveCollege,
                    child: Container(
                      width: double.infinity,
                      height: 45,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: _isSaving
                            ? const CircularProgressIndicator(color: darkColor)
                            : const Text(
                          "Create",
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
        ),
      ),
    );
  }

  Widget _buildUnderlineTextField(TextEditingController controller,
      String hintText,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: grayColor),
        filled: true,
        fillColor: Colors.transparent,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: grayColor),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: secondaryColor, width: 2),
        ),
      ),
      style: const TextStyle(color: darkColor),
    );
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _logoFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveCollege() async {
    final String collegeName = _collegeNameController.text;
    final String collegeCode = _collegeCodeController.text.toUpperCase();
    final String adminId = _adminIdController.text;
    final String adminPassword = _adminPasswordController.text;
    final String email = _emailController.text;
    final String bio = _bioController.text;

    if (collegeName.isEmpty ||
        collegeCode.isEmpty ||
        adminId.isEmpty ||
        adminPassword.isEmpty ||
        _logoFile == null ||
        email.isEmpty ||
        bio.isEmpty) {
      _showToast(message: "All fields and logo are required.");
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Ensure that the logo file is selected
      if (_logoFile == null) {
        _showToast(message: "Please select a logo image.");
        return;
      }

      // Upload logo to Firebase Storage
      final storageRef =
      _storage.ref().child('college_logos').child('$collegeCode.jpg');
      await storageRef.putFile(_logoFile!); // Upload the logo file
      _logoUrl = await storageRef.getDownloadURL(); // Get the URL of the logo

      // Save college data to Firestore
      await _firestore
          .collection('users')
          .doc(collegeCode)
          .collection('admin')
          .doc(adminId)
          .set({
        'collegeName': collegeName,
        'collegeCode': collegeCode,
        'adminId': adminId,
        'adminPassword': adminPassword,
        'logoUrl': _logoUrl,
        'email': email,
        'bio': bio,
      });

      // Update the 'collegeCodes' array in Firestore
      await _firestore.collection('codes').doc('allCodes').update({
        'collegeCodes': FieldValue.arrayUnion([collegeCode]),
      });

      _showToast(message: "College added successfully!");
      Navigator.pop(context);

      // Clear fields and reset logo
      _collegeNameController.clear();
      _collegeCodeController.clear();
      _adminIdController.clear();
      _adminPasswordController.clear();
      _emailController.clear();
      _bioController.clear();
      setState(() {
        _logoFile = null;
      });
    } catch (e) {
      _showToast(message: "Error: $e");
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showToast({required String message}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: primaryColor,
      textColor: darkColor,
      fontSize: 16.0,
    );
  }
}
