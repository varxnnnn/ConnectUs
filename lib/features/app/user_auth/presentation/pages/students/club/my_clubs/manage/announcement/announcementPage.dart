import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'AnnouncementDetailsPage.dart';
import 'createAnnouncement.dart';

class AnnouncementsPage extends StatelessWidget {
  final Map<String, dynamic> clubDetails;

  const AnnouncementsPage({Key? key, required this.clubDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the collegeCode and adminRollNumber from clubDetails
    final collegeCode = clubDetails['collegeCode'] ?? ''; // Provide a default if null
    final adminRollNumber = clubDetails['adminRollNumber'] ?? '';
    final clubId = clubDetails['clubId'] ?? ''; // Provide a default if null

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(collegeCode)  // Accessing the collegeCode
            .collection('students')
            .doc(adminRollNumber)  // Accessing the student by roll number
            .collection('myClubs')
            .doc(clubId)
            .collection('myAnnouncement') // Fetching announcements for this student
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Announcements Available'));
          }

          final announcements = snapshot.data!.docs;

          return ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index].data() as Map<String, dynamic>;
              final String subject = announcement['subject'] ?? 'No Subject';
              final String content = announcement['content'] ?? 'No Content';
              final Timestamp createdAt = announcement['createdAt'];
              final DateTime createdDate = createdAt.toDate();
              final String formattedDate =
                  '${createdDate.day}/${createdDate.month}/${createdDate.year} ${createdDate.hour}:${createdDate.minute}';

              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.announcement, color: Color(0xFFA60000)),  // Icon for announcement
                    title: Text(subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(content),
                        const SizedBox(height: 8),  // Space between content and date
                        Text(
                          'Posted on: $formattedDate',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Navigate to the AnnouncementDetailsPage and pass the announcement data
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AnnouncementDetailsPage(
                            announcementData: announcement,  // Pass the full announcement data
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(
                    color: Colors.grey, // Divider color
                    thickness: 0.5,       // Divider thickness
                    indent: 16,           // Indentation from the left
                    endIndent: 16,        // Indentation from the right
                  ),
                ],
              );
            },
          );
        },
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
                rollNumber: adminRollNumber,
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
