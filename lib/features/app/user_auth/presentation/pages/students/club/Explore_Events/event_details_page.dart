import 'package:flutter/material.dart';

class EventDetailsPage extends StatelessWidget {
  final Map<String, dynamic> eventDetails;

  const EventDetailsPage({Key? key, required this.eventDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define colors
    const Color backgroundColor = Color(0xFF0D1920);
    const Color primaryColor = Color(0xFFECE6E6);
    const Color secondaryColor = Color(0xFF0D6EC5);
    const Color textColor = Colors.white;
    const Color secondaryTextColor =Color(0xFF86B2D8);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          eventDetails['name'] ?? 'Event Details',
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
            _buildPosterSection(eventDetails['posterUrl'], context),
            const SizedBox(height: 20),
            _buildSectionHeader('Event Details', secondaryColor),
            const SizedBox(height: 10),
            _buildInfoRow('Name', eventDetails['name'] ?? 'Unnamed Event', textColor, secondaryTextColor),
            _buildInfoRow('Date', eventDetails['date'] ?? 'N/A', textColor, secondaryTextColor),
            _buildInfoRow('Time', eventDetails['time'] ?? 'N/A', textColor, secondaryTextColor),
            _buildInfoRow('Venue', eventDetails['venue'] ?? 'N/A', textColor, secondaryTextColor),
            _buildInfoRow('Admission Fee', eventDetails['admissionFee'] ?? 'Free', textColor, secondaryTextColor),
            _buildInfoRow('Guests', eventDetails['guests'] ?? 'No guests listed', textColor, secondaryTextColor),
            _buildInfoRow('Restrictions', eventDetails['restrictions'] ?? 'No restrictions', textColor, secondaryTextColor),
            _buildInfoRow('College Code', eventDetails['collagecode'] ?? 'N/A', textColor, secondaryTextColor),
            const SizedBox(height: 20),
            _buildSectionHeader('Club Details', secondaryColor),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildClubLogo(eventDetails['clubLogoUrl']),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Club Name', eventDetails['clubName'] ?? 'N/A', textColor, secondaryTextColor),
                      _buildInfoRow('Club Admin', eventDetails['clubAdmin'] ?? 'N/A', textColor, secondaryTextColor),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionHeader('Activities', secondaryColor),
            const SizedBox(height: 10),
            _buildActivitiesList(eventDetails['activities'] ?? [], textColor, secondaryColor),
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
                            child: const Icon(
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
          color: const Color(0xFF7D7F88),
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

  Widget _buildSectionHeader(String title, Color secondaryColor) {
    return Text(
      title,
      style: TextStyle(
        color: secondaryColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color textColor, Color secondaryTextColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: secondaryTextColor,
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

  Widget _buildActivitiesList(List<dynamic> activities, Color textColor, Color secondaryColor) {
    if (activities.isEmpty) {
      return Text(
        'No activities available.',
        style: TextStyle(color: textColor, fontSize: 16),
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
              Text(
                '•',
                style: TextStyle(
                  color: secondaryColor,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  activity,
                  style: TextStyle(color: textColor, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
