import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Sidebar and Screens
import 'notifications_screen.dart';
import 'borrowed_books_screen.dart';
import 'signin_screen.dart';
import 'help_support_screen.dart';
import 'home_screen.dart';
//import 'sidebar.dart'; // Assuming you moved Feature enum and StudentSidebar here

class ProfileScreen extends StatelessWidget {
  final String userEmail;

  const ProfileScreen({Key? key, required this.userEmail}) : super(key: key);

  Future<Map<String, dynamic>?> fetchUserData() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: userEmail)
            .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    }
    return null;
  }

  void handleFeature(BuildContext context, Feature feature) {
    switch (feature) {
      case Feature.borrowedBooks:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BorrowedBooksScreen(userEmail: userEmail),
          ),
        );
        break;

      case Feature.profile:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileScreen(userEmail: userEmail),
          ),
        );
        break;

      case Feature.helpSupport:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
        );
        break;

      case Feature.notifications:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NotificationsScreen(userEmail: userEmail),
          ),
        );
        break;

      case Feature.home:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(userName: userEmail, userEmail: userEmail),
          ),
        );
        break;

      case Feature.logout:
        FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SigninPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          "My Profile",
          style: GoogleFonts.lato(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF6F73D2),
      ),
      drawer: StudentSidebar(
        onFeatureTap: (feature) => handleFeature(context, feature),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("User not found."));
          }

          final user = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF83C9F4),
                  child: Text(
                    user['name'][0].toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  user['name'],
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[900],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user['email'],
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F8FF),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.blueAccent),
                      const SizedBox(width: 12),
                      Text(
                        user['phone'] ?? "No phone number",
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}
