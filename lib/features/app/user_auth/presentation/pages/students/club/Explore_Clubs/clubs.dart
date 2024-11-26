import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'club_details_page/clubdetailpage.dart';

class AllClubsPage extends StatefulWidget {
  final String collegeCode;

  const AllClubsPage({Key? key, required this.collegeCode}) : super(key: key);

  @override
  _AllClubsPageState createState() => _AllClubsPageState();
}

class _AllClubsPageState extends State<AllClubsPage> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  Set<String> _selectedCollegeCodes = {"All"}; // Default to "All" selected

  final List<String> _collegeCodes = [
    'All',
    'VGNT',
    'CMR',
    'GRRR',
    'MGIT',
    'SNITS',
    'HOLY',
  ]; // List of college codes including "All"

  @override
  void initState() {
    super.initState();
  }

  // Fetch clubs from Firestore with search and college code filter
  Stream<List<Map<String, dynamic>>> _fetchCollegeClubs() {
    Query query = FirebaseFirestore.instance.collection('allClubs');

    // Apply college code filter if "All" is not selected
    if (!_selectedCollegeCodes.contains("All")) {
      query = query.where(
        'collegeCode',
        whereIn: _selectedCollegeCodes.isNotEmpty ? _selectedCollegeCodes.toList() : null,
      );
    }

    // Apply search query filter
    if (_searchQuery.isNotEmpty) {
      query = query
          .where('name', isGreaterThanOrEqualTo: _searchQuery)
          .where('name', isLessThanOrEqualTo: _searchQuery + '\uf8ff');
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {...data, 'id': doc.id}; // Add club ID to the data
      }).toList();
    });
  }

  // Update the search query
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  // Handle college code selection
  void _onCollegeCodeSelected(String code) {
    setState(() {
      if (code == "All") {
        _selectedCollegeCodes = {"All"}; // Reset to only "All"
      } else {
        _selectedCollegeCodes.remove("All"); // Deselect "All" when a specific college is selected
        if (_selectedCollegeCodes.contains(code)) {
          _selectedCollegeCodes.remove(code); // Deselect if already selected
        } else {
          _selectedCollegeCodes.add(code); // Add to selection
        }

        // If no specific colleges are selected, default to "All"
        if (_selectedCollegeCodes.isEmpty) {
          _selectedCollegeCodes = {"All"};
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Card(
            color: Color(0xFFF0F0F0), // Light gray background similar to WhatsApp
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Fully rounded corners
            ),
            elevation: 0, // No elevation for a flat look
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
                        hintText: 'Search for a club...',
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
          // Scrollable list of college code filters
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _collegeCodes.length,
              itemBuilder: (context, index) {
                final code = _collegeCodes[index];
                final isSelected = _selectedCollegeCodes.contains(code);
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      code,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => _onCollegeCodeSelected(code),
                    selectedColor: Colors.orangeAccent,
                    backgroundColor: Colors.grey[200],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Clubs List
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _fetchCollegeClubs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final clubs = snapshot.data ?? [];

                return clubs.isEmpty
                    ? const Center(child: Text('No clubs available.'))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemCount: clubs.length,
                  itemBuilder: (context, index) {
                    final club = clubs[index];
                    final clubId = club['id'];

                    return GestureDetector(
                      onTap: () {
                        // Navigate to the ClubDetailsPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClubDetailsPage(
                              clubDetails: club,
                              clubId: clubId,
                              collegeCode: widget.collegeCode,
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
                                  // Club logo
                                  Expanded(
                                    flex: 3,
                                    child: club['logoUrl'] != null
                                        ? Image.network(
                                      club['logoUrl']!,
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
                                        club['name'] ?? 'Unnamed Club',
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
                                        club['category'] ?? 'Category not specified',
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
          ),
        ],
      ),
    );
  }
}
