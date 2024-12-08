import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'announcement_tab.dart';
import 'events_tab.dart';

class ClubDetailsPage extends StatefulWidget {
  final Map<String, dynamic> clubDetails;
  final String collegeCode;
  final String CrollNumber;

  const ClubDetailsPage({
    Key? key,
    required this.clubDetails,
    required this.collegeCode,
    required clubId,
    required this.CrollNumber,
  }) : super(key: key);

  @override
  _ClubDetailsPageState createState() => _ClubDetailsPageState();
}

class _ClubDetailsPageState extends State<ClubDetailsPage> {
  int _selectedTabIndex = 0;
  int? _memberCount;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  static const Color primaryColor = Color(
      0xFF0D6EC5); // Selected icon and label
  static const Color secondaryColor = Color(
      0xFF86B2D8); // Hover/transition color
  static const Color grayColor = Color(
      0xFFE9ECED); // Unselected icons and labels
  static const Color navBackgroundColor = Color(
      0xFF11232C); // Background of the bottom navigation bar
  static const Color darkColor = Colors.white; // White text
  static const Color darkText = Colors.black; // Black text


  @override
  void initState() {
    super.initState();
    _fetchMemberCount();
  }

  Future<void> _fetchMemberCount() async {
    final clubId = widget.clubDetails['id'];
    try {
      final clubDoc = await _firestore.collection('allClubs').doc(clubId).get();
      final members = clubDoc.data()?['members'] ?? [];
      setState(() {
        _memberCount = members.length;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching member count: $e')),
      );
    }
  }

  Future<void> _joinClub() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final clubId = widget.clubDetails['id'];
    final adminId = widget.clubDetails['adminId'];
    final adminRollNumber = widget.clubDetails['adminRollNumber'];
    final collegeCode = widget.clubDetails['collegeCode'];

    try {
      // Check if the user is the admin, prevent joining if true
      if (userId == adminId) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('You cannot join the club as you are the admin.')),
        );
        return;
      }

      // Check if the club document exists, create it if missing
      var clubDoc = await _firestore.collection('allClubs').doc(clubId).get();
      if (!clubDoc.exists) {
        await _firestore.collection('allClubs').doc(clubId).set({
          'members': [userId], // Initialize the 'members' array if missing
        });
      } else {
        await _firestore.collection('allClubs').doc(clubId).update({
          'members': FieldValue.arrayUnion([userId]),
          // Add the user to the 'members' array
        });
      }

      // Check if the admin's club document exists and create it if missing
      var adminClubDoc = await _firestore
          .collection('users')
          .doc(collegeCode)
          .collection('students')
          .doc(adminRollNumber)
          .collection('myClubs')
          .doc(clubId)
          .get();

      if (!adminClubDoc.exists) {
        await _firestore
            .collection('users')
            .doc(collegeCode)
            .collection('students')
            .doc(adminRollNumber)
            .collection('myClubs')
            .doc(clubId)
            .set({
          'members': [userId], // Initialize the 'members' array if missing
        });
      } else {
        await _firestore
            .collection('users')
            .doc(collegeCode)
            .collection('students')
            .doc(adminRollNumber)
            .collection('myClubs')
            .doc(clubId)
            .update({
          'members': FieldValue.arrayUnion([userId]),
          // Add the user to the 'members' array
        });
      }

      // Check if the college's club document exists, create it if missing
      var collegeClubDoc = await _firestore
          .collection('users')
          .doc(collegeCode)
          .collection('collegeClubs')
          .doc(clubId)
          .get();

      if (!collegeClubDoc.exists) {
        await _firestore
            .collection('users')
            .doc(collegeCode)
            .collection('collegeClubs')
            .doc(clubId)
            .set({
          'members': [userId], // Initialize the 'members' array if missing
        });
      } else {
        await _firestore
            .collection('users')
            .doc(collegeCode)
            .collection('collegeClubs')
            .doc(clubId)
            .update({
          'members': FieldValue.arrayUnion([userId]),
          // Add the user to the 'members' array
        });
      }

      // Check if the student's 'JoinedClubs' document exists and create it if missing
      var joinedClubsDoc = await _firestore
          .collection('users')
          .doc(widget.collegeCode)
          .collection('students')
          .doc(widget.CrollNumber)
          .collection('JoinedClubs')
          .doc('ids')
          .get();

      if (!joinedClubsDoc.exists) {
        await _firestore
            .collection('users')
            .doc(widget.collegeCode)
            .collection('students')
            .doc(widget.CrollNumber)
            .collection('JoinedClubs')
            .doc('ids')
            .set({
          'clubids': [clubId], // Initialize the 'clubids' array if missing
        });
      } else {
        await _firestore
            .collection('users')
            .doc(widget.collegeCode)
            .collection('students')
            .doc(widget.CrollNumber)
            .collection('JoinedClubs')
            .doc('ids')
            .update({
          'clubids': FieldValue.arrayUnion([clubId]),
          // Add the clubId to the 'clubids' array
        });
      }

      // Show success message
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('You have joined the club!')));
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error joining the club: $e')));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.clubDetails['name'] ?? 'Club Details',
          style: const TextStyle(
              color: primaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: navBackgroundColor,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0D1920),
        ),
        child: Column(  // Use Column instead of SingleChildScrollView
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClubLogo(
              widget.clubDetails['logoUrl'],
              widget.clubDetails['name'] ?? 'Unnamed Club',
            ),
            const SizedBox(height: 20),
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
            Expanded(  // Ensures content takes remaining space
              child: _selectedTabIndex == 0
                  ? _buildAboutUsSection()
                  : _selectedTabIndex == 1
                  ? EventsTab(
                clubDetails: widget.clubDetails,
                clubId: widget.clubDetails['id'],
              )
                  : AnnouncementsTab(clubDetails: widget.clubDetails),
            ),
          ],
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
              : Image.asset(
              'assets/images/default_club_logo.png', fit: BoxFit.cover),
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
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
          color: _selectedTabIndex == index
              ? const Color(0xFF0D6EC5)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: _selectedTabIndex == index
                ? Colors.white
                : const Color(0xFF0D6EC5),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAboutUsSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                    widget.clubDetails['name'] ?? 'Unnamed Club',
                    const Color(0xFF0D6EC5)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.category, color: secondaryColor, size: 20),
                    const SizedBox(width: 5),
                    Text(
                      widget.clubDetails['category'] ?? 'Uncategorized',
                      style: const TextStyle(
                        fontSize: 18,
                        color: secondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                        Icons.access_time, color: secondaryColor, size: 20),
                    const SizedBox(width: 5),
                    Text(
                      'Established since ${_formatDate(
                          widget.clubDetails['createdAt'])}',
                      style: const TextStyle(
                          fontSize: 16, color: secondaryColor),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSectionHeader('Description ', const Color(0xFF0D6EC5)),
                const SizedBox(height: 4),
                Text(
                  widget.clubDetails['description'] ??
                      'No description provided',
                  style: const TextStyle(fontSize: 16, color: secondaryColor),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.collegeCode} ',
                  style: const TextStyle(fontSize: 16, color: secondaryColor),
                ),
                const SizedBox(height: 8),
                Text(
                  'Club Members: ${_memberCount ?? 0}', // Fixed typo
                  style: const TextStyle(fontSize: 16, color: secondaryColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          _buildSectionHeader('Admin Information', const Color(0xFF0D6EC5)),
          const SizedBox(height: 16),
          _buildAdminInfo(
            widget.clubDetails['adminProfilePic'],
            widget.clubDetails['adminName'],
            widget.clubDetails['adminBranch'],
            widget.clubDetails['adminRollNumber'],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _joinClub,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D6EC5),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              // Adjusted padding for better button size
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Join Club',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20), // Added to ensure spacing at the bottom
        ],
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    final formatter = DateFormat('MMMM dd, yyyy');
    return formatter.format(date);
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 30,
          color: color,
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: grayColor),
        ),
      ],
    );
  }

  Widget _buildAdminInfo(String? profilePicUrl, String? name, String? branch,
      String? rollNumber) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: NetworkImage(profilePicUrl ??
              'https://www.example.com/default_profile_pic.jpg'),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name ?? 'Admin',
              style: const TextStyle(fontSize: 18, color: secondaryColor),
            ),
            const SizedBox(height: 4),
            Text(
              'Branch: $branch',
              style: const TextStyle(fontSize: 16, color: secondaryColor),
            ),
            const SizedBox(height: 4),
            Text(
              'Roll No: $rollNumber',
              style: const TextStyle(fontSize: 16, color: secondaryColor),
            ),
          ],
        ),
      ],
    );
  }
}