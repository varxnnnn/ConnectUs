import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../admin/AdminDashboardPage.dart';
import 'AddCollegePage.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _adminIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoggingIn = false;
  String? _selectedCollegeCode;
  List<String> _collegeCodes = [];

  @override
  void initState() {
    super.initState();
    _fetchCollegeCodes();
  }

  Future<void> _fetchCollegeCodes() async {
    try {
      DocumentSnapshot snapshot =
      await _firestore.collection('codes').doc('allCodes').get();
      if (snapshot.exists) {
        List<dynamic> codes = snapshot.get('collegeCodes') ?? [];
        setState(() {
          _collegeCodes = List<String>.from(codes);
        });
      }
    } catch (e) {
      _showToast(message: "Error fetching college codes: $e");
    }
  }

  @override
  void dispose() {
    _adminIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
  static const Color darktext = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: primaryGradient),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Admin Login",
                  style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor),
                ),
                const SizedBox(height: 30),
                _buildUnderlineTextField(_adminIdController, 'Admin ID'),
                const SizedBox(height: 10),
                _buildUnderlineTextField(_passwordController, 'Password',
                    obscureText: true),
                const SizedBox(height: 10),
                _buildCollegeCodeDropdown(),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: _login,
                  child: Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      color: primaryColor,
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
                    const Text("I'm a student !",
                        style: TextStyle(color: grayColor)),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Back to Login",
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddCollegePage()),
                    );
                  },
                  child: const Text(
                    "Add a College to Community",
                    style: TextStyle(
                        color: secondaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnderlineTextField(TextEditingController controller,
      String hintText, {bool obscureText = false}) {
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
          child: Text(value, style: const TextStyle(color: darktext)),
        );
      }).toList(),
      decoration: const InputDecoration(
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
      final String collegeCode = _selectedCollegeCode ?? '';
      final String adminId = _adminIdController.text;

      if (collegeCode.isEmpty) {
        _showToast(message: "Please select a college code.");
        return;
      }

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
      if (_passwordController.text != storedPassword) {
        _showToast(message: "Incorrect password.");
        return;
      }

      _showToast(message: "Login successful!");

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('collegeCode', collegeCode);
      await prefs.setString('adminId', adminId);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdminDashboardPage(
            collegeCode: collegeCode,
            adminId: adminId,
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
      backgroundColor: darkColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
