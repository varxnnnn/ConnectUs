import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AnnouncementDetailsPage extends StatelessWidget {
  final Map<String, dynamic> announcementData;

  const AnnouncementDetailsPage({Key? key, required this.announcementData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define colors
    const Color backgroundColor = Color(0xFF0D1920);
    const Color primaryColor = Color(0xFF0D6EC5);
    const Color textColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Announcement Details'),
        backgroundColor: backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              announcementData['subject'] ?? 'No Subject',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 16),
            Text(
              announcementData['content'] ?? 'No Content',
              style: const TextStyle(fontSize: 16, color: textColor),
            ),
            const SizedBox(height: 16),
            Text(
              'Posted on: ${announcementData['createdAt'] != null ? (announcementData['createdAt'] as Timestamp).toDate().toString() : 'Unknown Date'}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
