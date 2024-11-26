import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String collegeCode;
  final String adminId;

  const ProfilePage({
    super.key,
    required this.collegeCode,
    required this.adminId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('College Code: $collegeCode'),
            Text('Admin ID: $adminId'),
          ],
        ),
      ),
    );
  }
}
