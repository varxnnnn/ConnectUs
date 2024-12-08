import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'college_admins.dart'; // Import the new CollegeAdminsSection


// Define colors
const Color primaryColor = Color(0xFF0D6EC5);
const Color cardBackgroundColor = Color(0xFF1E2018);
const Color announcementCardColor = Color(0xFFECE6E6);
const Color announcementTextColor = Color(0xFF131212);

class HotPage extends StatefulWidget {
  final String collegeCode;

  const HotPage({
    Key? key,
    required this.collegeCode, required String rollNumber,
  }) : super(key: key);

  @override
  _HotPageState createState() => _HotPageState();
}

class _HotPageState extends State<HotPage> {
  final List<String> imageList = [
    'assets/1.jpg',
    'assets/2.jpg',
    'assets/3.jpg',
    'assets/4.jpg',
  ];

  Future<List<QueryDocumentSnapshot>> _fetchClubs() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('allClubs')
        .limit(4)
        .get();
    return snapshot.docs;
  }

  Future<List<QueryDocumentSnapshot>> _fetchEvents() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('allEvents')
        .limit(4)
        .get();
    return snapshot.docs;
  }

  Future<List<QueryDocumentSnapshot>> _fetchAnnouncements() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('allAnnouncements')
        .limit(4)
        .get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageCarousel(imageList),
              CollegeCodesSection(collegeCode: widget.collegeCode),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Hot Clubs',
                  style: TextStyle(
                    fontSize: 32,
                    fontFamily: 'Archivo',
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              _buildClubList(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Hot Events',
                  style: TextStyle(
                    fontSize: 32,
                    fontFamily: 'Archivo',
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              _buildEventCarousel(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Hot Announcements',
                  style: TextStyle(
                    fontSize: 32,
                    fontFamily: 'Archivo',
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              _buildAnnouncementList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel(List<String> imagePaths) {
    return CarouselSlider.builder(
      itemCount: imagePaths.length,
      itemBuilder: (BuildContext context, int index, int realIndex) {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imagePaths[index]),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: 200,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        viewportFraction: 1.0,
      ),
    );
  }

  Widget _buildClubList() {
    return FutureBuilder<List<QueryDocumentSnapshot>>(
      future: _fetchClubs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error loading clubs"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No clubs available"));
        } else {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: snapshot.data!.length + 1,
            itemBuilder: (context, index) {
              if (index == snapshot.data!.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFDFD),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextButton(
                      onPressed: () {
                        // Navigate to ClubsPage or relevant route
                      },
                      child: const Text(
                        'See More',
                        style: TextStyle(fontSize: 18, color: primaryColor),
                      ),
                    ),
                  ),
                );
              } else {
                final clubData = snapshot.data![index].data() as Map<String, dynamic>;
                String clubName = clubData['name'] ?? 'Unknown Club';
                String clubLogoUrl = clubData['logoUrl'] ?? '';

                return Card(
                  color: cardBackgroundColor,
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.network(
                          clubLogoUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          clubName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        }
      },
    );
  }

  Widget _buildEventCarousel() {
    return FutureBuilder<List<QueryDocumentSnapshot>>(
      future: _fetchEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error loading events"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No events available"));
        } else {
          return CarouselSlider.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (BuildContext context, int index, int realIndex) {
              final eventData = snapshot.data![index].data() as Map<String, dynamic>;
              String eventName = eventData['name'] ?? 'Unknown Event';
              String clubName = eventData['clubName'] ?? 'Unknown Club';
              String posterUrl = eventData['posterUrl'] ?? '';

              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      posterUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eventName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Club: $clubName',
                          style: const TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            options: CarouselOptions(
              height: 400,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              viewportFraction: 0.9,
              enlargeCenterPage: true,
            ),
          );
        }
      },
    );
  }

  Widget _buildAnnouncementList() {
    return FutureBuilder<List<QueryDocumentSnapshot>>(
      future: _fetchAnnouncements(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error loading announcements"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No announcements available"));
        } else {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final announcementData = snapshot.data![index].data() as Map<String, dynamic>;
              String subject = announcementData['subject'] ?? 'Unknown Subject';
              String content = announcementData['content'] ?? '';
              String clubName = announcementData['clubName'] ?? 'Unknown Club';

              String truncatedContent = content.length > 50 ? '${content.substring(0, 50)}...' : content;

              return Card(
                color: announcementCardColor,
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  title: Text(
                    subject,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: announcementTextColor,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Club: $clubName',
                        style: const TextStyle(
                          fontSize: 14,
                          color: announcementTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        truncatedContent,
                        style: const TextStyle(
                          fontSize: 14,
                          color: announcementTextColor,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navigate to the full announcement details page
                  },
                ),
              );
            },
          );
        }
      },
    );
  }
}
