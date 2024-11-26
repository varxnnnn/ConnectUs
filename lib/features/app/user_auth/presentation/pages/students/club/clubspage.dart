import 'package:flutter/material.dart';
import 'Explore_Clubs/clubs.dart';
import 'Explore_Events/events.dart';
import 'my_clubs/my_clubs.dart';

class ClubsPage extends StatefulWidget {
  final String collegeCode;
  final String rollNumber;

  const ClubsPage({Key? key, required this.collegeCode, required this.rollNumber}) : super(key: key);

  @override
  _ClubsPageState createState() => _ClubsPageState();
}

class _ClubsPageState extends State<ClubsPage> {
  int _selectedOptionIndex = 0;

  // PageController to handle the page view animation
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            const SizedBox(height: 20), // Add space at the top
            // Horizontally scrollable options aligned to the left
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabButton(0, 'Explore Explore_Clubs'),
                  const SizedBox(width: 10),
                  _buildTabButton(1, 'Explore Explore_Events'),
                  const SizedBox(width: 10),
                  _buildTabButton(2, 'My Explore_Clubs'),
                ],
              ),
            ),
            const SizedBox(height: 10), // Space between tabs and content
            // PageView with transition animation
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _selectedOptionIndex = index;
                  });
                },
                children: [
                  AllClubsPage(collegeCode: widget.collegeCode),
                  AllEvents(collegeCode: widget.collegeCode),
                  MyClubsPage(collegeCode: widget.collegeCode, rollNumber: widget.rollNumber),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOptionIndex = index;
          _pageController.jumpToPage(index); // Jump to the selected page
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: _selectedOptionIndex == index
              ? const Color(0xFFF9AA33) // Highlight color if selected
              : const Color(0xFF1E2018), // Default color
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade700),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
