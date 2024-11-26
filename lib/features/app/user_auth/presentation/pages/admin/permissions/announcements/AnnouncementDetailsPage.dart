import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AnnouncementDetailsPage extends StatelessWidget {
  final Map<String, dynamic> announcementData;

  const AnnouncementDetailsPage({Key? key, required this.announcementData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String subject = announcementData['subject'] ?? 'No Subject';
    final Timestamp createdAt = announcementData['createdAt'];
    final DateTime createdDate = createdAt.toDate();
    final String formattedDate = '${createdDate.day}/${createdDate.month}/${createdDate.year} ${createdDate.hour}:${createdDate.minute}';

    final String adminName = announcementData['adminName'] ?? 'Unknown Admin';
    final String adminBranch = announcementData['adminBranch'] ?? 'Unknown Branch';
    final String adminRollNumber = announcementData['adminRollNumber'] ?? 'Unknown Roll Number';
    final String adminProfilePic = announcementData['adminProfilePic'] ?? '';
    final String clubId = announcementData['clubId'] ?? 'Unknown Club ID'; // Set default value if not provided


    final String clubName = announcementData['clubName'] ?? 'Unknown Club';
    final String clubAim = announcementData['clubAim'] ?? 'Unknown Aim';
    final String clubCategory = announcementData['clubCategory'] ?? 'Unknown Category';
    final String clubLogoUrl = announcementData['clubLogoUrl'] ?? '';

    final String content = announcementData['content'] ?? 'No Content';

    // Extract collegeCode
    final String collegeCode = announcementData['collegeCode'] ?? 'Unknown College Code';

    // Reference to Firestore document
    final String documentId = announcementData['announcementId'];

    // Function to add the announcement to all relevant Firestore collections
    Future<void> _addAnnouncementToFirestore() async {
      try {
        final firestore = FirebaseFirestore.instance;

        // Retrieve the clubId from the announcementData (or pass it when creating the announcement)
        // Declare the announcementData map here
        final Map<String, dynamic> announcementData = {
          'subject': subject,
          'createdAt': createdAt,
          'adminName': adminName,
          'adminBranch': adminBranch,
          'adminRollNumber': adminRollNumber,
          'adminProfilePic': adminProfilePic,
          'clubName': clubName,
          'clubAim': clubAim,
          'clubCategory': clubCategory,
          'clubLogoUrl': clubLogoUrl,
          'content': content,
          'announcementId': documentId,
          'collegeCode': collegeCode,
          'clubId': clubId, // Add clubId to the data
        };

        // Batch write to Firestore
        WriteBatch batch = firestore.batch();

        // Add announcement to allAnnouncements
        batch.set(firestore.collection('allAnnouncements').doc(documentId), announcementData);

        batch.set(firestore.collection('allClubs').doc(clubId).collection('myAnnouncement').doc(documentId), announcementData);

        
        // Add announcement to collegeAnnouncements
        batch.set(
          firestore.collection('users').doc(collegeCode).collection('collegeAnnouncements').doc(documentId),
          announcementData,
        );

        // Add announcement to myAnnouncements for admin
        batch.set(
          firestore.collection('users').doc(collegeCode).collection('students').doc(adminRollNumber).collection('myClubs').doc(clubId).collection('myAnnouncement').doc(documentId),
          announcementData,
        );

        // Commit the batch write
        await batch.commit();

        await firestore.collection('announcementRequests').doc(documentId).delete();


        // Show success and navigate back
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Announcement Accepted')));
        Navigator.pop(context); // Go back to the previous page
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }

    // Function to reject the announcement (removes from requests and navigates back)
    Future<void> _rejectAnnouncement() async {
      try {
        // Ensure document exists before attempting deletion from announcementRequests collection
        final firestore = FirebaseFirestore.instance;
        final announcementRequestDoc = await firestore.collection('users').doc(collegeCode).collection('collegeAnnouncements').doc(documentId).get();

        if (announcementRequestDoc.exists) {
          // Remove the announcement from the announcementRequests collection
          await firestore.collection('users').doc(collegeCode).collection('announcementRequests').doc(documentId).delete();
        } else {
          print('Document not found in announcementRequests: $documentId');
        }

        // Show a snackbar and navigate back after rejecting the announcement
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Announcement Rejected')));
        Navigator.pop(context);  // Go back to the previous page
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcement Details'),
        backgroundColor: Colors.teal, // AppBar color for a fresh look
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display Subject
              Text(
                'Subject: $subject',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 8),

              // Display Created Date
              Text(
                'Created on: $formattedDate',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Admin Info
              Text(
                'Admin Name: $adminName',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Branch: $adminBranch',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Roll Number: $adminRollNumber',
                style: const TextStyle(fontSize: 16),
              ),
              if (adminProfilePic.isNotEmpty) ...[
                const SizedBox(height: 8),
                ClipOval(
                  child: Image.network(adminProfilePic, width: 50, height: 50, fit: BoxFit.cover),
                ),
              ],
              const SizedBox(height: 16),

              // College Code Display
              Text(
                'College Code: $collegeCode',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Club Info
              Text(
                'Club Name: $clubName',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Club Aim: $clubAim',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Club Category: $clubCategory',
                style: const TextStyle(fontSize: 16),
              ),
              if (clubLogoUrl.isNotEmpty) ...[
                const SizedBox(height: 8),
                ClipOval(
                  child: Image.network(clubLogoUrl, width: 50, height: 50, fit: BoxFit.cover),
                ),
              ],
              const SizedBox(height: 16),

              // Announcement Content
              Text(
                'Content: $content',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),

              // Accept and Reject buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _addAnnouncementToFirestore,
                    child: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Green color for Accept button
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _rejectAnnouncement,
                    child: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Red color for Reject button
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
