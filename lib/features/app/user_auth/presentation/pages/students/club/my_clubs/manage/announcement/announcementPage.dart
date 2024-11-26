import 'package:flutter/material.dart';
import 'createAnnouncement.dart';

class AnnouncementsPage extends StatelessWidget {
  final Map<String, dynamic> clubDetails;

  const AnnouncementsPage({Key? key, required this.clubDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the collegeCode from clubDetails
    final collegeCode = clubDetails['collegeCode'] ?? ''; // Provide a default if null
    final rollNumber = clubDetails['adminRollNumber'] ?? ''; // Provide a default if null

    return Scaffold(
      appBar: AppBar(
        title: Text('${clubDetails['name']} Announcements'),
      ),
      body: Center(
        child: Text('Announcements for ${clubDetails['name']}'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to CreateAnnouncementPage with collegeCode and rollNumber
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateAnnouncementPage(
                clubDetails: clubDetails,
                collegeCode: collegeCode,
                rollNumber: rollNumber,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
