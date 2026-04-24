import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'help_support_screen.dart';
import 'signin_screen.dart';

class NotificationsScreen extends StatelessWidget {
  final String userEmail;

  const NotificationsScreen({Key? key, required this.userEmail})
    : super(key: key);

  Future<Map<String, dynamic>?> fetchUserData() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: userEmail)
              .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data();
      }
      return null;
    } catch (error) {
      print('Error fetching user data: $error');
      return null;
    }
  }

  void handleFeature(BuildContext context, String feature) {
    final userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SigninPage()),
      );
      return;
    }

    switch (feature) {
      case 'helpSupport':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
        );
        break;

      case 'logout':
        FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SigninPage()),
        );
        break;

      case 'notifications':
        // No need to navigate here as we are already in the NotificationsScreen
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? userEmail = FirebaseAuth.instance.currentUser?.email;

    // Check if the user is logged in
    if (userEmail == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Notifications")),
        body: const Center(child: Text("No user logged in.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notifications",
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.lato(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFA3D5FF),
                Color(0xFF83C9F4),
                Color(0xFF6F73D2),
                Color(0xFF242A42),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF7F9FC),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20), // You can adjust spacing as needed
            // Notification list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('due_date_fine')
                        .where('email', isEqualTo: userEmail)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/empty_alert.png", height: 150),
                          const SizedBox(height: 20),
                          Text(
                            "No pending notifications.",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final name = data['name'] ?? 'Unknown';
                      final returnDate = DateTime.tryParse(
                        data['returnDate'] ?? '',
                      );
                      final formattedDate =
                          returnDate != null
                              ? DateFormat.yMMMd().format(returnDate)
                              : 'N/A';
                      final penalty = data['penalty'] ?? 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.red.shade100,
                              child: const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2B2D42),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Due on: $formattedDate",
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Penalty: ₹$penalty",
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
