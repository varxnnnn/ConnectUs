import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeAdminPage extends StatefulWidget {
  final String collegeCode;

  const HomeAdminPage({
    super.key,
    required this.collegeCode, required String adminId,
  });

  @override
  _HomeAdminPageState createState() => _HomeAdminPageState();
}

class _HomeAdminPageState extends State<HomeAdminPage> {
  // List of asset image names
  final List<String> imageList = [
    'assets/1.jpg',
    'assets/2.jpg',
    'assets/3.jpg',
    'assets/4.jpg',
  ];

  // Fetch events from Firestore
  Future<List<QueryDocumentSnapshot>> _fetchEvents() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.collegeCode)
        .collection('collegeEvents')
        .get();
    return snapshot.docs;
  }

  // Fetch announcements from Firestore
  Future<List<QueryDocumentSnapshot>> _fetchAnnouncements() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.collegeCode)
        .collection('collegeAnnouncements')
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
              // Carousel Slider for Admin Images
              _buildImageCarousel(imageList),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Manage Events',
                  style: TextStyle(
                    fontSize: 32,
                    fontFamily: 'Archivo',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              // Display carousel of events
              _buildEventCarousel(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Recent Announcements',
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
                    borderRadius: BorderRadius.circular(10),
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
                  // Event Details
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

  /// Builds the list view of announcements
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
              String title = announcementData['title'] ?? 'No Title';
              String content = announcementData['content'] ?? 'No Content';

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  child: ListTile(
                    title: Text(title),
                    subtitle: Text(content),
                    onTap: () {
                      // Handle tap if needed
                    },
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
