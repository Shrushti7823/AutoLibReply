import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import 'signin_screen.dart';
import 'help_support_screen.dart';
import 'home_screen.dart';

class BorrowedBooksScreen extends StatelessWidget {
  final String userEmail;

  const BorrowedBooksScreen({Key? key, required this.userEmail})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("BorrowedBooksScreen -> userEmail: $userEmail");

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Borrowed Books",
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
      drawer: StudentSidebar(
        onFeatureTap: (feature) {
          Navigator.pop(context);
          switch (feature) {
            case Feature.home:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (_) =>
                          HomePage(userName: userEmail, userEmail: userEmail),
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

            case Feature.profile:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(userEmail: userEmail),
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
            default:
              break;
          }
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('issue_return')
                .where('email', isEqualTo: userEmail)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final books = snapshot.data!.docs;

          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/empty_books.png", height: 180),
                  const SizedBox(height: 20),
                  Text(
                    "No books borrowed.",
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
            itemCount: books.length,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            itemBuilder: (context, index) {
              final book = books[index];
              final issueDate = DateTime.tryParse(book['issueDate'] ?? '');
              final returnDate = DateTime.tryParse(book['returnDate'] ?? '');
              final submitted = book['submitted'] == true;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Color(0xFFF9FBFF), Color(0xFFE9F0FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          submitted ? Colors.green[50] : Colors.red[50],
                      child: Icon(
                        Icons.menu_book,
                        color: submitted ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book['book'] ?? 'Unknown Book',
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey[900],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_month,
                                size: 16,
                                color: Colors.blueGrey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Issued: ${issueDate != null ? DateFormat.yMMMd().format(issueDate) : 'N/A'}',
                                style: GoogleFonts.roboto(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.event,
                                size: 16,
                                color: Colors.orangeAccent,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Due: ${returnDate != null ? DateFormat.yMMMd().format(returnDate) : 'N/A'}',
                                style: GoogleFonts.roboto(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  submitted
                                      ? Colors.green[100]
                                      : Colors.red[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  submitted ? Icons.check : Icons.close,
                                  color: submitted ? Colors.green : Colors.red,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  submitted ? "Returned" : "Not Returned",
                                  style: GoogleFonts.roboto(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        submitted
                                            ? Colors.green[800]
                                            : Colors.red[800],
                                  ),
                                ),
                              ],
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
    );
  }
}
