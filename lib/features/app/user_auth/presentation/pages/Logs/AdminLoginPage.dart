import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../admin/AdminDashboardPage.dart';
import 'AddCollegePage.dart'; // Import AddCollegePage

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController _adminIdController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _isLoggingIn = false;

  String? _selectedCollegeCode; // Variable to hold selected college code
  final List<String> _collegeCodes = [
    'VGNT', 'CMR', 'GRRR', 'MGIT', 'SNITS', 'HOLY' // List of college codes
  ];

  static const Color primaryColor = Color(0xFF121111);
  static const Color secondaryColor = Color(0xFFF9AA33);
  static const Color grayColor = Color(0xFF7D7F88);
  static const Color darkColor = Colors.white;

  @override
  void dispose() {
    _adminIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Admin Login",
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: secondaryColor),
              ),
              const SizedBox(height: 30),
              _buildUnderlineTextField(_adminIdController, 'Admin ID'),
              const SizedBox(height: 10),
              _buildUnderlineTextField(_passwordController, 'Password', obscureText: true),
              const SizedBox(height: 10),
              _buildCollegeCodeDropdown(), // College code dropdown
              const SizedBox(height: 30),
              GestureDetector(
                onTap: _login,
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: secondaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: _isLoggingIn
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("I'm a student", style: TextStyle(color: grayColor)),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Back to Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Add College button
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddCollegePage()),
                  );
                },
                child: const Text(
                  "Add a College to Community",
                  style: TextStyle(color: secondaryColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnderlineTextField(TextEditingController controller, String hintText, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
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

  // Dropdown button for college code selection
  Widget _buildCollegeCodeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCollegeCode,
      onChanged: (String? newValue) {
        setState(() {
          _selectedCollegeCode = newValue;
        });
      },
      items: _collegeCodes.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: InputDecoration(
        hintText: 'Select College Code',
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
    );
  }

  void _login() async {
    setState(() {
      _isLoggingIn = true;
    });

    try {
      final String collegeCode = _selectedCollegeCode ?? ''; // Use selected college code
      final String adminId = _adminIdController.text;

      if (collegeCode.isEmpty) {
        _showToast(message: "Please select a college code.");
        return;
      }

      // Check Firestore for the admin credentials
      DocumentSnapshot<Map<String, dynamic>> adminSnapshot = await _firestore
          .collection('users')
          .doc(collegeCode)
          .collection('admin')
          .doc(adminId)
          .get();

      if (!adminSnapshot.exists) {
        _showToast(message: "Invalid Admin ID or College Code.");
        return;
      }

      final Map<String, dynamic>? adminData = adminSnapshot.data();
      if (adminData == null) {
        _showToast(message: "No data found for this admin.");
        return;
      }

      final String storedPassword = adminData['adminPassword'] ?? '';
      if (storedPassword.isEmpty) {
        _showToast(message: "Password not found.");
        return;
      }

      // Check if the password matches
      if (_passwordController.text != storedPassword) {
        _showToast(message: "Incorrect password.");
        return;
      }

      // Login successful
      _showToast(message: "Login successful!");

      // Save the college code and admin ID in shared_preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('collegeCode', collegeCode);
      await prefs.setString('adminId', adminId); // Optionally save the adminId too

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdminDashboardPage(
            collegeCode: collegeCode, // Pass the college code
            adminId: adminId, // Pass the adminId as well
          ),
        ),
      );
    } catch (e) {
      _showToast(message: "Error: $e");
    } finally {
      setState(() {
        _isLoggingIn = false;
      });
    }
  }

  void _showToast({required String message}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
