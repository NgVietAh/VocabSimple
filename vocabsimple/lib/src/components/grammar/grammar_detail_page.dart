import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vocabsimple/src/components/model/grammar.dart';

class GrammarDetailPage extends StatelessWidget {
  final Grammar grammar;

  const GrammarDetailPage({super.key, required this.grammar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.purple[700]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          grammar.title,
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description
              _buildSection(
                'Mô tả',
                Icons.info_outline,
                Colors.blue,
                Text(
                  grammar.description,
                  style: GoogleFonts.inter(fontSize: 15, height: 1.6),
                ),
              ),

              const SizedBox(height: 20),

              // Structure
              _buildSection(
                'Cấu trúc',
                Icons.account_tree_outlined,
                Colors.purple,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: grammar.structure.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.purple[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              entry.value,
                              style: GoogleFonts.robotoMono(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Rules
              _buildSection(
                'Quy tắc',
                Icons.rule,
                Colors.orange,
                Column(
                  children: grammar.rules.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.orange[600],
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${entry.key + 1}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: GoogleFonts.inter(fontSize: 14, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Examples
              _buildSection(
                'Ví dụ',
                Icons.lightbulb_outline,
                Colors.green,
                Column(
                  children: grammar.examples.map((example) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    example.en,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.only(left: 22),
                              child: Text(
                                example.vi,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Notes
              _buildSection(
                'Ghi chú',
                Icons.note_outlined,
                Colors.red,
                Column(
                  children: grammar.notes.map((note) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.star, size: 18, color: Colors.red[600]),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              note,
                              style: GoogleFonts.inter(fontSize: 14, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Color color, Widget content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }
}

