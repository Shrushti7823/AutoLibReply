import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'admin_screen.dart';
import 'member_management.dart';
import 'package:google_fonts/google_fonts.dart';
import 'due_date_fine.dart';
import 'sms_notifications.dart';
import 'reports_logs.dart';
import 'signin_screen.dart';

class IssueReturnBooksPage extends StatefulWidget {
  const IssueReturnBooksPage({super.key});

  @override
  _IssueReturnBooksPageState createState() => _IssueReturnBooksPageState();
}

class _IssueReturnBooksPageState extends State<IssueReturnBooksPage> {
  final _searchController = TextEditingController();
  String _filter = "All";

  @override
  void initState() {
    super.initState();
    _importFromStudents(); // 👈 Automatically runs when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminSidebar(
        onFeatureTap: (feature) => _handleFeatureTap(context, feature),
      ),
      appBar: AppBar(
        title: Text(
          "Issue & Return Books",
          style: GoogleFonts.lato(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.upload),
            tooltip: 'Import from Students',
            onPressed: _importFromStudents,
          ),
        ],
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
                      hintText: "Search by name, email, class, or book or phno",
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _filter,
                  items:
                      ["All", "Submitted", "Unsubmitted"].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (newValue) => setState(() => _filter = newValue!),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Issue & Return Books Table
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

                  // Filtering records based on search and filter
                  var filteredRecords =
                      records.where((record) {
                        String query = _searchController.text.toLowerCase();
                        bool matchesSearch =
                            record['name'].toLowerCase().contains(query) ||
                            record['email'].toLowerCase().contains(query) ||
                            record['class'].toLowerCase().contains(query) ||
                            record['book'].toLowerCase().contains(query) ||
                            record['phno'].toLowerCase().contains(query);

                        bool matchesFilter = false;
                        if (_filter == "All") {
                          matchesFilter = true;
                        } else if (_filter == "Submitted" &&
                            record['submitted'] == true) {
                          matchesFilter = true;
                        } else if (_filter == "Unsubmitted" &&
                            record['submitted'] == false) {
                          matchesFilter = true;
                        }

                        return matchesSearch && matchesFilter;
                      }).toList();

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Phone Number')),
                        DataColumn(label: Text('Class')),
                        DataColumn(label: Text('Book')),
                        DataColumn(label: Text('Issue Date')),
                        DataColumn(label: Text('Return Date')),

                        DataColumn(label: Text('Submitted')),
                      ],
                      rows:
                          filteredRecords.map((record) {
                            return DataRow(
                              cells: [
                                DataCell(Text(record['name'])),
                                DataCell(Text(record['email'])),
                                DataCell(Text(record['phno'])),

                                DataCell(Text(record['class'])),
                                DataCell(Text(record['book'])),
                                DataCell(
                                  Text(
                                    DateFormat.yMMMd().format(
                                      DateTime.parse(record['issueDate']),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    DateFormat.yMMMd().format(
                                      DateTime.parse(record['returnDate']),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Checkbox(
                                    value: record['submitted'] ?? false,
                                    onChanged: (value) {
                                      FirebaseFirestore.instance
                                          .collection('issue_return')
                                          .doc(record.id)
                                          .update({'submitted': value});
                                    },
                                  ),
                                ),
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

  // 🔁 Import student data into issue_return collection
  Future<void> _importFromStudents() async {
    final studentsSnapshot =
        await FirebaseFirestore.instance.collection('students').get();
    final issueReturnRef = FirebaseFirestore.instance.collection(
      'issue_return',
    );

    // Step 1: Get all student IDs
    final studentIds = studentsSnapshot.docs.map((doc) => doc.id).toSet();

    // Step 2: Sync existing students to issue_return
    for (var student in studentsSnapshot.docs) {
      final data = student.data();

      DateTime issueDate;
      try {
        issueDate = DateTime.parse(data['issueDate']);
      } catch (_) {
        print('Invalid issueDate for ${data['name']}');
        continue;
      }

      final returnDate = issueDate.add(Duration(days: 30));

      await issueReturnRef.doc(student.id).set({
        'name': data['name'],
        'email': data['email'],
        'class': data['class'],
        'book': data['book'] ?? 'N/A',
        'phno': data['phno'],
        'issueDate': issueDate.toIso8601String(),
        'returnDate': returnDate.toIso8601String(),
      }, SetOptions(merge: true));

      final issueReturnDoc = await issueReturnRef.doc(student.id).get();

      if (!issueReturnDoc.data()!.containsKey('submitted')) {
        await issueReturnRef.doc(student.id).update({'submitted': false});
      }
    }

    // Step 3: Remove issue_return docs with no matching student
    final issueReturnSnapshot = await issueReturnRef.get();
    for (var doc in issueReturnSnapshot.docs) {
      if (!studentIds.contains(doc.id)) {
        await issueReturnRef.doc(doc.id).delete();
        print('Deleted issue_return record: ${doc.id}');
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Synced successfully.')));
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
