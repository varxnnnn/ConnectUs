import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore for Timestamp
import 'package:fluttertoast/fluttertoast.dart';

class ClubRequestDetailsPage extends StatefulWidget {
  final Map<String, dynamic> clubDetails;
  final String collegeCode;

  static const Color primaryColor = Color(0xFFFFFDFD); // Dark primary color
  static const Color secondaryColor = Color(0xFFA60000); // Light secondary color
  static const Color darkColor = Colors.black; // Text on dark backgrounds
  static const Color grayColor = Color(0xFF7D7F88); // Gray for secondary text
  static const Color accentColor = Color(0xFF7E6377); // Accent color for buttons

  const ClubRequestDetailsPage({
    Key? key,
    required this.clubDetails,
    required this.collegeCode,
  }) : super(key: key);

  @override
  _ClubRequestDetailsPageState createState() =>
      _ClubRequestDetailsPageState();
}

class _ClubRequestDetailsPageState extends State<ClubRequestDetailsPage> {
  int _selectedTabIndex = 0; // Track the selected tab index (0 for About Us, 1 for Admin Info)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClubRequestDetailsPage.primaryColor, // Set page background color to primaryColor
      appBar: AppBar(
        title: Text(
          '${widget.clubDetails['name'] ?? 'Club Details'}',
          style: TextStyle(color: ClubRequestDetailsPage.secondaryColor), // Change title color
        ),
        backgroundColor: ClubRequestDetailsPage.primaryColor,
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
            _buildSectionHeader('Club Information', ClubRequestDetailsPage.secondaryColor), // Change color to secondaryColor
            _buildInfoRow('Name', widget.clubDetails['name'] ?? 'Unnamed Club'),
            _buildInfoRow('Category', widget.clubDetails['category'] ?? 'Uncategorized'),
            _buildInfoRow('Description', widget.clubDetails['description'] ?? 'No description provided'),
            _buildInfoRow('Created At', _formatDate(widget.clubDetails['createdAt'])), // Add Created At
            const SizedBox(height: 20),
            // Conditional rendering of Admin Information based on _selectedTabIndex
            if (_selectedTabIndex == 0)
              _buildSectionHeader('Admin Information', ClubRequestDetailsPage.secondaryColor),
            if (_selectedTabIndex == 0)
              Padding(
                padding: const EdgeInsets.only(top: 16.0), // Add top padding here
                child: _buildAdminInfo(
                    widget.clubDetails['adminProfilePic'],
                    widget.clubDetails['adminName'],
                    widget.clubDetails['adminBranch'],
                    widget.clubDetails['adminRollNumber']),
              ),
            const SizedBox(height: 40), // Space before the buttons
            // Accept and Reject buttons at the bottom
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _acceptRequest(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Row(
                    children: const [
                      Icon(Icons.check),
                      SizedBox(width: 5),
                      Text('Accept'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _rejectRequest(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Row(
                    children: const [
                      Icon(Icons.clear),
                      SizedBox(width: 5),
                      Text('Reject'),
                    ],
                  ),
                ),
              ],
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
      color: Colors.blue, // Background color for the entire section
      alignment: Alignment.bottomLeft, // Align text to the bottom left
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Display the logo image if it exists
          logoUrl != null && logoUrl.isNotEmpty
              ? Image.network(
            logoUrl,
            fit: BoxFit.cover,
          )
              : Image.asset(
            'assets/images/default_club_logo.png',
            fit: BoxFit.cover,
          ),
          // Add gradient overlay
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
                  colors: [
                    Colors.black.withOpacity(0.5), // Faded color (black with opacity)
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Overlay with the club name at the bottom left with highlight effect
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
                  ], // Shadow effect for better contrast
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: color, // Use the provided color
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // New widget to display Admin Profile Pic on the left, and Admin info on the right.
  Widget _buildAdminInfo(String? profilePicUrl, String? adminName, String? adminBranch, String? adminRollNumber) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Admin profile picture
        profilePicUrl != null && profilePicUrl.isNotEmpty
            ? CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(profilePicUrl),
        )
            : const CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage('assets/images/default_profile_pic.png'),
        ),
        const SizedBox(width: 16), // Add some space between profile and details
        // Admin details
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

  // Function to accept the request
  Future<void> _acceptRequest() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final clubDetails = widget.clubDetails;

      // Reference to the request document using the `clubId`
      final requestRef = firestore
          .collection('users')
          .doc(widget.collegeCode)
          .collection('clubRequests')
          .doc(clubDetails['clubId']); // Using clubId as the document ID

      // Get the request document
      final requestDoc = await requestRef.get();

      if (!requestDoc.exists) {
        print('Request with clubId ${clubDetails['clubId']} does not exist.');
        Fluttertoast.showToast(msg: 'Request does not exist.');
        return;
      }

      // Get the data from the request document
      final requestData = requestDoc.data() as Map<String, dynamic>;

      // Add the collegeCode to the data before storing it
      requestData['collegeCode'] = widget.collegeCode;

      // Get the admin roll number directly from the widget's clubDetails
      String? adminRollNumber = clubDetails['adminRollNumber'];
      if (adminRollNumber == null) {
        Fluttertoast.showToast(msg: 'Admin roll number not found.');
        return;
      }

      // Reference for the 'myClubs' collection under the admin's roll number
      final myClubsCollection = firestore
          .collection('users')
          .doc(widget.collegeCode)
          .collection('students')
          .doc(adminRollNumber) // Use adminRollNumber here
          .collection('myClubs');

      // Use clubId from requestData or clubDetails as the unique identifier for the club
      final clubId = clubDetails['clubId'];

      // Accept the request by moving data to the myClubs collection under the admin's roll number
      await myClubsCollection.doc(clubId).set(requestData);

      // Add the club to the 'collegeClubs' collection under the collegeCode
      final clubsCollection = firestore
          .collection('users')
          .doc(widget.collegeCode)
          .collection('collegeClubs')
          .doc(clubId); // Use clubId as the document ID

      // Set the data for the collegeClubs collection
      await clubsCollection.set(requestData);

      final clubCollection = firestore
          .collection('allClubs')
          .doc(clubId); // Use clubId as the document ID

      await clubCollection.set(requestData);

      // Optionally delete the request after accepting it
      await requestRef.delete();

      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Club request accepted successfully.');
    } catch (e) {
      print('Error accepting club request: $e');
      Fluttertoast.showToast(msg: 'Failed to accept request: $e');
    }
  }

  // Function to reject the request
  Future<void> _rejectRequest() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final clubDetails = widget.clubDetails;

      // Reference to the request document using the `clubId`
      final requestRef = firestore
          .collection('users')
          .doc(widget.collegeCode)
          .collection('clubRequests')
          .doc(clubDetails['clubId']); // Using clubId as the document ID

      // Delete the request document
      await requestRef.delete();

      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Club request rejected.');
    } catch (e) {
      print('Error rejecting club request: $e');
      Fluttertoast.showToast(msg: 'Failed to reject request: $e');
    }
  }
}
