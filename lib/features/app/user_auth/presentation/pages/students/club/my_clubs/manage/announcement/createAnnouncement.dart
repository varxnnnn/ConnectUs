import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CreateAnnouncementPage extends StatefulWidget {
  final String collegeCode;
  final Map<String, dynamic> clubDetails; // Add clubDetails as a parameter
  final String rollNumber;

  const CreateAnnouncementPage({
    Key? key,
    required this.collegeCode,
    required this.clubDetails,
    required this.rollNumber,
  }) : super(key: key);

  @override
  _CreateAnnouncementPageState createState() => _CreateAnnouncementPageState();
}

class _CreateAnnouncementPageState extends State<CreateAnnouncementPage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController _subjectController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  bool _isCreating = false;
  XFile? _attachmentImage; // To hold any attachment for the announcement

  static const Color primaryColor = Color(0xFFECE6E6);
  static const Color secondaryColor = Color(0xFFA60000);
  static const Color grayColor = Color(0xFF4A6572);
  static const Color darkColor = Colors.black;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _attachmentImage = pickedFile; // Store the selected image
    });
  }

  Future<void> _createAnnouncementRequest() async {
    if (_subjectController.text.isEmpty || _contentController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please fill all fields", backgroundColor: Colors.red);
      return;
    }

    setState(() {
      _isCreating = true; // Set loading state to true
    });

    try {
      String? attachmentUrl;

      // If there's an attachment image, upload it to Firebase Storage
      if (_attachmentImage != null) {
        final storageRef = FirebaseStorage.instance.ref();
        final attachmentRef = storageRef.child('announcement_attachments/${_attachmentImage!.name}');
        await attachmentRef.putFile(File(_attachmentImage!.path));

        // Get the download URL of the uploaded image
        attachmentUrl = await attachmentRef.getDownloadURL();
      }

      // Get admin details from Firestore using adminId
      final adminDoc = await FirebaseFirestore.instance.collection('allUsers').doc(FirebaseAuth.instance.currentUser!.uid).get();

      if (adminDoc.exists) {
        var adminData = adminDoc.data()!;

        // Generate a unique ID for the announcement using Firestore's auto-generated document ID
        final announcementRef = FirebaseFirestore.instance.collection('users')
            .doc(widget.collegeCode)
            .collection('announcementRequests')
            .doc(); // Firestore auto-generates a document ID

        final announcementId = announcementRef.id; // Get the generated announcement ID

        // Add the announcement request to Firestore under the 'announcementRequests' collection
        await announcementRef.set({
          'announcementId': announcementId,  // Save the generated announcementId
          'subject': _subjectController.text,
          'content': _contentController.text,
          'attachmentUrl': attachmentUrl ?? '', // Save the attachment URL (if any)
          'adminId': FirebaseAuth.instance.currentUser!.uid,
          'adminName': adminData['name'], // Admin name from Firestore
          'adminProfilePic': adminData['profilePictureUrl'], // Admin profile picture from Firestore
          'adminRollNumber': adminData['rollNumber'], // Admin's roll number from Firestore
          'adminBranch': adminData['branch'],
          'collegeCode': widget.collegeCode,// Admin's branch from Firestore
          'clubName': widget.clubDetails['name'], // Add club name from the clubDetails
          'clubAim': widget.clubDetails['aim'], // Add club aim from the clubDetails
          'clubCategory': widget.clubDetails['category'], // Add club category from the clubDetails
          'clubId': widget.clubDetails['clubId'], // Add clubId from the clubDetails
          'clubLogoUrl': widget.clubDetails['logoUrl'], // Add clubLogoUrl from the clubDetails
          'createdAt': FieldValue.serverTimestamp(), // Timestamp when the request was created
        });

        Fluttertoast.showToast(msg: "Announcement submitted successfully!", backgroundColor: Colors.green);
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
        title: const Text('Create Announcement'),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Announcement Attachment Picker (Optional image for announcement)
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
                      _attachmentImage != null ? _attachmentImage!.name : 'Select Attachment (Optional)',
                      style: TextStyle(color: _attachmentImage != null ? darkColor : grayColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              _buildUnderlineTextField(_subjectController, 'Subject'),
              const SizedBox(height: 10),

              _buildUnderlineTextField(_contentController, 'Content', maxLines: 3),
              const SizedBox(height: 30),

              // Submit Button or Circular Progress Indicator
              _isCreating
                  ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(secondaryColor),
              )
                  : GestureDetector(
                onTap: _createAnnouncementRequest,
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: secondaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: const Text(
                      "Submit Announcement",
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
}
