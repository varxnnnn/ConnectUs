import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventDetailsPage extends StatelessWidget {
  final String eventId;
  final String clubId;

  const EventDetailsPage({Key? key, required this.eventId, required this.clubId}) : super(key: key);

  // Define color constants
  static const Color primaryColor = Color(0xFF1F2628);
  static const Color secondaryColor = Color(0xFF0D6EC5);
  static const Color textColor = Colors.white;
  static const Color grayColor = Color(
      0xFF86B2D8);
  static const Color backgroundColor = Color(0xFF0D1920);

  // Fetch event details from Firestore
  Future<Map<String, dynamic>> _getEventDetails() async {
    try {
      DocumentSnapshot eventSnapshot = await FirebaseFirestore.instance
          .collection('allClubs')
          .doc(clubId)
          .collection('myEvents')
          .doc(eventId)
          .get();

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

        final event = snapshot.data!;

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: Text(
              event['name'] ?? 'Event Details',
              style: const TextStyle(color: secondaryColor),
            ),
            backgroundColor: backgroundColor,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPosterSection(event['posterUrl'], context),
                const SizedBox(height: 20),
                _buildSectionHeader('Event Details'),
                const SizedBox(height: 10),
                _buildInfoRow('Name', event['name'] ?? 'Unnamed Event'),
                _buildInfoRow('Date', event['date'] ?? 'N/A'),
                _buildInfoRow('Time', event['time'] ?? 'N/A'),
                _buildInfoRow('Venue', event['venue'] ?? 'N/A'),
                _buildInfoRow('Admission Fee', event['admissionFee'] ?? 'Free'),
                _buildInfoRow('Guests', event['guests'] ?? 'No guests listed'),
                _buildInfoRow('Restrictions', event['restrictions'] ?? 'No restrictions'),
                _buildInfoRow('College Code', event['collegeCode'] ?? 'N/A'),
                const SizedBox(height: 20),
                _buildSectionHeader('Club Details'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildClubLogo(event['clubLogoUrl']),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('Club Name', event['clubName'] ?? 'N/A'),
                          _buildInfoRow('Club Admin', event['clubAdmin'] ?? 'N/A'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSectionHeader('Activities'),
                const SizedBox(height: 10),
                _buildActivitiesList(event['activities'] ?? []),
              ],
            ),
          ),
        );
      },
    );
  }

  // Poster Section with Full-Screen View
  Widget _buildPosterSection(String? posterUrl, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (posterUrl != null) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                backgroundColor: Colors.transparent,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: InteractiveViewer(
                    child: Image.network(posterUrl, fit: BoxFit.contain),
                  ),
                ),
              );
            },
          );
        }
      },
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: posterUrl != null
              ? DecorationImage(image: NetworkImage(posterUrl), fit: BoxFit.cover)
              : null,
          color: grayColor, // Fallback color
        ),
        child: posterUrl == null
            ? const Center(
          child: Text(
            'No Poster Available',
            style: TextStyle(color: Color(
                0xFF86B2D8), fontSize: 16),
          ),
        )
            : null,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: secondaryColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: grayColor,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClubLogo(String? clubLogoUrl) {
    return CircleAvatar(
      radius: 30,
      backgroundImage: clubLogoUrl != null && clubLogoUrl.isNotEmpty
          ? NetworkImage(clubLogoUrl)
          : const AssetImage('assets/images/default_club_logo.png') as ImageProvider,
    );
  }

  Widget _buildActivitiesList(List<dynamic> activities) {
    if (activities.isEmpty) {
      return const Text(
        'No activities available.',
        style: TextStyle(color: Color(
            0xFF86B2D8), fontSize: 16),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: activities.map((activity) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '•',
                style: TextStyle(color: secondaryColor, fontSize: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  activity,
                  style: const TextStyle(color: Color(
                      0xFF86B2D8), fontSize: 16),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
