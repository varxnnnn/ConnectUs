import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentDetailsPage extends StatelessWidget {
  final String rollNumber;
  final String collegeCode;

  const StudentDetailsPage({
    Key? key,
    required this.rollNumber,
    required this.collegeCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(collegeCode)
            .collection('students')
            .doc(rollNumber)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Student not found.'));
          }

          // Fetch the student data
          final student = snapshot.data!.data() as Map<String, dynamic>;
          final studentName = student['name'] ?? 'Unnamed';
          final profilePictureUrl = student['profilePictureUrl'] ?? '';
          final branch = student['branch'] ?? 'Unknown';
          final phone = student['phone'] ?? 'Unavailable';
          final email = student['email'] ?? 'Unavailable';
          final bio = student['bio'] ?? 'No bio available';
          final verificationStatus = student['verification'] ?? 'N/A';
          final uid = student['uid'] ?? '';

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: profilePictureUrl.isNotEmpty
                              ? NetworkImage(profilePictureUrl)
                              : const AssetImage('assets/default_avatar.png')
                          as ImageProvider,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        studentName,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Roll Number: $rollNumber',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Branch: $branch',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Email: $email',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Phone: $phone',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bio: $bio',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Verification Status: $verificationStatus',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                if (verificationStatus != 'Verified') // Show Approve button for non-verified students
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      onPressed: () async {
                        try {
                          // Reference to the student document
                          final studentRef = FirebaseFirestore.instance
                              .collection('users')
                              .doc(collegeCode)
                              .collection('students')
                              .doc(rollNumber);

                          // Update the student document's verification status
                          await studentRef.update({'verification': 'Verified'});

                          // Ensure UID is available
                          if (uid.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'UID not found for this student.')),
                            );
                            return;
                          }

                          // Reference to the allUsers document
                          final allUsersRef = FirebaseFirestore.instance
                              .collection('allUsers')
                              .doc(uid);

                          // Update the allUsers document's verification status
                          await allUsersRef.update({'verification': 'Verified'});

                          // Success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Student approved successfully!')),
                          );

                          Navigator.pop(context); // Go back to the previous page
                        } catch (e) {
                          // Error handling
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      },
                      child: const Text(
                        'Approve',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
