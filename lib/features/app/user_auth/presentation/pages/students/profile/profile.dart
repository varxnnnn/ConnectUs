import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  static const Color primaryColor = Color(0xFF0D1920); // Updated background color
  static const Color secondaryColor = Color(0xFF0D6EC5);
  static const Color grayColor = Color(0xFF8A969B);
  static const Color textColor = Color(0xFFECE6E6);

  final Map<String, String> collegeNames = {
    'VGNT': 'Vignan',
    'MGIT': 'Mahatma Gandhi Institute',
    'HOLY': 'Holy Mary',
    'SNITS': 'Sreenidhi College',
    'GRRR': 'Gurunanak',
    'CMR': 'CMR College',
  };

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("  Profile Page"),
        backgroundColor: primaryColor,
        foregroundColor: secondaryColor,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: primaryColor, // Set background color to the updated value
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('allUsers')
            .doc(user?.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("User data not found."));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final collegeCode = userData['collegeCode'] ?? 'N/A';
          final collegeName = collegeNames[collegeCode] ?? 'Unknown College';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              color: primaryColor,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Profile picture and details row
                  Row(
                    children: [
                      // Profile picture
                      userData['profilePictureUrl'] != null &&
                          userData['profilePictureUrl']!.isNotEmpty
                          ? ClipOval(
                        child: Image.network(
                          userData['profilePictureUrl'],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                    : null,
                                color: secondaryColor,
                              ),
                            );
                          },
                        ),
                      )
                          : ClipOval(
                        child: Image.asset(
                          'assets/default_avatar.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Profile details (Username and Branch)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData['name'] ?? 'N/A',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Branch: ${userData['branch'] ?? 'N/A'}",
                              style: TextStyle(
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // College Info Section
                  _buildSectionHeader("College Info"),
                  _buildProfileInfo("College Code", collegeCode),
                  _buildProfileInfo("College Name", collegeName),
                  _buildProfileInfo("Roll Number", userData['rollNumber'] ?? 'N/A'),

                  const SizedBox(height: 16),

                  // Contact Info Section
                  _buildSectionHeader("Contact Info"),
                  _buildProfileInfo("Email", user?.email ?? 'Not signed in'),
                  _buildProfileInfo("Phone Number", userData['phone'] ?? 'N/A'),
                  _buildProfileInfo("Location", userData['location'] ?? 'N/A'),
                  _buildProfileInfo("Bio", userData['bio'] ?? 'N/A'),

                  const SizedBox(height: 16),

                  // Verification Section
                  _buildSectionHeader("Verification"),
                  _buildProfileInfo("Status", userData['verification'] ?? 'Pending'),

                  const SizedBox(height: 20),

                  // Sign Out Button
                  ElevatedButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut().then((_) {
                        Navigator.pushReplacementNamed(context, '/login');
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      backgroundColor: secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Sign Out",
                      style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper method to build profile info rows
  Widget _buildProfileInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: grayColor),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: textColor),
          ),
        ],
      ),
    );
  }

  // Helper method to build section headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: secondaryColor,
          ),
        ),
      ),
    );
  }
}
