import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventDetailsPage extends StatelessWidget {
  final String eventId;
  final String clubId;

  const EventDetailsPage({Key? key, required this.eventId, required this.clubId}) : super(key: key);

  // Method to fetch event details from Firestore based on eventId
  Future<Map<String, dynamic>> _getEventDetails() async {
    try {
      // Fetch event details for the specific eventId from the Firestore 'myEvents' collection
      DocumentSnapshot eventSnapshot = await FirebaseFirestore.instance
          .collection('allClubs')
          .doc(clubId)
          .collection('myEvents')
          .doc(eventId)
          .get();

      // Check if the document exists
      if (eventSnapshot.exists) {
        return eventSnapshot.data() as Map<String, dynamic>;
      } else {
        throw Exception('Event not found');
      }
    } catch (e) {
      print("Error fetching event details: $e");
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getEventDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Event details not available.'));
        }

        // Event details
        final event = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Event Details'),
            backgroundColor: Colors.deepPurple,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (event['posterUrl'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        event['posterUrl'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 250,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    event['name'] ?? 'Event Name',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Date: ${event['date'] ?? 'Not specified'}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Text(
                    'Time: ${event['time'] ?? 'Not specified'}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Text(
                    'Venue: ${event['venue'] ?? 'Not specified'}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Club: ${event['clubName'] ?? 'Not specified'}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Admin: ${event['clubAdmin'] ?? 'Not specified'}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Admission Fee: ${event['admissionFee'] ?? 'Not specified'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  if (event['activities'] != null)
                    Text(
                      'Activities: ${List<String>.from(event['activities']).join(', ')}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'Guests: ${event['guests'] ?? 'Not specified'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Restrictions: ${event['restrictions'] ?? 'Not specified'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
