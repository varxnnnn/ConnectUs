import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventDetailsPage extends StatelessWidget {
  final String eventId;
  final String collegeCode;
  final Map<String, dynamic> clubDetails;

  const EventDetailsPage({
    Key? key,
    required this.eventId,
    required this.collegeCode,
    required this.clubDetails,
  }) : super(key: key);

  // Method to handle event status updates and add event to the student's club
  Future<void> _updateEventStatus(String status, BuildContext context) async {
    try {
      // Fetch the event data from Firestore
      final eventSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(collegeCode)
          .collection('eventRequests')
          .doc(eventId)
          .get();

      if (!eventSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event not found.')),
        );
        return;
      }

      final event = eventSnapshot.data() as Map<String, dynamic>;
      final clubId = event['clubId'];

      if (clubId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Club ID not found for the event.')),
        );
        return;
      }

      // Ensure activities is an array and handle it as an array of strings
      final activities = event['activities'] is List ? event['activities'] : [];

      // Update the event status in the eventRequests collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(collegeCode)
          .collection('eventRequests')
          .doc(eventId)
          .update({'status': status});

      if (status == 'Accepted') {
        // Add the event to the student's "myClubs" and the club's "events" collections
        await FirebaseFirestore.instance
            .collection('users')
            .doc(collegeCode)
            .collection('students')
            .doc(event['rollNumber'])
            .collection('myClubs')
            .doc(clubId)
            .collection('myEvents')
            .doc(eventId)
            .set({
          'eventId': eventId,  // Save the eventId here
          'name': event['name'],
          'date': event['date'],
          'time': event['time'],
          'venue': event['venue'],
          'collagecode' : collegeCode,
          'posterUrl': event['posterUrl'],
          'clubName': event['clubName'],
          'clubAdmin': event['clubAdmin'],
          'clubLogoUrl': event['clubLogoUrl'],
          'admissionFee': event['admissionFee'],
          'guests': event['guests'],
          'restrictions': event['restrictions'],
          'status': status,
          'activities': activities,  // Storing activities array
        });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(collegeCode)
            .collection('collegeClubs')
            .doc(clubId)
            .collection('events')
            .doc(eventId)
            .set({
          'eventId': eventId,  // Save the eventId here
          'name': event['name'],
          'date': event['date'],
          'time': event['time'],
          'venue': event['venue'],
          'collagecode' : collegeCode,
          'posterUrl': event['posterUrl'],
          'clubName': event['clubName'],
          'clubAdmin': event['clubAdmin'],
          'clubLogoUrl': event['clubLogoUrl'],
          'admissionFee': event['admissionFee'],
          'guests': event['guests'],
          'restrictions': event['restrictions'],
          'status': status,
          'activities': activities,  // Storing activities array
        });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(collegeCode)
            .collection('collegeEvents')
            .doc(eventId)
            .set({
          'eventId': eventId,  // Save the eventId here
          'name': event['name'],
          'date': event['date'],
          'time': event['time'],
          'venue': event['venue'],
          'collagecode' : collegeCode,
          'posterUrl': event['posterUrl'],
          'clubName': event['clubName'],
          'clubAdmin': event['clubAdmin'],
          'clubLogoUrl': event['clubLogoUrl'],
          'admissionFee': event['admissionFee'],
          'guests': event['guests'],
          'restrictions': event['restrictions'],
          'status': status,
          'activities': activities,  // Storing activities array
        });

        await FirebaseFirestore.instance
            .collection('allEvents')
            .doc(eventId)
            .set({
          'eventId': eventId,  // Save the eventId here
          'name': event['name'],
          'date': event['date'],
          'time': event['time'],
          'venue': event['venue'],
          'collagecode' : collegeCode,
          'posterUrl': event['posterUrl'],
          'clubName': event['clubName'],
          'clubAdmin': event['clubAdmin'],
          'clubLogoUrl': event['clubLogoUrl'],
          'admissionFee': event['admissionFee'],
          'guests': event['guests'],
          'restrictions': event['restrictions'],
          'status': status,
          'activities': activities,  // Storing activities array
        });

        await FirebaseFirestore.instance
            .collection('allClubs')
            .doc(clubId)
            .collection('myEvents')
            .doc(eventId)
            .set({
          'eventId': eventId,  // Save the eventId here
          'name': event['name'],
          'date': event['date'],
          'time': event['time'],
          'venue': event['venue'],
          'collagecode' : collegeCode,
          'posterUrl': event['posterUrl'],
          'clubName': event['clubName'],
          'clubAdmin': event['clubAdmin'],
          'clubLogoUrl': event['clubLogoUrl'],
          'admissionFee': event['admissionFee'],
          'guests': event['guests'],
          'restrictions': event['restrictions'],
          'status': status,
          'activities': activities,  // Storing activities array
        });
      }

      // Remove the event from eventRequests after updating the status
      await FirebaseFirestore.instance
          .collection('users')
          .doc(collegeCode)
          .collection('eventRequests')
          .doc(eventId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event Successfully updated to $status')),
      );
    } catch (e) {
      print("Error updating event: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error occurred while updating the event')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(collegeCode)
            .collection('eventRequests')
            .doc(eventId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Event not found.'));
          }

          final event = snapshot.data!.data() as Map<String, dynamic>;
          final eventName = event['name'];
          final eventDate = event['date'];
          final eventTime = event['time'];
          final eventVenue = event['venue'];
          final eventPosterUrl = event['posterUrl'];
          final clubName = event['clubName'];
          final clubAdmin = event['clubAdmin'];
          final clubLogoUrl = event['clubLogoUrl'];
          final admissionFee = event['admissionFee'];
          final guests = event['guests'];
          final restrictions = event['restrictions'];
          final activities = event['activities'] is List ? event['activities'] : [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                if (eventPosterUrl != null)
                  Image.network(eventPosterUrl, fit: BoxFit.cover),
                const SizedBox(height: 16),
                Text('Event Name: $eventName', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Date: $eventDate'),
                Text('Time: $eventTime'),
                Text('Venue: $eventVenue'),
                const SizedBox(height: 16),
                Text('Club: $clubName'),
                Text('Admin: $clubAdmin'),
                if (clubLogoUrl != null) ...[
                  const SizedBox(height: 8),
                  CircleAvatar(backgroundImage: NetworkImage(clubLogoUrl), radius: 30),
                ],
                const SizedBox(height: 16),
                Text('Admission Fee: $admissionFee'),
                Text('Guests: $guests'),
                Text('Restrictions: $restrictions'),
                const SizedBox(height: 16),
                if (activities.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Activities:', style: Theme.of(context).textTheme.titleLarge),
                  ...activities.map((activity) => Text(activity)).toList(),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _updateEventStatus('Accepted', context);
                      },
                      child: const Text('Accept'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _updateEventStatus('Rejected', context);
                      },
                      child: const Text('Reject'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
