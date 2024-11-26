import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'announcement_tab.dart';
import 'events_tab.dart';

class ClubDetailsPage extends StatefulWidget {
  final Map<String, dynamic> clubDetails;
  final String collegeCode;

  const ClubDetailsPage({
    Key? key,
    required this.clubDetails,
    required this.collegeCode, required clubId,
  }) : super(key: key);

  @override
  _ClubDetailsPageState createState() => _ClubDetailsPageState();
}

class _ClubDetailsPageState extends State<ClubDetailsPage> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF101112),
      appBar: AppBar(
        title: Text(
          widget.clubDetails['name'] ?? 'Club Details',
          style: TextStyle(color: Color(0xFFF9AA33)),
        ),
        backgroundColor: Color(0xFF101112),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClubLogo(
                widget.clubDetails['logoUrl'], widget.clubDetails['name'] ?? 'Unnamed Club'),
            const SizedBox(height: 20),
            // Horizontal Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabButton(0, 'About Us'),
                  const SizedBox(width: 10),
                  _buildTabButton(1, 'Explore_Events'),
                  const SizedBox(width: 10),
                  _buildTabButton(2, 'Announcements'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Display Content based on the selected tab
            if (_selectedTabIndex == 0) _buildAboutUsSection(),
            if (_selectedTabIndex == 1)
              EventsTab(
                clubDetails: widget.clubDetails,
                clubId: widget.clubDetails['id'], // Pass the clubId here
              ),
            if (_selectedTabIndex == 2) AnnouncementsTab(clubDetails: widget.clubDetails),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: _selectedTabIndex == index ? Color(0xFFF9AA33) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: _selectedTabIndex == index ? Colors.black : Color(0xFFF9AA33),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildClubLogo(String? logoUrl, String clubName) {
    return Container(
      width: double.infinity,
      height: 200,
      alignment: Alignment.bottomLeft,
      child: Stack(
        fit: StackFit.expand,
        children: [
          logoUrl != null && logoUrl.isNotEmpty
              ? Image.network(logoUrl, fit: BoxFit.cover)
              : Image.asset('assets/images/default_club_logo.png', fit: BoxFit.cover),
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            top: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                clubName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(blurRadius: 10.0, color: Colors.black, offset: Offset(2.0, 2.0)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutUsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Club Information', Color(0xFFF9AA33)),
        _buildInfoRow('Name', widget.clubDetails['name'] ?? 'Unnamed Club'),
        _buildInfoRow('Category', widget.clubDetails['category'] ?? 'Uncategorized'),
        _buildInfoRow('Description', widget.clubDetails['description'] ?? 'No description provided'),
        _buildInfoRow('Created At', _formatDate(widget.clubDetails['createdAt'])),
        const SizedBox(height: 20),
        _buildSectionHeader('Admin Information', Color(0xFFF9AA33)),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: _buildAdminInfo(
            widget.clubDetails['adminProfilePic'],
            widget.clubDetails['adminName'],
            widget.clubDetails['adminBranch'],
            widget.clubDetails['adminRollNumber'],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildAdminInfo(String? profilePicUrl, String? adminName, String? adminBranch, String? adminRollNumber) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        profilePicUrl != null && profilePicUrl.isNotEmpty
            ? CircleAvatar(radius: 50, backgroundImage: NetworkImage(profilePicUrl))
            : const CircleAvatar(radius: 50, backgroundImage: AssetImage('assets/images/default_profile_pic.png')),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Admin Name', adminName ?? 'Unknown Leader'),
              _buildInfoRow('Admin Branch', adminBranch ?? 'No branch'),
              _buildInfoRow('Admin Roll Number', adminRollNumber ?? 'No roll number'),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Not available';
    final dateTime = timestamp.toDate();
    return DateFormat.yMMMd().add_jm().format(dateTime);
  }
}
