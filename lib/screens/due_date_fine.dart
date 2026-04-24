import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'admin_screen.dart';
import 'member_management.dart';
import 'sms_notifications.dart';
import 'reports_logs.dart';
import 'signin_screen.dart';
import 'issue_return_books.dart'; // Ensure you have this import for the sidebar widget
import 'package:google_fonts/google_fonts.dart';

class DueDateFinePage extends StatefulWidget {
  const DueDateFinePage({super.key});

  @override
  _DueDateFinePageState createState() => _DueDateFinePageState();
}

class _DueDateFinePageState extends State<DueDateFinePage> {
  String _penaltyFilter = "None"; // Changed to a single filter
  final TextEditingController _searchController = TextEditingController();

  void initState() {
    super.initState();
    _syncData(); // Call cleanup on load
  }

  Future<void> _syncData() async {
    try {
      // Fetch valid students
      final studentDocs =
          await FirebaseFirestore.instance.collection('students').get();
      final validStudentEmails =
          studentDocs.docs.map((doc) => doc['email']).toSet();

      // Fetch all issue_return records
      final issueReturnSnapshot =
          await FirebaseFirestore.instance.collection('issue_return').get();
      final issueReturnDocs = issueReturnSnapshot.docs;
      final issueReturnIds = issueReturnDocs.map((doc) => doc.id).toSet();

      // Clean invalid issue_return and corresponding due_date_fine
      for (var record in issueReturnDocs) {
        final data = record.data();
        final email = data['email'];
        final docId = record.id;

        if (!validStudentEmails.contains(email)) {
          await FirebaseFirestore.instance
              .collection('issue_return')
              .doc(docId)
              .delete();

          await FirebaseFirestore.instance
              .collection('due_date_fine')
              .doc(docId)
              .delete();
        }
      }

      // Delete orphan entries from due_date_fine that don't exist in issue_return
      final dueDateFineDocs =
          await FirebaseFirestore.instance.collection('due_date_fine').get();
      for (var doc in dueDateFineDocs.docs) {
        if (!issueReturnIds.contains(doc.id)) {
          await FirebaseFirestore.instance
              .collection('due_date_fine')
              .doc(doc.id)
              .delete();
        }
      }
    } catch (e) {
      print('Error syncing data: $e');
    }
  }

  Future<void> _removeFromDueDateFine(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('due_date_fine')
          .doc(docId)
          .delete();
    } catch (e) {
      print('Error deleting due date fine: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminSidebar(
        onFeatureTap: (feature) => _handleFeatureTap(context, feature),
      ),
      appBar: AppBar(
        title: Text(
          "Due Date & Fine",
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
          children: [
            // Search and Filter
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search by student name",
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _penaltyFilter,
                  items:
                      ["None", "Ascending", "Descending"].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged:
                      (newValue) => setState(() => _penaltyFilter = newValue!),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // StreamBuilder to fetch overdue students
            Expanded(
              child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance
                        .collection('issue_return')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var records = snapshot.data!.docs;
                  DateTime now = DateTime.now();

                  // List to hold overdue students
                  List<Map<String, dynamic>> overdueStudents = [];

                  // Filter based on overdue books
                  for (var record in records) {
                    DateTime returnDate = DateTime.parse(record['returnDate']);

                    // If the book is already submitted, remove any entry in due_date_fine
                    if (record['submitted']) {
                      _removeFromDueDateFine(
                        record.id,
                      ); // Delete from due_date_fine
                      continue; // Skip to the next record
                    }

                    if (returnDate.isBefore(now)) {
                      int overdueDays = now.difference(returnDate).inDays;
                      int penalty = overdueDays;

                      overdueStudents.add({
                        'studentName': record['name'],
                        'email': record['email'],
                        'phno': record['phno'],
                        'issueDate': record['issueDate'],
                        'returnDate': record['returnDate'],
                        'class': record['class'],
                        'penalty': penalty,
                        'submitted': record['submitted'],
                      });

                      FirebaseFirestore.instance
                          .collection('due_date_fine')
                          .doc(record.id)
                          .set(
                            {
                              'name': record['name'],
                              'email': record['email'],
                              'phno': record['phno'],
                              'class': record['class'],
                              'issueDate': record['issueDate'],
                              'returnDate': record['returnDate'],
                              'penalty': penalty,
                              'submitted': record['submitted'],
                            },
                            SetOptions(merge: true),
                          ); // Use merge to avoid overwriting unintentionally
                    }
                  }

                  // Apply search filter
                  overdueStudents =
                      overdueStudents.where((student) {
                        String query = _searchController.text.toLowerCase();
                        return student['studentName'].toLowerCase().contains(
                              query,
                            ) ||
                            student['email']?.toLowerCase().contains(query) ||
                            student['class']?.toLowerCase().contains(query) ||
                            student['phno']?.toLowerCase().contains(query);
                      }).toList();

                  // Apply penalty filter (ascending/descending)
                  if (_penaltyFilter == "Ascending") {
                    overdueStudents.sort(
                      (a, b) => a['penalty'].compareTo(b['penalty']),
                    );
                  } else if (_penaltyFilter == "Descending") {
                    overdueStudents.sort(
                      (a, b) => b['penalty'].compareTo(a['penalty']),
                    );
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Student Name')),
                        DataColumn(label: Text('Student Email')),
                        DataColumn(label: Text('Student Phone Number')),
                        DataColumn(label: Text('Class')),
                        DataColumn(label: Text('Issue Date')),
                        DataColumn(label: Text('Return Date')),
                        DataColumn(label: Text('Penalty (₹)')),
                      ],
                      rows:
                          overdueStudents.map((student) {
                            return DataRow(
                              cells: [
                                DataCell(Text(student['studentName'])),
                                DataCell(Text(student['email'])),
                                DataCell(Text(student['phno'])),
                                DataCell(Text(student['class'])),
                                DataCell(
                                  Text(
                                    DateFormat.yMMMd().format(
                                      DateTime.parse(student['issueDate']),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    DateFormat.yMMMd().format(
                                      DateTime.parse(student['returnDate']),
                                    ),
                                  ),
                                ),
                                DataCell(Text(student['penalty'].toString())),
                              ],
                            );
                          }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

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
}
