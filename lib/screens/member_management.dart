import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'admin_screen.dart';
import 'due_date_fine.dart';
import 'sms_notifications.dart';
import 'reports_logs.dart';
import 'signin_screen.dart';
import 'issue_return_books.dart';

class MemberManagementPage extends StatefulWidget {
  const MemberManagementPage({super.key});

  @override
  _MemberManagementPageState createState() => _MemberManagementPageState();
}

class _MemberManagementPageState extends State<MemberManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _bookController = TextEditingController();
  final TextEditingController _phnoController = TextEditingController();
  DateTime? _issueDate;
  String _filter = "All";
  String? _editingId;

  Future<void> _saveStudent() async {
    if (_formKey.currentState!.validate()) {
      if (_issueDate == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Please select an issue date")));
        return;
      }

      // Determine if this is a new record or an update
      bool isUpdate = _editingId != null;

      if (isUpdate) {
        // Show confirmation dialog for update
        bool confirmUpdate =
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Confirm Update"),
                  content: Text(
                    "Are you sure you want to update ${_nameController.text}'s record?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        "Update",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                );
              },
            ) ??
            false;

        if (!confirmUpdate) {
          return; // Exit if user cancelled
        }
      }

      await FirebaseFirestore.instance
          .collection('students')
          .doc(_editingId ?? _idController.text)
          .set({
            'name': _nameController.text,
            'email': _emailController.text,
            'class': _classController.text,
            'id': _idController.text,
            'book': _bookController.text,
            'phno': _phnoController.text,
            'issueDate': _issueDate!.toIso8601String(),
          });

      // Show appropriate success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isUpdate
                ? "Record updated Successfully"
                : "Record saved Successfully",
          ),
          backgroundColor: Colors.green,
        ),
      );

      _clearForm();
    }
  }

  // Function to delete student record
  Future<void> _deleteStudent(String documentId, String studentName) async {
    // Show confirmation dialog
    bool confirmDelete =
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Confirm Delete"),
              content: Text(
                "Are you sure you want to delete $studentName's record?",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text("Delete", style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmDelete) {
      // Proceed with deletion
      await FirebaseFirestore.instance
          .collection('students')
          .doc(documentId)
          .delete();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Record deleted Successfully"),
          backgroundColor: Colors.red,
        ),
      );

      // Clear form if the deleted record was being edited
      if (_editingId == documentId) {
        _clearForm();
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _classController.clear();
    _idController.clear();
    _bookController.clear();
    _phnoController.clear();
    setState(() {
      _issueDate = null;
      _editingId = null;
    });
  }

  List<DocumentSnapshot> _applyFilter(List<DocumentSnapshot> students) {
    DateTime now = DateTime.now();
    return students.where((student) {
      DateTime issueDate = DateTime.parse(student['issueDate']);
      if (_filter == "Last Day" &&
          issueDate.isAfter(now.subtract(Duration(days: 1))))
        return true;
      if (_filter == "Last Week" &&
          issueDate.isAfter(now.subtract(Duration(days: 7))))
        return true;
      if (_filter == "Last Month" &&
          issueDate.isAfter(now.subtract(Duration(days: 30))))
        return true;
      return _filter == "All";
    }).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminSidebar(
        onFeatureTap: (feature) => _handleFeatureTap(context, feature),
      ),
      appBar: AppBar(
        title: Text(
          "Member Management",
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Student Name',
                        ),
                        validator:
                            (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Required'
                                    : null,
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email ID',
                        ),
                        validator:
                            (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Required'
                                    : null,
                      ),
                      TextFormField(
                        controller: _classController,
                        decoration: const InputDecoration(labelText: 'Class'),
                        validator:
                            (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Required'
                                    : null,
                      ),
                      TextFormField(
                        controller: _idController,
                        decoration: const InputDecoration(labelText: 'ID'),
                        validator:
                            (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Required'
                                    : null,
                      ),
                      TextFormField(
                        controller: _phnoController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                        ),
                        validator:
                            (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Required'
                                    : null,
                      ),
                      TextFormField(
                        controller: _bookController,
                        decoration: const InputDecoration(
                          labelText: 'Book Name',
                        ),
                        validator:
                            (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Required'
                                    : null,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() => _issueDate = picked);
                              }
                            },
                            child: Text(
                              _issueDate == null
                                  ? "Select Issue Date"
                                  : "Date: ${DateFormat.yMMMd().format(_issueDate!)}",
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _saveStudent,
                            child: Text(_editingId == null ? "Save" : "Update"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Search and Filter
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search by name, class, or book",
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _filter,
                  items:
                      ["All", "Last Day", "Last Week", "Last Month"].map((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (newValue) => setState(() => _filter = newValue!),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Student List
            SizedBox(
              height: 400, // You can adjust this height
              child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance
                        .collection('students')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());
                  var students =
                      _applyFilter(snapshot.data!.docs).where((student) {
                        String query = _searchController.text.toLowerCase();
                        return student['name'].toLowerCase().contains(query) ||
                            student['email'].toLowerCase().contains(query) ||
                            student['class'].toLowerCase().contains(query) ||
                            student['book'].toLowerCase().contains(query) ||
                            student['phno'].toLowerCase().contains(query);
                      }).toList();

                  return ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      var student = students[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            "${student['name']} - ${student['class']}",
                            style: GoogleFonts.lato(fontSize: 18),
                          ),
                          subtitle: Text(
                            "Email: ${student['email']} | Book: ${student['book']} | Issue Date: ${DateFormat.yMMMd().format(DateTime.parse(student['issueDate']))}",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  setState(() {
                                    _editingId = student.id;
                                    _nameController.text = student['name'];
                                    _emailController.text = student['email'];
                                    _classController.text = student['class'];
                                    _idController.text = student['id'];
                                    _bookController.text = student['book'];
                                    _phnoController.text = student['phno'];
                                    _issueDate = DateTime.parse(
                                      student['issueDate'],
                                    );
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed:
                                    () => _deleteStudent(
                                      student.id,
                                      student['name'],
                                    ),
                              ),
                            ],
                          ),
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
