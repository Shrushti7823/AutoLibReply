import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'admin_screen.dart';
import 'member_management.dart';
import 'due_date_fine.dart';
import 'issue_return_books.dart';
import 'reports_logs.dart';
import 'signin_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SmsNotificationsPage extends StatefulWidget {
  const SmsNotificationsPage({super.key});

  @override
  _SmsNotificationsPageState createState() => _SmsNotificationsPageState();
}

class _SmsNotificationsPageState extends State<SmsNotificationsPage> {
  final _searchController = TextEditingController();
  int _notificationsSent = 0;
  DateTime? _lastSentTime;
  bool _isAscending = true; // Track the sorting order

  int _calculatePenalty(DateTime returnDate) {
    final currentDate = DateTime.now();
    if (returnDate.isBefore(currentDate)) {
      return currentDate.difference(returnDate).inDays;
    }
    return 0;
  }

  // Toggle the sorting order
  void _toggleSortOrder() {
    setState(() {
      _isAscending = !_isAscending;
    });
  }

  Future<void> _sendSmsNotification(String phoneNumber, String message) async {
    const String twilioSID = 'YOUR_TWILIO_SID';
    const String twilioAuthToken = 'YOUR_AUTH_TOKEN';
    const String twilioPhoneNumber =  'YOUR_TWILIO_NUMBER';

    if (phoneNumber.isEmpty) return;

    String formattedPhone = phoneNumber;
    if (!phoneNumber.startsWith('+')) {
      formattedPhone = '+91$phoneNumber';
    }

    final Uri url = Uri.parse(
      'https://api.twilio.com/2010-04-01/Accounts/$twilioSID/Messages.json',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization':
              'Basic ' +
              base64Encode(utf8.encode('$twilioSID:$twilioAuthToken')),
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'From': twilioPhoneNumber,
          'To': formattedPhone,
          'Body': message,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('SMS sent successfully');
      } else {
        final errorData = json.decode(response.body);
        print('Failed to send SMS: ${errorData['message']}');
      }
    } catch (e) {
      print('Error sending SMS: $e');
    }
  }

  Future<void> _sendNotificationForUser(
    String studentName,
    String phoneNumber,
    DateTime returnDate,
  ) async {
    int penalty = _calculatePenalty(returnDate);

    if (penalty > 0) {
      String message =
          "Hello $studentName, you have a penalty of ₹$penalty for returning the book late. Please return it as soon as possible.";

      await _sendSmsNotification(phoneNumber, message);
      await _recordNotification(
        name: studentName,
        phone: phoneNumber,
        message: message,
      ); // <-- Log it

      setState(() {
        _notificationsSent++;
        _lastSentTime = DateTime.now();
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('SMS sent to $studentName')));
    }
  }

  Future<void> _sendAllNotifications(List<DocumentSnapshot> records) async {
    for (var record in records) {
      try {
        DateTime returnDate = DateTime.parse(record['returnDate']);
        String name = record['name'] ?? 'Unknown';
        String phone = record['phno'] ?? '';
        await _sendNotificationForUser(name, phone, returnDate);
      } catch (e) {
        print('Error processing record: $e');
      }
    }
  }

  Future<void> _recordNotification({
    required String name,
    required String phone,
    required String message,
  }) async {
    await FirebaseFirestore.instance.collection('notifications_sent').add({
      'name': name,
      'phone': phone,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminSidebar(
        onFeatureTap: (feature) => _handleFeatureTap(context, feature),
      ),
      appBar: AppBar(
        title: const Text(
          "SMS Notifications",
          style: TextStyle(
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifications Sent: $_notificationsSent',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _lastSentTime != null
                              ? 'Last Sent: ${DateFormat('MMM d, yyyy – h:mm a').format(_lastSentTime!)}'
                              : 'Last Sent: Never',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final snapshot =
                            await FirebaseFirestore.instance
                                .collection('due_date_fine')
                                .get();
                        await _sendAllNotifications(snapshot.docs);
                      },
                      icon: const Icon(Icons.send),
                      label: const Text("Send All"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by name, email, class, or book",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text('Sort by penalty:'),
                IconButton(
                  icon: Icon(
                    _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  ),
                  onPressed: _toggleSortOrder,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('due_date_fine')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var records = snapshot.data!.docs;
                  var query = _searchController.text.toLowerCase();
                  var filteredRecords =
                      records.where((r) {
                        final data = r.data() as Map<String, dynamic>;
                        return (data['name'] ?? '').toLowerCase().contains(
                              query,
                            ) ||
                            (data['email'] ?? '').toLowerCase().contains(
                              query,
                            ) ||
                            (data['className'] ?? '').toLowerCase().contains(
                              query,
                            ) ||
                            (data['issueDate'] ?? '').toLowerCase().contains(
                              query,
                            ) ||
                            (data['returnDate'] ?? '').toLowerCase().contains(
                              query,
                            ) ||
                            data['penalty'].toString().contains(query);
                      }).toList();

                  // Sort records based on penalty
                  filteredRecords.sort((a, b) {
                    final penaltyA = _calculatePenalty(
                      DateTime.parse(
                        (a.data() as Map<String, dynamic>)['returnDate'],
                      ),
                    );
                    final penaltyB = _calculatePenalty(
                      DateTime.parse(
                        (b.data() as Map<String, dynamic>)['returnDate'],
                      ),
                    );

                    return _isAscending
                        ? penaltyA.compareTo(penaltyB)
                        : penaltyB.compareTo(penaltyA);
                  });

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Phone')),
                        DataColumn(label: Text('Class')),
                        DataColumn(label: Text('Issue Date')),
                        DataColumn(label: Text('Return Date')),
                        DataColumn(label: Text('Penalty')),
                        DataColumn(label: Text('Send')),
                      ],
                      rows:
                          filteredRecords.map((record) {
                            final data = record.data() as Map<String, dynamic>;
                            DateTime returnDate = DateTime.parse(
                              data['returnDate'],
                            );
                            DateTime issueDate = DateTime.parse(
                              data['issueDate'],
                            );
                            String name = data['name'] ?? '';
                            String phone = data['phno'] ?? '';
                            int penalty = _calculatePenalty(returnDate);

                            return DataRow(
                              cells: [
                                DataCell(Text(name)),
                                DataCell(Text(data['email'] ?? '')),
                                DataCell(Text(phone)),
                                DataCell(Text(data['class'] ?? '')),
                                DataCell(
                                  Text(DateFormat.yMMMd().format(issueDate)),
                                ),
                                DataCell(
                                  Text(DateFormat.yMMMd().format(returnDate)),
                                ),
                                DataCell(Text(penalty.toString())),
                                DataCell(
                                  ElevatedButton(
                                    onPressed: () async {
                                      await _sendNotificationForUser(
                                        name,
                                        phone,
                                        returnDate,
                                      );
                                    },
                                    child: const Text("Send"),
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
