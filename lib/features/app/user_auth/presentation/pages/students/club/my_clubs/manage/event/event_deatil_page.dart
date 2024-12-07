import 'package:flutter/material.dart';

class EventDetailPage extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailPage({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event['name'] ?? 'Event Details'),
        backgroundColor: const Color(0xFFECE6E6), // Dark primary color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Poster
              _buildPosterSection(event['posterUrl'], context),
              const SizedBox(height: 16),

              // Club Details Section
              _buildSectionHeader('Club Details'),
              const SizedBox(height: 8),
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

              // New Event Section
              const SizedBox(height: 24),
              _buildSectionHeader('Event Information'),
              const SizedBox(height: 8),
              _buildInfoRow('Name', event['name'] ?? 'N/A'),
              _buildInfoRow('Date', event['date'] ?? 'N/A'),
              _buildInfoRow('Time', event['time'] ?? 'N/A'),
              _buildInfoRow('Venue', event['venue'] ?? 'N/A'),
              _buildInfoRow('Guests', event['guests'] ?? 'N/A'),
              _buildInfoRow('Restrictions', event['restrictions'] ?? 'N/A'),
              _buildInfoRow('Admission Fee', event['admissionFee'] ?? 'Free'),

              // Activities Section
              const SizedBox(height: 24),
              _buildSectionHeader('Activities'),
              const SizedBox(height: 8),
              _buildActivitiesList(event['activities'] ?? []),
            ],
          ),
        ),
      ),
    );
  }

  // Poster Section
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
                              color: Colors.black,
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
          color: const Color(0xFF050505), // Gray fallback color
        ),
        child: posterUrl == null
            ? const Center(
          child: Text(
            'No Poster Available',
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        )
            : null,
      ),
    );
  }

  // Section Header
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFFA60000), // Secondary color
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Info Row (label-value pair)
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
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

  // Club Logo
  Widget _buildClubLogo(String? clubLogoUrl) {
    return CircleAvatar(
      radius: 30,
      backgroundImage: clubLogoUrl != null && clubLogoUrl.isNotEmpty
          ? NetworkImage(clubLogoUrl)
          : const AssetImage('assets/images/default_club_logo.png') as ImageProvider,
    );
  }

  // Activities List
  Widget _buildActivitiesList(List<dynamic> activities) {
    if (activities.isEmpty) {
      return const Text(
        'No activities available.',
        style: TextStyle(color: Colors.black, fontSize: 16),
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
                  color: Color(0xFFA60000), // Secondary color
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  activity,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
