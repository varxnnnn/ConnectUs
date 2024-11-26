import 'package:flutter/material.dart';

class EventDetailsPage extends StatelessWidget {
  final Map<String, dynamic> eventDetails;

  const EventDetailsPage({Key? key, required this.eventDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(eventDetails['name'] ?? 'Event Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (eventDetails['posterUrl'] != null)
              Image.network(
                eventDetails['posterUrl'],
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 16),
            Text(
              eventDetails['name'] ?? 'Unnamed Event',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Club: ${eventDetails['clubName'] ?? 'N/A'}"),
            const SizedBox(height: 8),
            Text("Date: ${eventDetails['date'] ?? 'N/A'}"),
            const SizedBox(height: 8),
            Text("Venue: ${eventDetails['venue'] ?? 'N/A'}"),
            const SizedBox(height: 8),
            Text("Admission Fee: ${eventDetails['admissionFee'] ?? 'N/A'}"),
            const SizedBox(height: 16),
            Text("Description:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(eventDetails['description'] ?? 'No description available.'),
          ],
        ),
      ),
    );
  }
}
