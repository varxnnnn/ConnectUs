import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'event_details_page.dart'; // Import the EventDetailsPage

class EventsRequestsPage extends StatelessWidget {
  final String collegeCode;

  const EventsRequestsPage({Key? key, required this.collegeCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              final eventName = event['name'] ?? 'Untitled Event';
              final clubName = event['clubName'] ?? 'Unknown Club';
              final eventId = events[index].id; // To use this in navigation
              final eventImageUrl = event['posterUrl'] ?? ''; // You can replace this with your event image URL field
              final eventDate = event['date'] ?? 'N/A';

              return GestureDetector(
                onTap: () {
                  // Navigate to EventDetailsPage with event information
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailsPage(
                        eventId: eventId,
                        collegeCode: collegeCode,
                        clubDetails: {}, // Pass actual club details here if needed
                      ),
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
                              child: eventImageUrl.isNotEmpty
                                  ? Image.network(
                                eventImageUrl,
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
                              child: Container(
                                color: Colors.white,
                              ),
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
                                  eventName,
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
                                  "Club: $clubName",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Date: $eventDate",
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
                      ],
                    ),
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
