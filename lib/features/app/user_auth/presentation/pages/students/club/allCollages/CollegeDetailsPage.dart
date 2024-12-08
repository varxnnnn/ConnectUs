import 'package:flutter/material.dart';

class CollagesDetailsPage extends StatelessWidget {
  final Map<String, dynamic> collegeDetails;
  final String collegeId;

  const CollagesDetailsPage({
    Key? key,
    required this.collegeDetails,
    required this.collegeId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(collegeDetails['name'] ?? 'College Details'),
        backgroundColor: Color(0xFF0D6EC5), // Example color
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // College Image or Logo
              collegeDetails['logoUrl'] != null
                  ? Image.network(
                collegeDetails['logoUrl']!,
                fit: BoxFit.cover,
                height: 200,
              )
                  : Container(
                color: Colors.grey,
                child: const Icon(
                  Icons.photo,
                  color: Colors.white,
                  size: 50,
                ),
                height: 200,
              ),
              const SizedBox(height: 16),

              // College Information Section
              Text(
                'College Name: ${collegeDetails['name'] ?? 'Unknown College'}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'College Code: ${collegeDetails['collegeCode'] ?? 'Unknown'}',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Location: ${collegeDetails['location'] ?? 'Unknown Location'}',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Description: ${collegeDetails['description'] ?? 'No description available.'}',
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 16),

              // Button to navigate to other pages (e.g., clubs, events)

            ],
          ),
        ),
      ),
    );
  }
}
