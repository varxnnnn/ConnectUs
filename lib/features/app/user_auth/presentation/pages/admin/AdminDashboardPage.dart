import 'package:flutter/material.dart';
import 'package:project1/features/app/user_auth/presentation/pages/admin/permissions/permission_page.dart';
import 'package:project1/features/app/user_auth/presentation/pages/admin/profile_page.dart';
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
        selectedItemColor: Color(0xFFA60000),
        unselectedItemColor: Color(0xFF333337),// Change selected item color to 0xFFF9AA33
        onTap: _onItemTapped,
      ),
    );
  }
}
