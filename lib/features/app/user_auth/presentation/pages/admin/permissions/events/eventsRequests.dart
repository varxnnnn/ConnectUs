import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'event_details_page.dart'; // Import the EventDetailsPage

class EventsRequestsPage extends StatelessWidget {
  final String collegeCode;

  const EventsRequestsPage({Key? key, required this.collegeCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Requests for $collegeCode'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(collegeCode)
            .collection('eventRequests') // Fetch event requests for the specific college code
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No event requests found.'));
          }

          final events = snapshot.data!.docs;

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index].data() as Map<String, dynamic>;
              final eventName = event['name'];
              final clubName = event['clubName'];
              final eventId = events[index].id; // To use this in navigation

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  title: Text(eventName ?? 'Untitled Event'),
                  subtitle: Text('Club: $clubName'),
                  trailing: IconButton(
                    icon: const Icon(Icons.info),
                    onPressed: () {
                      // Navigate to EventDetailsPage with event information
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailsPage(
                            eventId: eventId,
                            collegeCode: collegeCode, clubDetails: {},
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
