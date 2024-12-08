import 'package:flutter/material.dart';
import 'package:project1/features/app/user_auth/presentation/pages/admin/permissions/permission_page.dart';
import 'package:project1/features/app/user_auth/presentation/pages/admin/profile/profile_page.dart';
import 'home_admin.dart';

class AdminDashboardPage extends StatefulWidget {
  final String collegeCode; // Add college code parameter
  final String adminId; // Add adminId parameter

  const AdminDashboardPage({
    super.key,
    required this.collegeCode,
    required this.adminId, // Update constructor to accept adminId
  });

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Initialize the pages with the collegeCode and adminId passed from the login
    _pages = [
      HomeAdminPage(collegeCode: widget.collegeCode, adminId: widget.adminId), // Home Page
      PermissionsPage(collegeCode: widget.collegeCode), // Pass college code to PermissionsPage
      ProfilePage(collegeCode: widget.collegeCode, adminId: widget.adminId), // Pass college code and adminId to ProfilePage
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1920), // Page background color
      body: _pages[_selectedIndex], // Switch between pages based on the selected index
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.security),
            label: 'Permissions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF0D6EC5),
        unselectedItemColor: const Color(0xFFCACAD5),
        backgroundColor: const Color(0xFF11232C), // Bottom nav background color
        onTap: _onItemTapped,
      ),
    );
  }
}
