import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vocabsimple/src/components/model/grammar.dart';
import 'package:vocabsimple/src/services/grammar_service.dart';
import 'package:vocabsimple/src/components/grammar/grammar_detail_page.dart';

class GrammarListPage extends StatefulWidget {
  const GrammarListPage({super.key});

  @override
  State<GrammarListPage> createState() => _GrammarListPageState();
}

class _GrammarListPageState extends State<GrammarListPage> {
  List<Grammar> grammarList = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadGrammarData();
  }

  Future<void> loadGrammarData() async {
    try {
      final data = await GrammarService.loadGrammar();
      if (!mounted) return;

      if (data.isEmpty) {
        setState(() {
          grammarList = [];
          isLoading = false;
          errorMessage =
              'Không thể tải dữ liệu ngữ pháp. Vui lòng thử lại sau.';
        });
      } else {
        setState(() {
          grammarList = data;
          isLoading = false;
          errorMessage = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        grammarList = [];
        isLoading = false;
        errorMessage = 'Lỗi: $e';
      });
    }
  }

  Color getLevelColor(String level) {
    switch (level) {
      case 'basic':
        return Colors.green[600]!;
      case 'intermediate':
        return Colors.orange[600]!;
      case 'advanced':
        return Colors.red[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  String getLevelText(String level) {
    switch (level) {
      case 'basic':
        return 'Cơ bản';
      case 'intermediate':
        return 'Trung cấp';
      case 'advanced':
        return 'Nâng cao';
      default:
        return 'Khác';
    }
  }

  Widget buildGrammarCard(Grammar grammar) {
    final levelColor = getLevelColor(grammar.level);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GrammarDetailPage(
              grammar: grammar,
              allGrammarTopics: grammarList,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple[300]!, Colors.purple[500]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      grammar.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      grammar.description,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Level badge + arrow
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: levelColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      getLevelText(grammar.level),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.purple[700]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Learn Grammar',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage!,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          isLoading = true;
                          errorMessage = null;
                        });
                        loadGrammarData();
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text('Thử lại', style: GoogleFonts.inter()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : grammarList.isEmpty
          ? Center(
              child: Text(
                'Không có dữ liệu ngữ pháp',
                style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: grammarList.length,
              itemBuilder: (context, index) =>
                  buildGrammarCard(grammarList[index]),
            ),
    );
  }
}
