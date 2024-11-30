import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  File? _eventLogo;
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

  Future<void> _pickImage(bool isPoster) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        if (isPoster) {
          _eventPoster = File(pickedFile.path);
        } else {
          _eventLogo = File(pickedFile.path);
        }
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
        backgroundColor: Colors.red,
        textColor: Colors.white,
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _eventDateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _eventTimeController.text = "${picked.format(context)}";
      });
    }
  }

  Future<void> _submitEvent() async {
    if (_formKey.currentState?.validate() ?? false) {
      String? posterUrl;

      if (_eventPoster != null) {
        posterUrl = await _uploadImage(_eventPoster!, 'events/${widget.collegeCode}/${widget.rollNumber}/${_eventNameController.text}_poster.jpg');
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
        'clubName': widget.clubDetails['name'],  // Club Name
        'clubAdmin': widget.clubDetails['adminName'],  // Club Admin
        'clubLogoUrl': widget.clubDetails['logoUrl'],  // Club Logo URL
        'clubId': widget.clubDetails['clubId'],  // Club Id (added)
      };

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.collegeCode)
            .collection('eventRequests')
            .add(eventData);  // Using .add() to create a new document in eventRequests

        Fluttertoast.showToast(
          msg: "Event requested successfully!",
          backgroundColor: Color(0xFFF9AA33),
          textColor: Colors.white,
        );

        Navigator.pop(context);
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Error requesting event: $e",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildUnderlinedTextInput('Event Name', _eventNameController),
              GestureDetector(
                onTap: _selectDate,  // Date picker on tap
                child: AbsorbPointer(
                  child: _buildUnderlinedTextInput('Event Date (Tap to select)', _eventDateController),
                ),
              ),
              GestureDetector(
                onTap: _selectTime,  // Time picker on tap
                child: AbsorbPointer(
                  child: _buildUnderlinedTextInput('Event Time (Tap to select)', _eventTimeController),
                ),
              ),
              _buildUnderlinedTextInput('Venue', _venueController),

              _buildActivitiesSection(),

              SwitchListTile(
                title: const Text('Admission Fee'),
                value: _isPaidEvent,
                onChanged: (value) => setState(() => _isPaidEvent = value),
                subtitle: Text(_isPaidEvent ? 'Paid' : 'Free'),
              ),
              if (_isPaidEvent) _buildUnderlinedTextInput('Enter Fee Amount', _admissionFeeController, keyboardType: TextInputType.number),

              _buildUnderlinedTextInput('Guests', _guestController),
              _buildUnderlinedTextInput('Restrictions (if any)', _restrictionsController),

              _buildImagePicker('Select Event Poster', true, _eventPoster),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitEvent,
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFF9AA33)), // Light secondary color
                child: const Text('Submit Event'),
              ),
            ],
          ),
        ),
      ),
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
          border: UnderlineInputBorder(),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFF9AA33)), // Highlight with the secondary color
          ),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  Widget _buildActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Activities (add up to 5)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _activityController,
                decoration: const InputDecoration(
                  hintText: 'Add an activity',
                  border: UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFF9AA33)), // Highlight with the secondary color
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addActivity,
              color: Color(0xFFF9AA33), // Light secondary color for button
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: _activities.map((activity) {
            return Chip(label: Text(activity));
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildImagePicker(String label, bool isPoster, File? imageFile) {
    return GestureDetector(
      onTap: () => _pickImage(isPoster),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        color: Color(0xFF7E6377), // Dark color for the image picker container
        child: Column(
          children: [
            Text(label, style: TextStyle(color: Colors.white)),
            const SizedBox(height: 10),
            imageFile == null
                ? const Icon(Icons.add_a_photo, color: Colors.white)
                : Image.file(imageFile, width: 100, height: 100),
          ],
        ),
      ),
    );
  }
}
