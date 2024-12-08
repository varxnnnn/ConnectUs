import 'package:flutter/material.dart';
import 'package:project1/features/app/user_auth/presentation/pages/students/club/my_clubs/manage/announcement/announcementPage.dart';
import 'event/eventsPage.dart';
import 'about_us/about_us.dart';

class ManageClubPage extends StatefulWidget {
  final Map<String, dynamic> clubDetails;
  final String collegeCode;
  final String rollNumber;

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

  late final List<Widget> _pages;

  // Define colors
  static const Color backgroundColor = Color(0xFF0D1920);
  static const Color primaryColor = Color(0xFF0D1920);
  static const Color selectedTabColor = Color(0xFF0D6EC5);
  static const Color unselectedTabColor = Color(0xFF7D7F88);
  static const Color textColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _pages = [
      about_us(
        clubDetails: widget.clubDetails,
        collegeCode: widget.collegeCode,
        rollNumber: widget.rollNumber,
      ),
      EventsPage(
        clubDetails: widget.clubDetails,
        collegeCode: widget.collegeCode,
        rollNumber: widget.rollNumber,
      ),
      AnnouncementsPage(clubDetails: widget.clubDetails),
    ];
  }

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
          color: _currentIndex == index ? selectedTabColor : unselectedTabColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Manage Club', style: TextStyle(color: textColor)),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
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
            child: _pages[_currentIndex],
          ),
        ],
      ),
    );
  }
}
