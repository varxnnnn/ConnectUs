import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'createClubPage.dart';
import 'manage/manageclub.dart'; // Import ManageClubPage

class MyClubsPage extends StatefulWidget {
  final String collegeCode;
  final String rollNumber;

  const MyClubsPage({Key? key, required this.collegeCode, required this.rollNumber}) : super(key: key);

  @override
  _MyClubsPageState createState() => _MyClubsPageState();
}

class _MyClubsPageState extends State<MyClubsPage> {
  Stream<List<Map<String, dynamic>>> _fetchUserClubs() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.collegeCode)
        .collection('students')
        .doc(widget.rollNumber)
        .collection('myClubs')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {...data, 'id': doc.id};
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _fetchUserClubs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final userClubs = snapshot.data ?? [];

                return userClubs.isEmpty
                    ? const Center(child: Text('You have not created any clubs.'))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemCount: userClubs.length,
                  itemBuilder: (context, index) {
                    final club = userClubs[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ManageClubPage(
                                clubDetails: club,
                                collegeCode: widget.collegeCode,
                                rollNumber: widget.rollNumber,
                              ),
                            ),
                          );
                        },
                        child: SizedBox(
                          height: 150,
                          child: Stack(
                            children: [
                              Row(
                                children: [
                                  // Left 75%: Logo image
                                  Expanded(
                                    flex: 3,
                                    child: club['logoUrl'] != null
                                        ? Image.network(
                                      club['logoUrl'],
                                      fit: BoxFit.cover,
                                    )
                                        : Container(
                                      color: Colors.grey,
                                      child: const Icon(
                                        Icons.photo,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                    ),
                                  ),
                                  // Right 25%: Solid white background for club details
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              // Center overlay gradient
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.white.withOpacity(0.9),
                                        Colors.white,
                                      ],
                                      stops: [0.2, 0.6, 0.8],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                ),
                              ),
                              // Club details text
                              Positioned(
                                right: 8,
                                top: 8,
                                bottom: 8,
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.25,
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        club['name'] ?? 'Unnamed Club',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Category: ${club['category'] ?? 'No Category Available'}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        'Members: ${club['membersCount'] ?? 'N/A'}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 8,
                                bottom: 8,
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.black.withOpacity(0.7),
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            // Fetch the user's verification status
            final studentDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(widget.collegeCode)
                .collection('students')
                .doc(widget.rollNumber)
                .get();

            if (!studentDoc.exists) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Student record not found.')),
              );
              return;
            }

            final studentData = studentDoc.data() as Map<String, dynamic>;
            final verificationStatus = studentData['verification'] ?? 'Pending';

            if (verificationStatus == 'Verified') {
              // If verified, navigate to CreateClubPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateClubPage(
                    collegeCode: widget.collegeCode,
                  ),
                ),
              );
            } else {
              // If not verified, show an error message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('You must be verified to create a club.')),
              );
            }
          } catch (e) {
            // Handle errors
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        },
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFF0D6EC5),
      ),

    );
  }
}
