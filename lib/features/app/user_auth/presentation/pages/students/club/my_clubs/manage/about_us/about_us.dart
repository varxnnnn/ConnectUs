import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class about_us extends StatelessWidget {
  final Map<String, dynamic> clubDetails;
  final String collegeCode;
  final String rollNumber;

  const about_us({
    Key? key,
    required this.clubDetails,
    required this.collegeCode,
    required this.rollNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format the creation date
    String createdAt = _formatDate(clubDetails['createdAt']);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1920), // Dark background color
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Club Logo with Shadow
              _buildClubLogo(clubDetails['logoUrl'], clubDetails['name'] ?? 'Unnamed Club'),
              const SizedBox(height: 24),

              // Club Name with Decorative Divider
              Center(
                child: Column(
                  children: [
                    Text(
                      clubDetails['name'] ?? 'Unnamed Club',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D6EC5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 2,
                      width: 100,
                      color: const Color(0xFF0D6EC5), // Accent color divider
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Club Category
              _buildInfoRow(
                icon: Icons.category,
                title: 'Category',
                content: clubDetails['category'] ?? 'Uncategorized',
              ),
              const SizedBox(height: 16),

              // Club Description
              _buildInfoRow(
                icon: Icons.description,
                title: 'Description',
                content: clubDetails['description'] ?? 'No description available.',
              ),
              const SizedBox(height: 16),

              // Created At
              _buildInfoRow(
                icon: Icons.calendar_today,
                title: 'Created At',
                content: createdAt,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to build the club logo with shadow effect
  Widget _buildClubLogo(String? logoUrl, String clubName) {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF0D1920),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        image: logoUrl != null && logoUrl.isNotEmpty
            ? DecorationImage(
          image: NetworkImage(logoUrl),
          fit: BoxFit.cover,
        )
            : const DecorationImage(
          image: AssetImage('assets/images/default_club_logo.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // Method to build information row with icon, title, and content
  Widget _buildInfoRow({required IconData icon, required String title, required String content}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: const Color(0xFF0D6EC5), // Accent color for icons
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Method to format the createdAt date
  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Not available';
    final dateTime = timestamp.toDate();
    return DateFormat.yMMMd().add_jm().format(dateTime);
  }
}
