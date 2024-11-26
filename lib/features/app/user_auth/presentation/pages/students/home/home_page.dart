import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../club/clubspage.dart';

class HomePage extends StatefulWidget {
  final String collegeCode; // Define collegeCode
  final String rollnumber; // Define rollnumber

  const HomePage({
    super.key,
    required this.collegeCode,
    required this.rollnumber,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // New color list
  final List<Color> colorList = [
    const Color(0xFF1E88E5), // Blue
    const Color(0xFF43A047), // Green
    const Color(0xFFFBC02D), // Yellow
    const Color(0xFFE64A19), // Red
    const Color(0xFF8E24AA), // Purple
  ];

  @override
  void initState() {
    super.initState();

    // Set up a timer for automatic sliding
    Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentIndex < colorList.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      // Update the state to trigger carousel slide
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(  // Wrap the entire body with SafeArea
        child: SingleChildScrollView( // Make the entire body scrollable
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Upcoming Explore_Events',
                    style: TextStyle(
                      fontSize: 32, // Increased font size
                      fontFamily: 'Archivo', // Use Archivo font for title
                      fontWeight: FontWeight.bold, // Make the text bold
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: CarouselSlider.builder(
                    itemCount: colorList.length,
                    itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 0), // No margin to fit the full width
                        width: MediaQuery.of(context).size.width, // Full screen width
                        decoration: BoxDecoration(
                          color: colorList[itemIndex], // Use color from the list
                        ),
                        child: Center(
                          child: Text(
                            'Slide ${itemIndex + 1}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontFamily: 'Archivo', // Use Archivo font for carousel text
                              fontWeight: FontWeight.bold, // Make the text bold
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                    options: CarouselOptions(
                      height: 200,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 3),
                      viewportFraction: 1.0, // Set this to 1.0 to ensure only one slide is shown
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                    ),
                  ),
                ),
                // Add space between the carousel and the dot indicators
                const SizedBox(height: 16), // Space between carousel and dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(colorList.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8), // Added horizontal margin to create space between dots
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index
                            ? Colors.white
                            : Colors.grey, // Active dot is white, inactive is grey
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16), // Space between carousel and clubs section
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Explore Explore_Clubs',
                    style: TextStyle(
                      fontSize: 32, // Increased font size
                      fontFamily: 'Archivo', // Use Archivo font for title
                      fontWeight: FontWeight.bold, // Make the text bold
                      color: Colors.white,
                    ),
                  ),
                ),
                // Column for clubs instead of ListView
                Column(
                  children: List.generate(4, (index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      color: const Color(0xFF1E2018), // Set background color for the card
                      child: ListTile(
                        title: Text(
                          'Club ${index + 1}',
                          style: const TextStyle(
                            fontFamily: 'Inter', // Use Inter font for club title
                            fontWeight: FontWeight.bold, // Make the club title bold
                            color: Colors.white, // Change text color to white for contrast
                          ),
                        ),
                        subtitle: Text(
                          'Description of Club ${index + 1}', // Correctly using index
                          style: const TextStyle(
                            fontFamily: 'Inter', // Use Inter font for club description
                            color: Colors.grey, // Gray subtitle color
                          ),
                        ),
                        leading: const Icon(Icons.group, color: Colors.blue),
                      ),
                    );
                  }),
                ),
                // "See More" button for Explore Clubs section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: TextButton(
                    onPressed: () {
                      // Navigate to ClubsPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClubsPage(collegeCode: widget.collegeCode, rollNumber: widget.rollnumber),
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
                const SizedBox(height: 16), // Space between clubs and announcements section
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Recent Announcements',
                    style: TextStyle(
                      fontSize: 32, // Increased font size
                      fontFamily: 'Archivo', // Use Archivo font for title
                      fontWeight: FontWeight.bold, // Make the text bold
                      color: Colors.white,
                    ),
                  ),
                ),
                // ListView for announcements
                ListView.builder(
                  shrinkWrap: true, // Shrink the ListView to its content
                  physics: const NeverScrollableScrollPhysics(), // Disable scrolling
                  itemCount: 4, // Display 4 items for announcements
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      color: const Color(0xFF1E2018), // Set background color for the card
                      child: ListTile(
                        title: Text(
                          'Announcement ${index + 1}',
                          style: const TextStyle(
                            fontFamily: 'Inter', // Use Inter font for announcement title
                            fontWeight: FontWeight.bold, // Make the announcement title bold
                            color: Colors.white, // Change text color to white for contrast
                          ),
                        ),
                        subtitle: Text(
                          'Details about announcement ${index + 1}', // Correctly using index
                          style: const TextStyle(
                            fontFamily: 'Inter', // Use Inter font for announcement description
                            color: Colors.grey, // Gray subtitle color
                          ),
                        ),
                        leading: const Icon(Icons.announcement, color: Colors.blue),
                      ),
                    );
                  },
                ),
                // "See More" button for Recent Announcements section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: TextButton(
                    onPressed: () {
                      // Navigate to AnnouncementsPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClubsPage(collegeCode: widget.collegeCode, rollNumber: widget.rollnumber),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
