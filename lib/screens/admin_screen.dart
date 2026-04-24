import 'package:flutter/material.dart';
import 'signin_screen.dart';
import 'package:google_fonts/google_fonts.dart';

// Import Feature Pages
import 'member_management.dart';
import 'issue_return_books.dart';
import 'due_date_fine.dart';
import 'sms_notifications.dart';
import 'reports_logs.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final List<Map<String, dynamic>> features = [
    {"title": "Member Management", "icon": Icons.group},
    {"title": "Issue & Return Books", "icon": Icons.book},
    {"title": "Due Date & Fine", "icon": Icons.date_range},
    {"title": "SMS Notifications", "icon": Icons.sms},
    {"title": "Reports & Logs", "icon": Icons.bar_chart},
  ];

  // Function to handle navigation
  void _handleFeatureTap(String feature) {
    Widget page;
    switch (feature) {
      case "Home":
        page = const AdminHomePage();
        break;
      case "Member Management":
        page = const MemberManagementPage();
        break;
      case "Issue & Return Books":
        page = const IssueReturnBooksPage();
        break;
      case "Due Date & Fine":
        page = const DueDateFinePage();
        break;
      case "SMS Notifications":
        page = const SmsNotificationsPage();
        break;
      case "Reports & Logs":
        page = const ReportsLogsPage();
        break;
      case "Logout":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SigninPage()),
        );
        return;
      default:
        return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminSidebar(onFeatureTap: _handleFeatureTap),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          title: Text(
            "Admin Dashboard",
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
          leading: Builder(
            builder:
                (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Features",
              style: GoogleFonts.lato(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF242A42),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.3,
                ),
                itemCount: features.length,
                itemBuilder: (context, index) {
                  return _buildDashboardBox(
                    features[index]["title"],
                    features[index]["icon"],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  // Function to build dashboard grid items
  Widget _buildDashboardBox(String feature, IconData icon) {
    return GestureDetector(
      onTap: () => _handleFeatureTap(feature),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                spreadRadius: 1,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.blue.shade900),
              const SizedBox(height: 5),
              Text(
                feature,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
                softWrap: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Sidebar Widget
class AdminSidebar extends StatelessWidget {
  final Function(String) onFeatureTap;

  const AdminSidebar({super.key, required this.onFeatureTap});

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
              children: const [
                Icon(Icons.person, size: 60, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  "Admin Menu",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildSidebarItem(context, Icons.group, "Home"),
                _buildSidebarItem(context, Icons.group, "Member Management"),
                _buildSidebarItem(context, Icons.book, "Issue & Return Books"),
                _buildSidebarItem(context, Icons.date_range, "Due Date & Fine"),
                _buildSidebarItem(context, Icons.sms, "SMS Notifications"),
                _buildSidebarItem(context, Icons.bar_chart, "Reports & Logs"),
                _buildSidebarItem(context, Icons.logout, "Logout"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(BuildContext context, IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade900),
      title: Text(title, style: GoogleFonts.lato(fontSize: 18)),
      hoverColor: Colors.blue.shade100,
      onTap: () {
        Navigator.pop(context); // Close the sidebar
        Future.delayed(const Duration(milliseconds: 300), () {
          onFeatureTap(title);
        });
      },
    );
  }
}
