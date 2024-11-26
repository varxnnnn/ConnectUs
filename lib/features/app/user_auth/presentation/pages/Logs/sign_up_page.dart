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

  String? _selectedCollegeCode;
  String? _selectedBranch;

  static const Color primaryColor = Color(0xFF1F2628);
  static const Color secondaryColor = Color(0xFFF9AA33);
  static const Color grayColor = Color(0xFF8A969B);
  static const Color darkColor = Color(0xFFEDEDED);

  final List<String> _collegeCodes = [
    'VGNT', 'CMR', 'GRRR', 'MGIT', 'SNITS', 'HOLY'
  ];

  final List<String> _branches = [
    'CSE', 'AIML', 'IT', 'MECH', 'DS', 'EEE', 'AI', 'ML'
  ];

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                "Sign Up Page",
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: secondaryColor),
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
              _buildDropdownField(
                hint: 'Select College Code',
                value: _selectedCollegeCode,
                items: _collegeCodes,
                onChanged: (value) {
                  setState(() {
                    _selectedCollegeCode = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              _buildDropdownField(
                hint: 'Select Branch',
                value: _selectedBranch,
                items: _branches,
                onChanged: (value) {
                  setState(() {
                    _selectedBranch = value;
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
                    color: secondaryColor,
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
                        color: secondaryColor,
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

  Widget _buildDropdownField({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
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
      style: const TextStyle(color: darkColor),
    );
  }

  void _signUp() async {
    if (_selectedCollegeCode == null || _selectedBranch == null) {
      showToast(message: "Please select both college code and branch.");
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
      int uniqueNumber = Random().nextInt(1000000); // Generate a random number
      if (_profileImage != null) {
        Reference storageRef = _firebaseStorage.ref().child('profile_images/$uniqueNumber');
        UploadTask uploadTask = storageRef.putFile(_profileImage!);
        TaskSnapshot taskSnapshot = await uploadTask;
        _profileImageUrl = await taskSnapshot.ref.getDownloadURL();
      }

      await _firestore.collection('users')
          .doc(_selectedCollegeCode)
          .collection('students')
          .doc(rollNumber)
          .set({
        'name': _usernameController.text,
        'email': _emailController.text,
        'branch': _selectedBranch,
        'collegeCode': _selectedCollegeCode,
        'rollNumber': rollNumber,
        'phone': _phoneController.text,
        'profilePictureUrl': _profileImageUrl,
        'bio': _bioController.text,
        'location': _locationController.text,
      });

      await _firestore.collection('allUsers').doc(uid).set({
        'name': _usernameController.text,
        'email': _emailController.text,
        'branch': _selectedBranch,
        'collegeCode': _selectedCollegeCode,
        'rollNumber': rollNumber,
        'phone': _phoneController.text,
        'profilePictureUrl': _profileImageUrl,
        'bio': _bioController.text,
        'location': _locationController.text,
      });

      showToast(message: "Sign up successful!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      showToast(message: e.message ?? "An error occurred during sign-up.");
    } finally {
      setState(() {
        _isSigningUp = false;
      });
    }
  }

  void showToast({required String message}) {
    Fluttertoast.showToast(msg: message);
  }
}
