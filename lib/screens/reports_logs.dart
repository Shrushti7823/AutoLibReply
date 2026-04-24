import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_screen.dart';
import 'issue_return_books.dart';
import 'sms_notifications.dart';
import 'due_date_fine.dart';
import 'signin_screen.dart';
import 'member_management.dart';

class ReportsLogsPage extends StatelessWidget {
  const ReportsLogsPage({super.key});

  void _handleFeatureTap(BuildContext context, String feature) {
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

    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  // Generic count stream from Firestore
  Stream<int> _getCount(
    String collection, {
    String? field,
    dynamic value,
    bool isNotEqual = false,
  }) {
    return FirebaseFirestore.instance.collection(collection).snapshots().map((
      snapshot,
    ) {
      if (field == null) return snapshot.docs.length;

      return snapshot.docs.where((doc) {
        var data = doc.data();
        if (!data.containsKey(field)) return false;
        return isNotEqual ? data[field] != value : data[field] == value;
      }).length;
    });
  }

  // Card widget for displaying a stat
  Widget _buildReportCard(String title, Stream<int> countStream, Color color) {
    return StreamBuilder<int>(
      stream: countStream,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.9), color.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                offset: const Offset(0, 8),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                "$count",
                style: GoogleFonts.poppins(
                  fontSize: 55,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminSidebar(
        onFeatureTap: (feature) => _handleFeatureTap(context, feature),
      ),
      appBar: AppBar(
        title: Text(
          "Reports & Logs",
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Library Reports & Logs",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            const SizedBox(height: 20),

            // Grid cards
            Expanded(
              child: GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 2.8,
                children: [
                  _buildReportCard(
                    "Students Who Took Books",
                    _getCount("issue_return"),
                    Colors.blue,
                  ),
                  _buildReportCard(
                    "Students Who Returned Books",
                    _getCount("issue_return", field: "submitted", value: true),
                    Colors.green,
                  ),
                  _buildReportCard(
                    "Students Who Have Not Returned Books",
                    _getCount("issue_return", field: "submitted", value: false),
                    Colors.redAccent,
                  ),
                  _buildReportCard(
                    "Students With Penalties",
                    _getCount("due_date_fine"),
                    Colors.orange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
