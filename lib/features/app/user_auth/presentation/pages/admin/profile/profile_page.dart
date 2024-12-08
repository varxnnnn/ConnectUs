import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  final String collegeCode;
  final String adminId;

  const ProfilePage({
    super.key,
    required this.collegeCode,
    required this.adminId,
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  late String collegeCode;
  late String adminId;
  bool _isUploading = false; // Track the upload status
  double _uploadProgress = 0; // Track the upload progress

  @override
  void initState() {
    super.initState();
    collegeCode = widget.collegeCode;
    adminId = widget.adminId;
  }

  // Fetch admin data from Firestore
  Future<Map<String, dynamic>?> _fetchAdminData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(collegeCode)
          .collection('admin')
          .doc(adminId)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      } else {
        print('Document does not exist');
        return null;
      }
    } catch (e) {
      print('Error fetching data: $e');
      return null;
    }
  }

  // Function to pick and upload image with progress bar
  Future<void> _pickAndUploadImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        _isUploading = true;
        _uploadProgress = 0; // Reset progress when new upload starts
      });

      try {
        // Upload image to Firebase Storage with progress monitoring
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        UploadTask uploadTask = FirebaseStorage.instance
            .ref('posts/$fileName')
            .putFile(imageFile);

        // Monitor upload progress
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          setState(() {
            _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
          });
        });

        // Wait for the upload to complete
        await uploadTask.whenComplete(() async {
          if (uploadTask.snapshot.state == TaskState.success) {
            // Get the uploaded image URL
            String imageUrl = await uploadTask.snapshot.ref.getDownloadURL();

            // Save the image URL to Firestore at the specified path
            await FirebaseFirestore.instance
                .collection('users')
                .doc(collegeCode)
                .collection('admin')
                .doc(adminId)
                .collection('posts')
                .doc() // Auto-generated document ID
                .set({
              'imageUrl': imageUrl,
              'timestamp': FieldValue.serverTimestamp(),
            });

            setState(() {
              _isUploading = false; // Reset upload status after completion
            });

            print('Image uploaded successfully');
          } else {
            setState(() {
              _isUploading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload image')));
          }
        });
      } catch (e) {
        setState(() {
          _isUploading = false;
        });
        print('Error uploading image: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload image')));
      }
    }
  }

  // Fetch the posts from Firestore
  Future<List<Map<String, dynamic>>> _fetchPosts() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(collegeCode)
          .collection('admin')
          .doc(adminId)
          .collection('posts')
          .orderBy('timestamp', descending: true) // Order by timestamp
          .get();

      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error fetching posts: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Profile'),
        backgroundColor: const Color(0xFF0D1920),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchAdminData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }

          if (snapshot.hasData) {
            Map<String, dynamic>? data = snapshot.data;

            return ListView(
              children: [
                // Profile Header (Profile Image, Name, Bio)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (data != null && data['logoUrl'] != null && data['logoUrl'].isNotEmpty)
                        ClipOval(
                          child: Image.network(
                            data['logoUrl'],
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        data?['collegeName'] ?? 'College Name',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data?['bio'] ?? 'No bio available',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // Admin Info Section (Email, College Code, Admin ID)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin ID: $adminId',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Email: ${data?['email'] ?? 'No email available'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'College Code: $collegeCode',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Button to upload post
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: _pickAndUploadImage,
                    child: const Text('Upload Post'),
                  ),
                ),

                const SizedBox(height: 20),

                // Progress bar for upload status
                if (_isUploading)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Uploading...',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: _uploadProgress,
                          backgroundColor: Colors.grey[300],
                          color: const Color(0xFFF9AA33), // Progress color
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // Posts Section (Grid of posts)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Posts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _fetchPosts(),
                        builder: (context, postsSnapshot) {
                          if (postsSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (postsSnapshot.hasError) {
                            return const Center(child: Text('Error loading posts'));
                          }

                          if (postsSnapshot.hasData) {
                            List<Map<String, dynamic>> posts = postsSnapshot.data!;

                            return GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1,
                              ),
                              itemCount: posts.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(posts[index]['imageUrl']),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            );
                          } else {
                            return const Center(child: Text('No posts available'));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('No data available'));
        },
      ),
    );
  }
}
