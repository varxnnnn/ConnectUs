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
      QuerySnapshot eventsSnapshot = await FirebaseFirestore.instance
          .collection('allClubs')
          .doc(clubId)
          .collection('myEvents')
          .get();

      return eventsSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error fetching events: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
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

        final events = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            final eventId = event['eventId'];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailsPage(eventId: eventId, clubId: clubId),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: SizedBox(
                  height: 150,
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: event['posterUrl'] != null
                                ? Image.network(
                              event['posterUrl'],
                              fit: BoxFit.cover,
                            )
                                : Container(
                              color: Colors.grey,
                              child: const Icon(
                                Icons.photo,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(color: Colors.white),
                          ),
                        ],
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white.withOpacity(0.9),
                                Colors.white,
                              ],
                              stops: [0.2, 0.6, 0.8],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        bottom: 8,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.25,
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                event['name'] ?? 'Unnamed Event',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Club: ${event['clubName'] ?? 'N/A'}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Date: ${event['date'] ?? 'N/A'}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.black.withOpacity(0.7),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
