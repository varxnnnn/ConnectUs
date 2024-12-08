import 'package:flutter/material.dart';
import 'package:project1/features/app/user_auth/presentation/pages/students/profile/profile.dart';
import 'students/chatBot/chatbot.dart';
import 'students/club/clubspage.dart';
import 'students/home/home_page.dart';
import 'students/hotPage/hot.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String? rollNumber;
  String? collegeCode;

  static const Color primaryColor = Color(0xFF0D6EC5); // Selected icon and label
  static const Color navBackgroundColor = Color(0xFF11232C); // Background of the bottom navigation bar
  static const Color pageBackgroundColor = Color(0xFF0D1920); // Updated background color

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('allUsers')
          .doc(user.uid)
          .get();
      setState(() {
        rollNumber = userData['rollNumber'];
        collegeCode = userData['collegeCode'];
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: pageBackgroundColor, // Set the background color to the updated value
        child: IndexedStack(
          index: _selectedIndex,
          children: <Widget>[
            HomePage(collegeCode: collegeCode ?? '', rollnumber: rollNumber ?? ''),
            ClubsPage(collegeCode: collegeCode ?? '', rollNumber: rollNumber ?? ''),
            HotPage(collegeCode: collegeCode ?? '', rollNumber: rollNumber ?? ''),
            ChatBotScreen(),
            ProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: navBackgroundColor,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: primaryColor),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups, color: primaryColor),
            label: 'Clubs & Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up_outlined),
            selectedIcon: Icon(Icons.trending_up, color: primaryColor),
            label: 'Hot Page',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat, color: primaryColor),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: primaryColor),
            label: 'Profile',
          ),
        ],
        indicatorColor: navBackgroundColor, // Highlight for the selected tab
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}
