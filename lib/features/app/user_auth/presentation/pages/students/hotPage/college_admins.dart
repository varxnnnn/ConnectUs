import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Define colors
const Color primaryColor = Color(0xFF0D6EC5);
const Color cardBackgroundColor = Color(0xFF1E2018);

class CollegeCodesSection extends StatefulWidget {
  const CollegeCodesSection({Key? key, required String collegeCode}) : super(key: key);

  @override
  _CollegeCodesSectionState createState() => _CollegeCodesSectionState();
}

class _CollegeCodesSectionState extends State<CollegeCodesSection> {
  TextEditingController _searchController = TextEditingController();
  List<String> _collegeCodes = [];
  List<String> _filteredCollegeCodes = [];

  @override
  void initState() {
    super.initState();
    _fetchCollegeCodes();
  }

  Future<void> _fetchCollegeCodes() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('codes')
        .doc('allCodes')
        .get();

    if (snapshot.exists) {
      List<dynamic> collegeCodes = snapshot['collegeCodes'] ?? [];
      setState(() {
        _collegeCodes = collegeCodes.cast<String>();
        _filteredCollegeCodes = _collegeCodes;
      });
    } else {
      throw Exception("No college codes found");
    }
  }

  void _filterCollegeCodes(String query) {
    final filtered = _collegeCodes.where((code) {
      return code.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredCollegeCodes = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Our Collages',
            style: TextStyle(
              fontSize: 32,
              fontFamily: 'Archivo',
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 16),

          // Horizontal Scrollable List
          Container(
            height: 80, // Set the height of the horizontal list
            child: ListView.builder(
              scrollDirection: Axis.horizontal, // Enable horizontal scrolling
              itemCount: _filteredCollegeCodes.length,
              itemBuilder: (context, index) {
                String collegeCode = _filteredCollegeCodes[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardBackgroundColor,
                      borderRadius: BorderRadius.circular(100.0), // Rounded corners
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        collegeCode,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: _filterCollegeCodes,
            decoration: InputDecoration(
              labelText: 'Search College Codes',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ],
      ),
    );
  }
}
