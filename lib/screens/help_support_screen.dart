import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final helpOptions = [
      {
        'title': 'FAQs',
        'subtitle': 'Find answers to common questions',
        'icon': Icons.question_answer,
      },
      {
        'title': 'Contact Us',
        'subtitle': 'Reach out for further assistance',
        'icon': Icons.phone_in_talk,
      },
      {
        'title': 'Report an Issue',
        'subtitle': 'Let us know what went wrong',
        'icon': Icons.report_problem,
      },
      {
        'title': 'Feedback',
        'subtitle': 'Share your experience with us',
        'icon': Icons.feedback_outlined,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Flexible(
          child: Text(
            "Help & Support",
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

      backgroundColor: const Color(0xFFF7F9FC),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: helpOptions.length,
        itemBuilder: (context, index) {
          final item = helpOptions[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: ListTile(
              leading: Icon(
                item['icon'] as IconData,
                color: const Color(0xFF6F73D2),
                size: 28,
              ),
              title: Text(
                item['title'].toString(),
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                item['subtitle'].toString(),
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
              onTap: () {
                // Add navigation or actions if needed
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${item['title']} tapped")),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
