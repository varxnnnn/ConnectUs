import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'CollegeDetailsPage.dart';

class AllCollegesPage extends StatefulWidget {
  const AllCollegesPage({Key? key}) : super(key: key);

  @override
  _AllCollegesPageState createState() => _AllCollegesPageState();
}

class _AllCollegesPageState extends State<AllCollegesPage> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
  }

  // Fetch all colleges from Firestore with search filter
  Stream<List<Map<String, dynamic>>> _fetchAllColleges() {
    Query query = FirebaseFirestore.instance.collection('colleges');

    // Apply search query filter if it's not empty
    if (_searchQuery.isNotEmpty) {
      query = query
          .where('name', isGreaterThanOrEqualTo: _searchQuery)
          .where('name', isLessThanOrEqualTo: _searchQuery + '\uf8ff');
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {...data, 'id': doc.id}; // Add college ID to the data
      }).toList();
    });
  }

  // Update the search query
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search Bar for searching colleges
          Card(
            color: Color(0xFFF0F0F0), // Light gray background
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
            elevation: 0, // Flat look
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17.0, vertical: 0.2),
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    color: Colors.grey, // Subtle icon color
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Search for a college...',
                        hintStyle: const TextStyle(color: Colors.grey), // Subtle hint text color
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Colleges List
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _fetchAllColleges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final colleges = snapshot.data ?? [];

                return colleges.isEmpty
                    ? const Center(child: Text('No colleges available.'))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemCount: colleges.length,
                  itemBuilder: (context, index) {
                    final college = colleges[index];
                    final collegeId = college['id'];

                    return GestureDetector(
                      onTap: () {
                        // Navigate to the CollegeDetailsPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CollagesDetailsPage(
                              collegeDetails: college,
                              collegeId: collegeId,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                        child: SizedBox(
                          height: 150,
                          child: Stack(
                            children: [
                              Row(
                                children: [
                                  // College logo
                                  Expanded(
                                    flex: 3,
                                    child: college['logoUrl'] != null
                                        ? Image.network(
                                      college['logoUrl']!,
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
                              // College details
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
                                        college['name'] ?? 'Unnamed College',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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
          ),
        ],
      ),
    );
  }
}
