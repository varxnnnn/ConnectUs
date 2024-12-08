import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'StudentDetailsPage.dart';

class StudentsRequestsPage extends StatelessWidget {
  final String collegeCode;

  const StudentsRequestsPage({Key? key, required this.collegeCode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            TabBar(
              tabs: const [
                Tab(text: 'My Students'),
                Tab(text: 'Student Requests'),
              ],
              indicatorColor: Color(0xFF0D6EC5), // Bright indicator color
              labelColor: Color(0xFF0D6EC5), // Bright label color for active tabs
              unselectedLabelColor: Color(0xFFCACAD5), // Bright inactive tab color
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: My Students
                  MyStudentsTab(collegeCode: collegeCode),

                  // Tab 2: Student Requests
                  StudentRequestsTab(collegeCode: collegeCode),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyStudentsTab extends StatelessWidget {
  final String collegeCode;

  const MyStudentsTab({Key? key, required this.collegeCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(collegeCode)
          .collection('students')
          .where('verification', isEqualTo: 'Verified')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No verified students found.'));
        }

        final students = snapshot.data!.docs;

        return ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index].data() as Map<String, dynamic>;
            final studentName = student['name'] ?? 'Unnamed';
            final studentRollNumber = student['rollNumber'] ?? 'Unknown';
            final profilePictureUrl = student['profilePictureUrl'] ?? '';


            return ListTile(
              leading: CircleAvatar(
                backgroundImage: profilePictureUrl.isNotEmpty
                    ? NetworkImage(profilePictureUrl)
                    : const AssetImage('assets/default_avatar.png')
                as ImageProvider,
              ),
              title: Text(
                studentName,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Roll Number: $studentRollNumber',
                style: const TextStyle(color: Colors.grey),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentDetailsPage(
                      rollNumber: studentRollNumber,
                      collegeCode: collegeCode,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class StudentRequestsTab extends StatelessWidget {
  final String collegeCode;

  const StudentRequestsTab({Key? key, required this.collegeCode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(collegeCode)
          .collection('students')
          .where('verification', isEqualTo: 'Pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No student requests found.'));
        }

        final students = snapshot.data!.docs;

        return ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index].data() as Map<String, dynamic>;
            final studentName = student['name'] ?? 'Unnamed';
            final studentRollNumber = student['rollNumber'] ?? 'Unknown';
            final profilePictureUrl = student['profilePictureUrl'] ?? '';
            final uid = student['uid'] ?? 'no';

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: profilePictureUrl.isNotEmpty
                    ? NetworkImage(profilePictureUrl)
                    : const AssetImage('assets/default_avatar.png')
                as ImageProvider,
              ),
              title: Text(
                studentName,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Roll Number: $studentRollNumber',
                style: const TextStyle(color: Colors.grey),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentDetailsPage(
                      rollNumber: studentRollNumber,
                      collegeCode: collegeCode,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
