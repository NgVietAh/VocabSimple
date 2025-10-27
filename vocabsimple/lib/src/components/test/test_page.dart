import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TestPage extends StatefulWidget {
  final String testTitle;
  final String? topic;
  final int questionCount;

  const TestPage({
    super.key,
    required this.testTitle,
    this.topic,
    required this.questionCount,
  });

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.testTitle),
      ),
      body: Center(
        child: Text(
          'Test Page - Coming Soon',
          style: GoogleFonts.poppins(fontSize: 20),
        ),
      ),
    );
  }
}

