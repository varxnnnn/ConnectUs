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
                  'Upcoming Explore Events',
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
                  'Explore Clubs',
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
              String clubAdmin = eventData['clubAdmin'] ?? 'Unknown Admin';
              String admissionFee = eventData['admissionFee'] ?? 'N/A';
              String date = eventData['date'] ?? 'No Date';
              String time = eventData['time'] ?? 'No Time';
              String posterUrl = eventData['posterUrl'] ?? '';
              String venue = eventData['venue'] ?? 'Unknown Venue';
              String restrictions = eventData['restrictions'] ?? 'None';

              return Card(
                color: const Color(0xFF1E2018),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Image.network(
                        posterUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        eventName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Club: $clubName',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Admin: $clubAdmin',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
            options: CarouselOptions(
              height: 400, // Adjust height as necessary
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              viewportFraction: 0.8,
              enlargeCenterPage: true,
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
                          style: const TextStyle(
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
              final announcementData =
              snapshot.data![index].data() as Map<String, dynamic>;
              String title = announcementData['title'] ?? 'No Title';
              String description = announcementData['description'] ?? 'No Description';

              return Card(
                color: const Color(0xFF1E2018),
                child: ListTile(
                  title: Text(
                    title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    description,
                    style: const TextStyle(color: Colors.white),
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
