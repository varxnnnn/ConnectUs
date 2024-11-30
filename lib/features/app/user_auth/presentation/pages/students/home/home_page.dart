import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../club/clubspage.dart';
import 'Club.dart';

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

  // Fetch clubs from Firestore
  Future<List<QueryDocumentSnapshot>> _fetchClubs() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.collegeCode)
        .collection('collegeClubs')
        .limit(6) // Fetch only 6 clubs
        .get();
    return snapshot.docs;
  }

  // Fetch events from Firestore
  Future<List<QueryDocumentSnapshot>> _fetchEvents() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.collegeCode)
        .collection('collegeEvents')
        .limit(6) // Fetch only 6 events
        .get();
    return snapshot.docs;
  }

  // Fetch announcements from Firestore
  Future<List<QueryDocumentSnapshot>> _fetchAnnouncements() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.collegeCode)
        .collection('collegeAnnouncements')
        .limit(5) // Fetch only 5 announcements
        .get();
    return snapshot.docs;
  }

  // Fetch club IDs from Firestore (joined clubs)
  Future<List<String>> _fetchJoinedClubs() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.collegeCode)
        .collection('students')
        .doc(widget.rollnumber)
        .collection('JoinedClubs')
        .doc('ids')
        .get();

    // Assuming the club IDs are stored in an array field called 'clubIds'
    if (snapshot.exists && snapshot.data() != null) {
      return List<String>.from(snapshot.data()!['clubids'] ?? []);
    } else {
      return [];
    }
  }

  Future<List<Club>> _fetchClubDetails(List<String> clubIds) async {
    List<Club> clubs = [];

    for (String clubId in clubIds) {
      final snapshot = await FirebaseFirestore.instance
          .collection('allClubs')
          .doc(clubId)
          .get();

      if (snapshot.exists) {
        final clubData = snapshot.data()!;
        clubs.add(Club.fromMap(clubData, clubId));
      }
    }

    return clubs;
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
                  'Our Clubs',
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

              // Horizontal list view for joined clubs
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Joined Clubs',
                  style: TextStyle(
                    fontSize: 32,
                    fontFamily: 'Archivo',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              // Display horizontal list of joined club IDs
              _buildJoinedClubsList(),

              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Upcoming Events',
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
                      color: const Color(0xFF1E2018), // Background color
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextButton(
                      onPressed: () {
                        // Navigate to the Clubs Page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClubsPage(collegeCode: widget.collegeCode, // Pass collegeCode
                              rollNumber: widget.rollnumber,),
                          ),
                        );
                      },
                      child: const Text(
                        'See More',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                final clubData = snapshot.data![index].data() as Map<String, dynamic>;
                String clubName = clubData['name'] ?? 'Unknown Club';
                String clubDescription = clubData['description'] ?? 'No description available';
                String clubImageUrl = clubData['logoUrl'] ?? '';

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        // Club Image
                        Image.network(
                          clubImageUrl,
                          fit: BoxFit.cover,
                          height: double.infinity,
                          width: double.infinity,
                        ),
                        // Overlay for text
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10), // Match rounded corners
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.7), // Dark at the bottom
                                Colors.transparent, // Fade to transparent at the top
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                        // Club details text
                        Positioned(
                          bottom: 16, // Padding from the bottom
                          left: 16,  // Padding from the left
                          right: 16, // Padding from the right
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                clubName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4), // Space between text
                              Text(
                                clubDescription,
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
              }
            },
          );
        }
      },
    );
  }

  /// Builds the horizontal list view for joined clubs
  Widget _buildJoinedClubsList() {
    return FutureBuilder<List<String>>(
      future: _fetchJoinedClubs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error loading joined clubs"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No joined clubs available"));
        } else {
          // Fetch club details from allClubs collection
          return FutureBuilder<List<Club>>(
            future: _fetchClubDetails(snapshot.data!),
            builder: (context, clubSnapshot) {
              if (clubSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (clubSnapshot.hasError) {
                return const Center(child: Text("Error loading club details"));
              } else if (!clubSnapshot.hasData || clubSnapshot.data!.isEmpty) {
                return const Center(child: Text("No club details available"));
              } else {
                return Container(
                  height: 160, // Increase the height for larger items
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: clubSnapshot.data!.length,
                    itemBuilder: (context, index) {
                      final club = clubSnapshot.data![index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0), // More padding for spacing
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Larger Circular club logo
                            CircleAvatar(
                              radius: 50, // Increased size for the logo
                              backgroundImage: NetworkImage(club.imageUrl),
                              backgroundColor: Colors.transparent,
                            ),
                            const SizedBox(height: 12), // More space between image and name
                            // Larger Club name
                            Text(
                              club.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18, // Larger font size
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }
            },
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
