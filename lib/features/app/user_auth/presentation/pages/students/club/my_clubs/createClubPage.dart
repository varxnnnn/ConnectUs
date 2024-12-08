import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Define colors at the top
const Color backgroundColor = Color(0xFF0D1920);
const Color primaryColor = Color(0xFFECE6E6);
const Color secondaryColor = Color(0xFF0D6EC5);
const Color textColor = Colors.white;
const Color secondaryTextColor = Color(0xFF86B2D8);

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
    'Dance', 'Singing', 'Coding', 'Sports', 'Event Managing',
    'Culturals', 'Arts', 'Drama', 'Music', 'Debate',
  ];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _logoImage = pickedFile;
    });
  }

  Future<void> _createClubRequest() async {
    if (_nameController.text.isEmpty || _aimController.text.isEmpty || _descriptionController.text.isEmpty || _logoImage == null) {
      Fluttertoast.showToast(msg: "Please fill all fields and select a logo", backgroundColor: Colors.red);
      return;
    }
    setState(() {
      _isCreating = true;
    });

    try {
      final storageRef = FirebaseStorage.instance.ref();
      final logoRef = storageRef.child('club_logos/${_logoImage!.name}');
      await logoRef.putFile(File(_logoImage!.path));
      final logoUrl = await logoRef.getDownloadURL();

      final adminDoc = await _firestore.collection('allUsers').doc(_firebaseAuth.currentUser!.uid).get();
      if (adminDoc.exists) {
        var adminData = adminDoc.data()!;
        final clubRef = _firestore.collection('users')
            .doc(widget.collegeCode)
            .collection('clubRequests')
            .doc();
        final clubId = clubRef.id;

        await clubRef.set({
          'clubId': clubId,
          'name': _nameController.text,
          'category': _selectedCategory,
          'aim': _aimController.text.isEmpty ? 'No aim provided' : _aimController.text,
          'description': _descriptionController.text,
          'logoUrl': logoUrl,
          'adminId': _firebaseAuth.currentUser!.uid,
          'adminName': adminData['name'],
          'adminProfilePic': adminData['profilePictureUrl'],
          'adminRollNumber': adminData['rollNumber'],
          'adminBranch': adminData['branch'],
          'createdAt': FieldValue.serverTimestamp(),
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
        _isCreating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Club', style: TextStyle(color: textColor)),
        centerTitle: true,
        backgroundColor: backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: secondaryTextColor),
                    borderRadius: BorderRadius.circular(10),
                    color: primaryColor,
                  ),
                  child: Center(
                    child: Text(
                      _logoImage != null ? _logoImage!.name : 'Select Club Logo',
                      style: TextStyle(color: _logoImage != null ? textColor : secondaryTextColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildUnderlineTextField(_nameController, 'Club Name'),
              const SizedBox(height: 10),
              _buildCategoryDropdown(),
              const SizedBox(height: 10),
              _buildUnderlineTextField(_aimController, 'Aim'),
              const SizedBox(height: 10),
              _buildUnderlineTextField(_descriptionController, 'Description', maxLines: 3),
              const SizedBox(height: 30),
              _isCreating
                  ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(secondaryColor))
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
                    child: const Text("Create Club", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnderlineTextField(TextEditingController controller, String hintText, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: secondaryTextColor),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: secondaryTextColor)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: secondaryColor, width: 2)),
      ),
      style: const TextStyle(color: textColor),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: secondaryTextColor))),
      items: categories.map((String category) => DropdownMenuItem(value: category, child: Text(category, style: TextStyle(color: secondaryTextColor)))).toList(),
      onChanged: (value) => setState(() => _selectedCategory = value!),
      style: const TextStyle(color: textColor),
    );
  }
}