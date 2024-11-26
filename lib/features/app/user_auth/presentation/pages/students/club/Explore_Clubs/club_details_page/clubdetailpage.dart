import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  int? _memberCount;

  // Firestore reference for the club members
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchMemberCount();
  }

  // Function to fetch the member count from Firestore
  Future<void> _fetchMemberCount() async {
    final clubId = widget.clubDetails['id'];
    try {
      // Fetch the club document and get the member list
      final clubDoc = await _firestore.collection('allClubs').doc(clubId).get();
      final members = clubDoc.data()?['members'] ?? [];
      setState(() {
        _memberCount = members.length; // Set the member count
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching member count: $e')));
    }
  }

  // Function to handle joining the club
  Future<void> _joinClub() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final clubId = widget.clubDetails['id'];
    final adminId = widget.clubDetails['adminId'];
    final adminRollNumber = widget.clubDetails['adminRollNumber'];

    try {
      if (userId == adminId) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You cannot join the club as you are the admin.')),
        );
        return; // Prevent the user from joining the club if they are the admin
      }

      // Update the club's member list
      await _firestore
          .collection('allClubs')
          .doc(clubId)
          .update({
        'members': FieldValue.arrayUnion([userId]), // Add the user to the members list
      });
      await _firestore
          .collection('users')
          .doc(widget.collegeCode)
          .collection('students')
          .doc(adminRollNumber) // Using the current user's ID
          .collection('myClubs')
          .doc(clubId)
          .update({
        'members': FieldValue.arrayUnion([userId]), // Add the user to the members list
      });
      await _firestore
          .collection('users')
          .doc(widget.collegeCode)
          .collection('collegeClubs')
          .doc(clubId)
          .update({
        'members': FieldValue.arrayUnion([userId]), // Add the user to the members list
      });
      // Optionally show a success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You have joined the club!')));
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error joining the club: $e')));
    }
  }

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
                  _buildTabButton(1, 'Events'),
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
            if (_selectedTabIndex == 2) AnnouncementsTab(clubDetails: widget.clubDetails,),
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
        // Display the member count below the Created At section
        _buildInfoRow('Members Count', _memberCount?.toString() ?? '0'),
        // Display the college code
        _buildInfoRow('College Code', widget.collegeCode),
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
        const SizedBox(height: 20),
        // Join Club Button
        ElevatedButton(
          onPressed: _joinClub,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFF9AA33), // Button color
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text(
            'Join Club',
            style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
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
        style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.white),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminInfo(String? profilePic, String adminName, String adminBranch, String adminRollNumber) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: profilePic != null && profilePic.isNotEmpty
              ? NetworkImage(profilePic)
              : AssetImage('assets/images/default_avatar.png') as ImageProvider,
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(adminName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(adminBranch, style: TextStyle(fontSize: 14, color: Colors.white)),
            Text(adminRollNumber, style: TextStyle(fontSize: 14, color: Colors.white)),
          ],
        ),
      ],
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000);
    return DateFormat.yMMMd().format(date);
  }
}
