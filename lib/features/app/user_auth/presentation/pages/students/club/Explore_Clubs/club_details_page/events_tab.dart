// events_tab.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'event_details/event_details_page.dart'; // Import the EventDetailsPage

class EventsTab extends StatelessWidget {
  final Map<String, dynamic> clubDetails;
  final String clubId;

  const EventsTab({Key? key, required this.clubDetails, required this.clubId}) : super(key: key);

  // Method to fetch events from Firestore
  Future<List<Map<String, dynamic>>> _getEvents() async {
    try {
      // Fetch events for the specific clubId from the 'myEvents' collection
      QuerySnapshot eventsSnapshot = await FirebaseFirestore.instance
          .collection('allClubs')
          .doc(clubId)
          .collection('myEvents')
          .get();

      // Map the events into a list of Map<String, dynamic>
      List<Map<String, dynamic>> eventsList = [];
      for (var doc in eventsSnapshot.docs) {
        eventsList.add(doc.data() as Map<String, dynamic>);
      }
      return eventsList;
    } catch (e) {
      print("Error fetching events: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(  // FutureBuilder to handle fetching data
      future: _getEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No events available for this club.'));
        }

        // List of events
        final events = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Explore_Events',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFF9AA33)),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                final eventId = event['eventId']; // Assuming 'eventId' is a field in the event document
                final eventName = event['name'] ?? 'Event Name';
                final eventDate = event['date'] ?? 'Event Date';
                final eventTime = event['time'] ?? 'Event Time';
                final logoUrl = event['clubLogoUrl'];  // Using logoUrl instead of clubLogoUrl

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(eventName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$eventDate at $eventTime'),
                      ],
                    ),
                    onTap: () {
                      // Navigate to the Event Details page, passing both eventId and clubId
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailsPage(eventId: eventId, clubId: clubId),
                        ),
                      );
                    },
                    leading: logoUrl != null
                        ? CircleAvatar(backgroundImage: NetworkImage(logoUrl), radius: 20)
                        : const Icon(Icons.arrow_forward, color: Colors.grey),  // Navigation symbol ">"
                    trailing: IconButton(
                      icon: const Icon(Icons.arrow_forward, color: Colors.grey),
                      onPressed: () {
                        // Navigate to the Event Details page, passing both eventId and clubId
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventDetailsPage(eventId: eventId, clubId: clubId),
                          ),
                        );
                      },
                    ),
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
