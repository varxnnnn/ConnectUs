import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
            const Text(
              'Club Announcements',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFF9AA33)),
            ),
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

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(subject),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(content, maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text('Published on: $formattedDate', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    leading: const Icon(Icons.announcement, color: Colors.orange),
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
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// Placeholder for AnnouncementDetailsPage
class AnnouncementDetailsPage extends StatelessWidget {
  final Map<String, dynamic> announcementData;

  const AnnouncementDetailsPage({Key? key, required this.announcementData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcement Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              announcementData['subject'] ?? 'No Subject',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              announcementData['content'] ?? 'No Content',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
