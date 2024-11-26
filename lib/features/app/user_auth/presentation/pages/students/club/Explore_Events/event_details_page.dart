import 'package:flutter/material.dart';

class EventDetailsPage extends StatelessWidget {
  final Map<String, dynamic> eventDetails;

  const EventDetailsPage({Key? key, required this.eventDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0E0E), // Dark background
      appBar: AppBar(
        title: Text(
          eventDetails['name'] ?? 'Event Details',
          style: const TextStyle(color: Color(0xFFF9AA33)), // Secondary color
        ),
        backgroundColor: const Color(0xFF1F2628), // Dark primary color
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPosterSection(eventDetails['posterUrl'], context),
            const SizedBox(height: 20),
            _buildSectionHeader('Event Details'),
            const SizedBox(height: 10),
            _buildInfoRow('Name', eventDetails['name'] ?? 'Unnamed Event'),
            _buildInfoRow('Date', eventDetails['date'] ?? 'N/A'),
            _buildInfoRow('Time', eventDetails['time'] ?? 'N/A'),
            _buildInfoRow('Venue', eventDetails['venue'] ?? 'N/A'),
            _buildInfoRow('Admission Fee', eventDetails['admissionFee'] ?? 'Free'),
            _buildInfoRow('Guests', eventDetails['guests'] ?? 'No guests listed'), // Guests row
            _buildInfoRow('Restrictions', eventDetails['restrictions'] ?? 'No restrictions'), // Restrictions row
            _buildInfoRow('College Code', eventDetails['collagecode'] ?? 'N/A'), // Display collegeCode
            const SizedBox(height: 20),
            _buildSectionHeader('Club Details'),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildClubLogo(eventDetails['clubLogoUrl']),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Club Name', eventDetails['clubName'] ?? 'N/A'),
                      _buildInfoRow('Club Admin', eventDetails['clubAdmin'] ?? 'N/A'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionHeader('Activities'),
            const SizedBox(height: 10),
            _buildActivitiesList(eventDetails['activities'] ?? []),
          ],
        ),
      ),
    );
  }

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
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(posterUrl),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 30,
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
          color: const Color(0xFF7D7F88), // Gray fallback color
        ),
        child: posterUrl == null
            ? const Center(
          child: Text(
            'No Poster Available',
            style: TextStyle(color: Colors.white, fontSize: 16),
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
        color: Color(0xFFF9AA33), // Secondary color
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
              style: const TextStyle(
                color: Color(0xFF7D7F88), // Gray for secondary text
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
        style: TextStyle(color: Colors.white, fontSize: 16),
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
                '•', // Unicode bullet character
                style: TextStyle(
                  color: Color(0xFFF9AA33), // Secondary color
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  activity,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
