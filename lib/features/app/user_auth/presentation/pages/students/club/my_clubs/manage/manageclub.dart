import 'package:flutter/material.dart';
import 'package:project1/features/app/user_auth/presentation/pages/students/club/my_clubs/manage/announcement/announcementPage.dart';
import 'event/eventsPage.dart';
import 'about_us/about_us.dart';

class ManageClubPage extends StatefulWidget {
  final Map<String, dynamic> clubDetails;
  final String collegeCode; // Accept collegeCode
  final String rollNumber; // Accept rollNumber

  const ManageClubPage({
    Key? key,
    required this.clubDetails,
    required this.collegeCode,
    required this.rollNumber,
  }) : super(key: key);

  @override
  _ManageClubPageState createState() => _ManageClubPageState();
}

class _ManageClubPageState extends State<ManageClubPage> {
  int _currentIndex = 0;

  // List of Widgets for each page
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Initialize the list of pages and pass collegeCode and rollNumber
    _pages = [
      about_us(
        clubDetails: widget.clubDetails,
        collegeCode: widget.collegeCode,
        rollNumber: widget.rollNumber,
      ),
      EventsPage(
        clubDetails: widget.clubDetails,
        collegeCode: widget.collegeCode, // Pass collegeCode here
        rollNumber: widget.rollNumber,    // Pass rollNumber here
      ),
      AnnouncementsPage(clubDetails: widget.clubDetails),
    ];
  }

  // Method to build tab buttons
  Widget _buildTabButton(int index, String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: _currentIndex == index ? const Color(0xFFA60000) : Colors.grey[300],
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: _currentIndex == index ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTabButton(0, 'About Us'),
                const SizedBox(width: 10),
                _buildTabButton(1, 'Events'),
                const SizedBox(width: 10),
                _buildTabButton(2, 'Announcements'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _pages[_currentIndex], // Display the selected page
          ),
        ],
      ),
    );
  }
}
