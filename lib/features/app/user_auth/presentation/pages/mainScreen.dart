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

  static const Color secondaryColor = Color(0xFFF9AA33); // Light secondary color
  static const Color grayColor = Color(0xFF7D7F88); // Gray for unselected items

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
      body: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          HomePage(collegeCode: collegeCode ?? '', rollnumber: rollNumber ?? ''),
          ClubsPage(collegeCode: collegeCode ?? '', rollNumber: rollNumber ?? ''),
          ChatBotScreen(),
          HotPage(collegeCode: collegeCode ?? '', rollNumber: rollNumber ?? ''),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: secondaryColor, // Set selected icon color
        unselectedItemColor: grayColor, // Set unselected icon color
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'My Collage',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Hot Page',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
