import 'package:flutter/material.dart';
import 'Explore_Clubs/clubs.dart';
import 'Explore_Events/events.dart';
import 'allCollages/AllCollegesPage.dart';
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
                  _buildTabButton(0, 'Explore Collages'),
                  const SizedBox(width: 10),
                  _buildTabButton(1, 'Explore Clubs'),
                  const SizedBox(width: 10),
                  _buildTabButton(2, 'Explore Events'),
                  const SizedBox(width: 10),
                  _buildTabButton(3, 'My Clubs'),

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
                  AllCollegesPage(),
                  AllClubsPage(collegeCode: widget.collegeCode, CrollNumber: widget.rollNumber),
                  AllEvents(collagecode: widget.collegeCode),
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
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          ); // Use animateToPage for smoother transition
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: _selectedOptionIndex == index
              ? const Color(0xFF0D6EC5) // Highlight color if selected
              : const Color(0xFF232322), // Default color
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
