import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'signin_screen.dart';
import 'borrowed_books_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'help_support_screen.dart';

enum Feature {
  home,
  borrowedBooks,
  notifications,
  profile,
  helpSupport,
  logout,
}

class HomePage extends StatelessWidget {
  final String userName;
  final String userEmail;

  const HomePage({Key? key, required this.userName, required this.userEmail})
    : super(key: key);

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
        Navigator.pop(context); // Just close the drawer
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          title: Flexible(
            child: Text(
              "Welcome, $userName",
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.lato(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
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
      ),
      drawer: StudentSidebar(
        onFeatureTap: (feature) => handleFeature(context, feature),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Features",
              style: GoogleFonts.lato(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF242A42),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildFeatureCard(
                    Icons.book,
                    "Borrowed Books",
                    () => handleFeature(context, Feature.borrowedBooks),
                  ),
                  _buildFeatureCard(
                    Icons.notifications,
                    "Notifications",
                    () => handleFeature(context, Feature.notifications),
                  ),
                  _buildFeatureCard(
                    Icons.person,
                    "Profile",
                    () => handleFeature(context, Feature.profile),
                  ),
                  _buildFeatureCard(
                    Icons.help,
                    "Help & Support",
                    () => handleFeature(context, Feature.helpSupport),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: const Color(0xFF6F73D2)),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF242A42),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentSidebar extends StatelessWidget {
  final Function(Feature) onFeatureTap;

  const StudentSidebar({Key? key, required this.onFeatureTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFD9F0FF),
                  Color(0xFFA3D5FF),
                  Color(0xFF83C9F4),
                  Color(0xFF6F73D2),
                  Color(0xFF242A42),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.person, size: 60, color: Colors.white),
                const SizedBox(height: 10),
                const Text(
                  "Student Menu",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildSidebarItem(
                  Icons.home,
                  "Home",
                  () => onFeatureTap(Feature.home),
                ),
                _buildSidebarItem(
                  Icons.book,
                  "My Borrowed Books",
                  () => onFeatureTap(Feature.borrowedBooks),
                ),
                _buildSidebarItem(
                  Icons.notifications,
                  "Notifications",
                  () => onFeatureTap(Feature.notifications),
                ),
                _buildSidebarItem(
                  Icons.person,
                  "Profile",
                  () => onFeatureTap(Feature.profile),
                ),
                _buildSidebarItem(
                  Icons.help,
                  "Help & Support",
                  () => onFeatureTap(Feature.helpSupport),
                ),
                _buildSidebarItem(
                  Icons.logout,
                  "Logout",
                  () => onFeatureTap(Feature.logout),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF242A42)),
      title: Text(
        title,
        style: GoogleFonts.lato(fontSize: 18, color: Colors.black87),
      ),
      onTap: onTap,
    );
  }
}
