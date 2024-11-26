import 'package:flutter/material.dart';

class AnnouncementsTab extends StatelessWidget {
  const AnnouncementsTab({Key? key, required Map<String, dynamic> clubDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Announcements',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFF9AA33)),
        ),
        SizedBox(height: 10),
        Text(
          'Announcements will be displayed here.',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
