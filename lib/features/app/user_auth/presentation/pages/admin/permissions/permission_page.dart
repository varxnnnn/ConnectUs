import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project1/features/app/user_auth/presentation/pages/admin/permissions/announcements/announcementRequests.dart';
import 'package:project1/features/app/user_auth/presentation/pages/admin/permissions/clubs/clubsRequests.dart';
import 'package:project1/features/app/user_auth/presentation/pages/admin/permissions/events/eventsRequests.dart';
import 'package:flutter/services.dart';
import 'package:project1/features/app/user_auth/presentation/pages/admin/permissions/students/StudentsRequestsPage.dart'; // Import for controlling system UI

class PermissionsPage extends StatefulWidget {
  final String collegeCode;

  const PermissionsPage({Key? key, required this.collegeCode}) : super(key: key);

  @override
  _PermissionsPageState createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  int _selectedOptionIndex = 0; // Track selected option
  final PageController _pageController = PageController(); // PageController for PageView

  @override
  void initState() {
    super.initState();
    // Set the status bar to a light color (for dark backgrounds)
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Transparent status bar
      statusBarIconBrightness: Brightness.light, // Light icons for dark background
    ));
  }

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
                  _buildTabButton(0, 'Students'),
                  const SizedBox(width: 10),
                  _buildTabButton(1, 'Clubs'), // Tab for Clubs
                  const SizedBox(width: 10), // Space between tabs
                  _buildTabButton(2, 'Events'), // Tab for Events
                  const SizedBox(width: 10), // Space between tabs
                  _buildTabButton(3, 'Announcements'), // Tab for Announcements
                  const SizedBox(width: 10), // Space between tabs
                   // Space between tabs
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
                  StudentsRequestsPage(collegeCode: widget.collegeCode),
                  ClubsRequestsPage(collegeCode: widget.collegeCode),
                  EventsRequestsPage(collegeCode: widget.collegeCode),
                  AnnouncementRequestsPage(collegeCode: widget.collegeCode),
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
              ? const Color(0xFF0D6EC5) // Highlight color if selected
              : const Color(0xFFCACAD5), // Default color
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
