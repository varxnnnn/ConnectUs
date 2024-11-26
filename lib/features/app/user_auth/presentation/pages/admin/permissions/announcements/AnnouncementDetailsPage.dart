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

    final String clubName = announcementData['clubName'] ?? 'Unknown Club';
    final String clubAim = announcementData['clubAim'] ?? 'Unknown Aim';
    final String clubCategory = announcementData['clubCategory'] ?? 'Unknown Category';
    final String clubLogoUrl = announcementData['clubLogoUrl'] ?? '';

    final String content = announcementData['content'] ?? 'No Content';

    // Reference to Firestore document
    final String documentId = announcementData['announcementId'];

    // Function to update the status in Firestore and add to allAnnouncements collection
    void _updateStatus(String status) async {
      try {
        // Debugging: Print the document ID for better tracking
        print('Updating status for announcement ID: $documentId');

        // Check if the document exists in announcementRequests
        var requestDoc = await FirebaseFirestore.instance
            .collection('announcementRequests')
            .doc(documentId)
            .get();

        if (!requestDoc.exists) {
          print('Document not found in announcementRequests');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Document missing in announcementRequests: $documentId')));
          return;
        }

        // Update the status in the announcementRequests collection
        await FirebaseFirestore.instance
            .collection('announcementRequests')
            .doc(documentId)
            .update({'status': status});

        // If accepted, add to allAnnouncements and other collections
        if (status == 'Accepted') {
          // Add to the allAnnouncements collection
          await FirebaseFirestore.instance
              .collection('allAnnouncements')
              .doc(documentId)
              .set({
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
          });

          // Add to the branch's collection
          await FirebaseFirestore.instance
              .collection('users')
              .doc(adminBranch)
              .collection('collegeAnnouncements')
              .doc(documentId)
              .set({
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
          });

          // Add to the student's collection under myAnnouncements
          await FirebaseFirestore.instance
              .collection('users')
              .doc(adminBranch)
              .collection('students')
              .doc(adminRollNumber)
              .collection('myAnnouncements')
              .doc(documentId)
              .set({
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
          });
        }

        // Remove the announcement from the announcementRequests collection (both for accepted and rejected)
        await FirebaseFirestore.instance
            .collection('announcementRequests')
            .doc(documentId)
            .delete();

        // Show a snackbar or navigate back after updating
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Announcement $status')));
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcement Details'),
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
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Display Created Date
              Text(
                'Created on: $formattedDate',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),

              // Admin Info
              Text(
                'Admin Name: $adminName',
                style: const TextStyle(fontSize: 18),
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
                Image.network(adminProfilePic, width: 50, height: 50, fit: BoxFit.cover),
              ],
              const SizedBox(height: 16),

              // Club Info
              Text(
                'Club Name: $clubName',
                style: const TextStyle(fontSize: 18),
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
                Image.network(clubLogoUrl, width: 50, height: 50, fit: BoxFit.cover),
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
                    onPressed: () => _updateStatus('Accepted'),
                    child: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Green color for Accept button
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _updateStatus('Rejected'),
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
