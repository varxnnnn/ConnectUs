import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'announcement_details/announcement_details.dart';


class AnnouncementsTab extends StatelessWidget {
  final Map<String, dynamic> clubDetails;

  const AnnouncementsTab({Key? key, required this.clubDetails}) : super(key: key);

  // Method to fetch announcements from Firestore
  Future<List<Map<String, dynamic>>> _getAnnouncements() async {
    try {
      // Extract clubId from clubDetails
      final String clubId = clubDetails['clubId'] ?? '';

      if (clubId.isEmpty) {
        throw Exception('Club ID is missing.');
      }

      // Fetch announcements for the specific clubId from the 'myAnnouncement' collection
      QuerySnapshot announcementsSnapshot = await FirebaseFirestore.instance
          .collection('allClubs')
          .doc(clubId)
          .collection('myAnnouncement')
          .orderBy('createdAt', descending: true)
          .get();

      // Map the announcements into a list of Map<String, dynamic>
      List<Map<String, dynamic>> announcementsList = [];
      for (var doc in announcementsSnapshot.docs) {
        announcementsList.add(doc.data() as Map<String, dynamic>);
      }
      return announcementsList;
    } catch (e) {
      print("Error fetching announcements: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getAnnouncements(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No announcements available for this club.'));
        }

        // List of announcements
        final announcements = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final announcement = announcements[index];
                final subject = announcement['subject'] ?? 'No Subject';
                final content = announcement['content'] ?? 'No Content';
                final createdAt = (announcement['createdAt'] as Timestamp?)?.toDate();
                final formattedDate = createdAt != null
                    ? '${createdAt.day}/${createdAt.month}/${createdAt.year}'
                    : 'Unknown Date';

                return Column(
                  children: [
                    ListTile(
                      title: Text(
                        subject,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            content,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Posted on: $formattedDate',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      leading: const Icon(Icons.announcement, color: Color(0xFF86B2D8)),
                      trailing: const Icon(Icons.arrow_forward, color: Colors.grey),
                      onTap: () {
                        // Handle navigation to Announcement Details page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AnnouncementDetailsPage(announcementData: announcement),
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
            ),
          ],
        );
      },
    );
  }
}
