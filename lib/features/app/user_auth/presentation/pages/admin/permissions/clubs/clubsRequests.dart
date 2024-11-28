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
            return const Center(child: CircularProgressIndicator());
          }

          final requests = requestsSnapshot.data!.docs;

          if (requests.isEmpty) {
            return const Center(child: Text("No club requests found."));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index].data() as Map<String, dynamic>;
              final requestId = requests[index].id;

              return GestureDetector(
                onTap: () {
                  _viewClubDetails(context, request, requestId);
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: SizedBox(
                    height: 150,
                    child: Stack(
                      children: [
                        Row(
                          children: [
                            // Club logo
                            Expanded(
                              flex: 3,
                              child: request['logoUrl'] != null
                                  ? Image.network(
                                request['logoUrl']!,
                                fit: BoxFit.cover,
                              )
                                  : Container(
                                color: Colors.grey,
                                child: const Icon(
                                  Icons.photo,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              ),
                            ),
                            // Details background
                            Expanded(
                              flex: 1,
                              child: Container(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        // Gradient overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withOpacity(0.9),
                                  Colors.white,
                                ],
                                stops: [0.2, 0.6, 0.8],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                          ),
                        ),
                        // Club details
                        Positioned(
                          right: 8,
                          top: 8,
                          bottom: 8,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.25,
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  request['name'] ?? 'Unnamed Club',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  request['category'] ?? 'Category not specified',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Arrow icon
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black.withOpacity(0.7),
                            size: 24,
                          ),
                        ),
                      ],
                    ),
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
