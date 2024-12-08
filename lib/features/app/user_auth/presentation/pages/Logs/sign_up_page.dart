import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rollNumberController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isSigningUp = false;
  File? _profileImage;
  String _profileImageUrl = '';

  String? selectedCollegeCode;
  String? selectedBranch;

  List<String> collegeCodes = [];
  List<String> branches = ['CSE','AIML','DS','MECH','CIVIL','IT','ECE'];

  static const Color primaryColor = Color(0xFF0D6EC5);
  static const Color secondaryColor = Color(0xFF86B2D8);
  static const Color grayColor = Color(0xFFE9ECED);
  static const Color darkColor = Colors.white;
  static const Color darktext = Colors.white;


  @override
  void initState() {
    super.initState();
    _fetchCollegeCodes();
  }

  Future<void> _fetchCollegeCodes() async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('codes')
          .doc('allCodes')
          .get();
      if (snapshot.exists) {
        List<dynamic> codes = snapshot.get('collegeCodes') ?? [];
        setState(() {
          collegeCodes = List<String>.from(codes);
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error fetching college codes: $e');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _rollNumberController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF041A2E), // Dark blue
              Color(0xFF193356), // Deep blue/teal
              Color(0xFF041D33),  // Dark blue
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.1, 0.7, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Sign Up Page",
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: Colors.white), // Light secondary color
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage:
                    _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null
                        ? const Icon(Icons.camera_alt, size: 30)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Personal Info",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: secondaryColor),
                ),
                const SizedBox(height: 10),
                _buildUnderlineTextField(_usernameController, 'Username'),
                const SizedBox(height: 10),
                _buildUnderlineTextField(_bioController, 'Bio'),
                const SizedBox(height: 10),
                _buildUnderlineTextField(_locationController, 'Location'),

                const SizedBox(height: 20),
                const Text(
                  "College Info",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: secondaryColor),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
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
                      child: Text(code, style: TextStyle(color: darktext)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCollegeCode = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedBranch,
                  hint: Text(
                    'Select Branch',
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
                  items: branches.map((String branch) {
                    return DropdownMenuItem<String>(
                      value: branch,
                      child: Text(branch, style: TextStyle(color: darktext)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedBranch = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                _buildUnderlineTextField(_rollNumberController, 'Roll Number'),

                const SizedBox(height: 20),
                const Text(
                  "Contact Info",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: secondaryColor),
                ),
                const SizedBox(height: 10),
                _buildUnderlineTextField(_emailController, 'Email'),
                const SizedBox(height: 10),
                _buildUnderlineTextField(_phoneController, 'Phone Number'),
                const SizedBox(height: 10),
                _buildUnderlineTextField(_passwordController, 'Password', obscureText: true),

                const SizedBox(height: 30),
                GestureDetector(
                  onTap: _signUp,
                  child: Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: _isSigningUp
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
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
          borderSide: BorderSide(color: grayColor, width: 2),
        ),
      ),
      style: const TextStyle(color: darkColor),
    );
  }

  void _signUp() async {
    if (_usernameController.text.trim().isEmpty ||
        _bioController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _rollNumberController.text.trim().isEmpty ||
        selectedCollegeCode == null ||
        selectedBranch == null ||
        _profileImage == null) {
      Fluttertoast.showToast(msg: 'All fields are mandatory. Please fill out all fields.');
      return;
    }

    setState(() {
      _isSigningUp = true;
    });

    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      String uid = userCredential.user!.uid;
      String rollNumber = _rollNumberController.text;

      // Generate a random unique number for the image filename
      int uniqueNumber = Random().nextInt(1000000);
      if (_profileImage != null) {
        Reference storageRef = _firebaseStorage.ref().child('profile_images/$uniqueNumber');
        UploadTask uploadTask = storageRef.putFile(_profileImage!);
        TaskSnapshot taskSnapshot = await uploadTask;
        _profileImageUrl = await taskSnapshot.ref.getDownloadURL();
      }

      await _firestore.collection('users')
          .doc(selectedCollegeCode)
          .collection('students')
          .doc(rollNumber)
          .set({
        'name': _usernameController.text,
        'email': _emailController.text,
        'branch': selectedBranch,
        'collegeCode': selectedCollegeCode,
        'rollNumber': rollNumber,
        'phone': _phoneController.text,
        'bio': _bioController.text,
        'profilePictureUrl': _profileImageUrl,
        'location': _locationController.text,
        'uid': uid,
      });

      Fluttertoast.showToast(msg: 'Sign-up successful!');
      setState(() {
        _isSigningUp = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      Fluttertoast.showToast( msg: 'Error: $e');
      setState(() {
        _isSigningUp = false;
      });
    }
  }
}
