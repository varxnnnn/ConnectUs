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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcement Details'),
        backgroundColor: Color(0xFF0D1920),
      ),
      backgroundColor: Color(0xFF0D1920),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject and Content
              Text('Subject: $subject', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D6EC5))),
              const SizedBox(height: 8),
              Text('Content: $content', style: const TextStyle(fontSize: 18, color: Colors.white)),
              const SizedBox(height: 16),

              // Created On
              Text('Created on: $formattedDate', style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 16),

              // Club Details
              Text('Club Name: $clubName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('Club Aim: $clubAim', style: const TextStyle(fontSize: 16, color: Colors.white)),
              Text('Club Category: $clubCategory', style: const TextStyle(fontSize: 16, color: Colors.white)),
              if (clubLogoUrl.isNotEmpty) ...[
                const SizedBox(height: 8),
                ClipOval(
                  child: Image.network(clubLogoUrl, width: 50, height: 50, fit: BoxFit.cover),
                ),
              ],
              const SizedBox(height: 16),

              // Admin Details
              Text('Admin Name: $adminName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('Branch: $adminBranch', style: const TextStyle(fontSize: 16, color: Colors.white)),
              Text('Roll Number: $adminRollNumber', style: const TextStyle(fontSize: 16, color: Colors.white)),
              if (adminProfilePic.isNotEmpty) ...[
                const SizedBox(height: 8),
                ClipOval(
                  child: Image.network(adminProfilePic, width: 50, height: 50, fit: BoxFit.cover),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
