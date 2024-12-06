import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'createEvents.dart';
import 'event_deatil_page.dart'; // Import the EventDetailPage

class EventsPage extends StatelessWidget {
  final Map<String, dynamic> clubDetails;
  final String collegeCode;
  final String rollNumber;

  const EventsPage({
    Key? key,
    required this.clubDetails,
    required this.collegeCode,
    required this.rollNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String clubId = clubDetails['clubId'];

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateEventPage(
                clubDetails: clubDetails,
                collegeCode: collegeCode,
                rollNumber: rollNumber,
              ),
            ),
          );
        },
        backgroundColor: Color(0xFFA60000),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(collegeCode)
            .collection('students')
            .doc(rollNumber)
            .collection('myClubs')
            .doc(clubId)
            .collection('myEvents')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No events found.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final event = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: GestureDetector(
                  onTap: () {
                    // Navigate to the EventDetailPage and pass the event data
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailPage(event: event),
                      ),
                    );
                  },
                  child: SizedBox(
                    height: 150,
                    child: Stack(
                      children: [
                        Row(
                          children: [
                            // Left 75%: Poster image
                            Expanded(
                              flex: 3, // 75% width for the image
                              child: event['posterUrl'] != null
                                  ? Image.network(
                                event['posterUrl'],
                                fit: BoxFit.cover,
                              )
                                  : Container(
                                color: Colors.grey,
                                child: const Icon(
                                  Icons.event,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              ),
                            ),
                            // Right 25%: Solid white background for event details
                            Expanded(
                              flex: 1, // 25% width for the data background
                              child: Container(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        // Center overlay gradient to merge poster and data
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withOpacity(0.9), // Thicker opacity
                                  Colors.white,
                                ],
                                stops: [0.2, 0.6, 0.8], // Smooth transition from left to right
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                          ),
                        ),
                        // Event details text on top of gradient
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
                                  'Date: ${event['date'] ?? 'No Date Available'}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  'Time: ${event['time'] ?? 'No Time Available'}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Add the ">" icon at the bottom-right corner
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Icon(
                            Icons.arrow_forward_ios, // The ">" symbol
                            color: Colors.black.withOpacity(0.7),
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
