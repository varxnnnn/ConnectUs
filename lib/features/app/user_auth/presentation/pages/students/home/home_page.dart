import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../club/clubspage.dart';

class HomePage extends StatefulWidget {
  final String collegeCode;
  final String rollnumber;

  const HomePage({
    super.key,
    required this.collegeCode,
    required this.rollnumber,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // List of asset image names
  final List<String> imageList = [
    'assets/1.jpg',
    'assets/2.jpg',
    'assets/3.jpg',
    'assets/4.jpg',
  ];

  Future<List<QueryDocumentSnapshot>> _fetchClubs() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('allClubs')
        .limit(4) // Fetch only 4 items
        .get();
    return snapshot.docs;
  }

  Future<List<QueryDocumentSnapshot>> _fetchAnnouncements() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('allAnnouncements')
        .limit(4) // Fetch only 4 items
        .get();
    return snapshot.docs;
  }

  Future<List<QueryDocumentSnapshot>> _fetchEvents() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('allEvents')
        .limit(4) // Fetch only 4 items
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
              // First Carousel Slider at the top of the page (with images)
              _buildImageCarousel(imageList),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Upcoming Explore Clubs',
                  style: TextStyle(
                    fontSize: 32,
                    fontFamily: 'Archivo',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              // Display list view of clubs
              _buildClubList(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Explore Events',
                  style: TextStyle(
                    fontSize: 32,
                    fontFamily: 'Archivo',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              // Display carousel slides for events after the clubs list
              _buildEventCarousel(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Announcements',
                  style: TextStyle(
                    fontSize: 32,
                    fontFamily: 'Archivo',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              // Display list view of announcements
              _buildAnnouncementList(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the first carousel slider (with images from assets)
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
        height: 200, // Adjust height as necessary
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        viewportFraction: 1.0, // Make the carousel take up the full width
      ),
    );
  }

  /// Builds the carousel slider for the events
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
                  // Event Poster
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    child: Image.network(
                      posterUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  // Overlay for text
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), // Match rounded corners
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.8), // Dark at the bottom
                          Colors.transparent, // Fade to transparent at the top
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  // Event Details
                  Positioned(
                    bottom: 16, // Padding from the bottom
                    left: 16,  // Padding from the left
                    right: 16, // Padding from the right
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
                        const SizedBox(height: 4), // Space between text
                        Text(
                          'Club: $clubName',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            options: CarouselOptions(
              height: 400, // Adjust height for card dimensions
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              viewportFraction: 0.9, // Slight margin on the sides
              enlargeCenterPage: true, // Highlight the center card
            ),
          );
        }
      },
    );
  }

  /// Builds the list view of clubs fetched from Firestore
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
              crossAxisCount: 2, // 2 items per row
              childAspectRatio: 1.0, // Square aspect ratio
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: snapshot.data!.length + 1, // Adding 1 for the "See More" button
            itemBuilder: (context, index) {
              if (index == snapshot.data!.length) {
                // Last item, "See More" button
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2018), // Background color for the block
                      borderRadius: BorderRadius.circular(10), // Optional: Add rounded corners
                    ),
                    child: TextButton(
                      onPressed: () {
                        // Navigate to the ClubsPage with BottomNavBar
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClubsPage(
                              collegeCode: widget.collegeCode,
                              rollNumber: widget.rollnumber,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'See More',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                final clubData = snapshot.data![index].data() as Map<String, dynamic>;
                String clubName = clubData['name'] ?? 'Unknown Club';
                String clubLogoUrl = clubData['logoUrl'] ?? ''; // URL of the club's logo

                return Card(
                  color: const Color(0xFF1E2018),
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

  /// Builds the list view of announcements fetched from Firestore
  /// Builds the list view of announcements fetched from Firestore
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
              String clubLogoUrl = announcementData['clubLogoUrl'] ?? ''; // Assuming the club logo is a URL

              // Truncate content to display only one or two lines
              String truncatedContent = content.length > 50 ? content.substring(0, 50) + '...' : content;

              return Card(
                color: const Color(0xFF1E2018),
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display club logo if available
                      clubLogoUrl.isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          clubLogoUrl,
                          width: 40.0,
                          height: 40.0,
                          fit: BoxFit.cover,
                        ),
                      )
                          : const SizedBox(width: 40.0), // Placeholder if no logo

                      const SizedBox(width: 12.0), // Space between logo and text

                      // Announcement text content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subject,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              truncatedContent,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'From: $clubName',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
}
}