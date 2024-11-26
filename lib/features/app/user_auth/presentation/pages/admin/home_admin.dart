import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeadminPage extends StatelessWidget {
  HomeadminPage({super.key});

  // Sample data for clubs and announcements
  final List<Map<String, String>> clubs = [
    {
      'name': 'Science Club',
      'description': 'A club for science enthusiasts.',
    },
    {
      'name': 'Art Club',
      'description': 'Explore creativity through art.',
    },
    {
      'name': 'Literature Club',
      'description': 'Discuss and analyze great literary works.',
    },
  ];

  final List<Map<String, String>> announcements = [
    {
      'title': 'New Library Opening',
      'description': 'Join us for the opening of our new library with modern facilities.',
    },
    {
      'title': 'School Sports Day',
      'description': 'A day filled with exciting sports events and competitions.',
    },
  ];

  final List<Color> eventColors = [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121111),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Carousel for Events
              const Text(
                'Upcoming Explore_Events',
                style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              CarouselSlider(
                options: CarouselOptions(
                  height: 200,
                  autoPlay: true,
                  enlargeCenterPage: true,
                ),
                items: eventColors.map((color) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Event ${eventColors.indexOf(color) + 1}', // Dynamic event title
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              backgroundColor: Colors.black54,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Clubs Section
              const Text(
                'Explore_Clubs',
                style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: clubs.length,
                itemBuilder: (context, index) {
                  return _buildClubCard(clubs[index]);
                },
              ),
              const SizedBox(height: 20),

              // Announcements Section
              const Text(
                'Announcements',
                style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  return _buildAnnouncementCard(announcements[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClubCard(Map<String, String> club) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: const Color(0xFF1E2018),
      child: ListTile(
        title: Text(
          club['name'] ?? 'Unknown Club',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          club['description'] ?? 'No description available.',
          style: const TextStyle(color: Colors.white54),
        ),
        tileColor: const Color(0xFF1E2018),
      ),
    );
  }

  Widget _buildAnnouncementCard(Map<String, String> announcement) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: const Color(0xFF1E2018),
      child: ListTile(
        title: Text(
          announcement['title'] ?? 'Unknown Announcement',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          announcement['description'] ?? 'No description available.',
          style: const TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}
