import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AnnouncementDetailsPage.dart';
class AnnouncementRequestsPage extends StatelessWidget {
  final String collegeCode;

  const AnnouncementRequestsPage({Key? key, required this.collegeCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Announcement Requests for $collegeCode'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(collegeCode)
            .collection('announcementRequests') // Replace with the actual path to the collection
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No announcement requests available.'));
          }

          // Get the documents
          final announcementRequests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: announcementRequests.length,
            itemBuilder: (context, index) {
              final request = announcementRequests[index];
              final requestData = request.data() as Map<String, dynamic>;

              // Build the UI for each request
              return Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 4,
                child: ListTile(
                  title: Text(requestData['subject'] ?? 'No title'),
                  subtitle: Text(requestData['collegeCode'] ?? 'No description'),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      // Navigate to the AnnouncementDetailsPage with the selected data
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AnnouncementDetailsPage(
                            announcementData: requestData,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
