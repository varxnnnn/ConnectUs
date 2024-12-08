import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:project1/features/app/user_auth/presentation/pages/students/club/my_clubs/createClubPage.dart';

class CreateEventPage extends StatefulWidget {
  final Map<String, dynamic> clubDetails;
  final String collegeCode;
  final String rollNumber;

  const CreateEventPage({
    Key? key,
    required this.clubDetails,
    required this.collegeCode,
    required this.rollNumber,
  }) : super(key: key);

  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  // Define colors
  final Color primaryColor = const Color(0xFF0D6EC5);
  final Color secondaryColor = const Color(0xFF0D1920);
  final Color darkColor = Colors.white;
  final Color grayColor = Colors.grey;
  final Color errorColor = Colors.black;

  final _formKey = GlobalKey<FormState>();
  final _eventNameController = TextEditingController();
  final _eventDateController = TextEditingController();
  final _eventTimeController = TextEditingController();
  final _venueController = TextEditingController();
  final _admissionFeeController = TextEditingController();
  final _guestController = TextEditingController();
  final _restrictionsController = TextEditingController();
  final _activityController = TextEditingController();

  bool _isPaidEvent = false;
  List<String> _activities = [];

  File? _eventPoster;
  final picker = ImagePicker();

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventDateController.dispose();
    _eventTimeController.dispose();
    _venueController.dispose();
    _admissionFeeController.dispose();
    _guestController.dispose();
    _restrictionsController.dispose();
    _activityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _eventPoster = File(pickedFile.path);
      }
    });
  }

  Future<String?> _uploadImage(File imageFile, String path) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(path);
      await storageRef.putFile(imageFile);
      return await storageRef.getDownloadURL();
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Image upload failed: $e",
        backgroundColor: errorColor,
        textColor: darkColor,
      );
      return null;
    }
  }

  void _addActivity() {
    if (_activityController.text.isNotEmpty && _activities.length < 5) {
      setState(() {
        _activities.add(_activityController.text);
        _activityController.clear();
      });
    }
  }

  Future<void> _submitEvent() async {
    if (_formKey.currentState?.validate() ?? false) {
      String? posterUrl;
      if (_eventPoster != null) {
        posterUrl = await _uploadImage(
          _eventPoster!,
          'events/${widget.collegeCode}/${widget.rollNumber}/${_eventNameController.text}_poster.jpg',
        );
      }

      final eventData = {
        'name': _eventNameController.text,
        'date': _eventDateController.text,
        'time': _eventTimeController.text,
        'venue': _venueController.text,
        'activities': _activities,
        'admissionFee': _isPaidEvent ? _admissionFeeController.text : 'Free',
        'guests': _guestController.text,
        'restrictions': _restrictionsController.text,
        'posterUrl': posterUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'collegeCode': widget.collegeCode,
        'rollNumber': widget.rollNumber,
        'clubName': widget.clubDetails['name'],
        'clubAdmin': widget.clubDetails['adminName'],
        'clubLogoUrl': widget.clubDetails['logoUrl'],
        'clubId': widget.clubDetails['clubId'],
      };

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.collegeCode)
            .collection('eventRequests')
            .add(eventData);

        Fluttertoast.showToast(
          msg: "Event requested successfully!",
          backgroundColor: errorColor,
          textColor: darkColor,
        );
        Navigator.pop(context);
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Error requesting event: $e",
          backgroundColor: errorColor,
          textColor: darkColor,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        backgroundColor: const Color(0xFF0D1920), // Change AppBar color
      ),
      backgroundColor: secondaryColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildUnderlinedTextInput('Event Name', _eventNameController),
              _buildUnderlinedTextInput('Event Date', _eventDateController),
              _buildUnderlinedTextInput('Event Time', _eventTimeController),
              _buildUnderlinedTextInput('Venue', _venueController),
              _buildActivitiesSection(),
              SwitchListTile(
                title: const Text('Admission Fee'),
                value: _isPaidEvent,
                onChanged: (value) => setState(() => _isPaidEvent = value),
              ),
              if (_isPaidEvent) _buildUnderlinedTextInput('Enter Fee Amount', _admissionFeeController, keyboardType: TextInputType.number),
              _buildUnderlinedTextInput('Guests', _guestController),
              _buildUnderlinedTextInput('Application Links', _restrictionsController),
              _buildImagePicker(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitEvent,
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                child: const Text('Submit Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event Poster',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[200],
            ),
            child: _eventPoster != null
                ? Image.file(_eventPoster!, fit: BoxFit.cover)
                : const Center(child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey)),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildUnderlinedTextInput(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF86B2D8)),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Activities', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Color(0xFF0D6EC5))),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _activityController,
                decoration: const InputDecoration(
                  hintText: 'Enter an activity',
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue), // Blue underline color
                  ),
                ),
              ),
            ),
            IconButton(icon: const Icon(Icons.add), onPressed: _addActivity),
          ],
        ),
        Wrap(
          spacing: 8.0,
          children: _activities.map((activity) => Chip(label: Text(activity), onDeleted: () => setState(() => _activities.remove(activity)))).toList(),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}