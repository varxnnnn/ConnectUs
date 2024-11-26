import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project1/features/app/user_auth/presentation/pages/admin/permissions/clubs/club_request_details_page.dart';

class ClubsRequestsPage extends StatelessWidget {
  final String collegeCode;

  ClubsRequestsPage({Key? key, required this.collegeCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(collegeCode)
            .collection('clubRequests')
            .snapshots(),
        builder: (context, requestsSnapshot) {
          if (!requestsSnapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final requests = requestsSnapshot.data!.docs;

          if (requests.isEmpty) {
            return Center(child: Text("No club requests found."));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index].data() as Map<String, dynamic>;
              final requestId = requests[index].id;

              return Card(
                margin: EdgeInsets.all(10),
                elevation: 5, // Adjust elevation to your preference
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                child: ListTile(
                  title: Text.rich(
                    TextSpan(
                      text: '${request['name'] ?? 'Unnamed Club'} CLUB',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  subtitle: Text("Requested by: ${request['adminName'] ?? 'Unknown'}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.info, color: Colors.blue),
                        onPressed: () => _viewClubDetails(context, request, requestId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _viewClubDetails(BuildContext context, Map<String, dynamic> clubDetails, String requestId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClubRequestDetailsPage(
          clubDetails: clubDetails,
          collegeCode: collegeCode,
        ),
      ),
    );
  }
}
