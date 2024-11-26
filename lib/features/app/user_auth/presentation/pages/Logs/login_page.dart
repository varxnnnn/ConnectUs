import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../mainScreen.dart';
import 'AdminLoginPage.dart';
import 'sign_up_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _rollNumberController = TextEditingController();

  bool _isLoggingIn = false;

  static const Color primaryColor = Color(0xFF1F2628);
  static const Color secondaryColor = Color(0xFFF9AA33);
  static const Color grayColor = Color(0xFF4A6572);
  static const Color darkColor = Colors.white;

  // List of College Codes
  final List<String> collegeCodes = [
    'VGNT', 'MGIT', 'HOLY', 'SNITS', 'GRRR', 'CMR'
  ];

  String? selectedCollegeCode;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _rollNumberController.dispose();
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
                "Login",
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: secondaryColor),
              ),
              const SizedBox(height: 30),
              _buildUnderlineTextField(_emailController, 'Email'),
              const SizedBox(height: 10),
              _buildUnderlineTextField(_passwordController, 'Password', obscureText: true),
              const SizedBox(height: 10),
              _buildCollegeCodeDropdown(),
              const SizedBox(height: 10),
              _buildUnderlineTextField(_rollNumberController, 'Roll Number'),
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
              const SizedBox(height: 20),
              _buildFooterText(
                "Don't have an account?",
                "Sign Up",
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage())),
              ),
              const SizedBox(height: 20),
              _buildFooterText(
                "Are you an admin?",
                "Admin Login",
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminLoginPage())),
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

  Widget _buildCollegeCodeDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedCollegeCode,
      hint: Text(
        'Select College Code',
        style: TextStyle(color: grayColor),
      ),
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
      items: collegeCodes.map((String code) {
        return DropdownMenuItem<String>(
          value: code,
          child: Text(code, style: TextStyle(color: darkColor)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedCollegeCode = value;
        });
      },
    );
  }

  Widget _buildFooterText(String prefixText, String actionText, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(prefixText, style: const TextStyle(color: grayColor)),
        const SizedBox(width: 5),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionText,
            style: const TextStyle(
              color: Colors.white, // Change to white
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _login() async {
    setState(() {
      _isLoggingIn = true;
    });

    try {
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      final String collegeCode = selectedCollegeCode ?? '';
      final String rollNumber = _rollNumberController.text;

      DocumentSnapshot<Map<String, dynamic>> studentSnapshot = await _firestore
          .collection('users')
          .doc(collegeCode)
          .collection('students')
          .doc(rollNumber)
          .get();

      if (!studentSnapshot.exists) {
        _showToast(message: "Invalid college code or roll number.");
        await _firebaseAuth.signOut();
        return;
      }

      final Map<String, dynamic> studentData = studentSnapshot.data()!;
      final String registeredEmail = studentData['email'];

      if (registeredEmail != _emailController.text) {
        _showToast(message: "Email does not match.");
        await _firebaseAuth.signOut();
        return;
      }

      _showToast(message: "Login successful!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
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
