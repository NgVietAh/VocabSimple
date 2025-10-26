import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:google_fonts/google_fonts.dart';
=======
>>>>>>> a84f2bf4f1df15c3e664fc13c72585042fc9c3ff
import 'package:vocabsimple/src/components/model/topic_voca.dart';
import 'package:vocabsimple/src/services/local_database_service.dart';

class VocaMainPage extends StatefulWidget {
  const VocaMainPage({super.key});

  @override
  State<VocaMainPage> createState() => _VocaMainPageState();
}

<<<<<<< HEAD
class _VocaMainPageState extends State<VocaMainPage> with RouteAware {
=======
class _VocaMainPageState extends State<VocaMainPage> {
>>>>>>> a84f2bf4f1df15c3e664fc13c72585042fc9c3ff
  List<TopicVoca> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTopicsFromSQLite();
  }

<<<<<<< HEAD
  @override
  void didPopNext() {
    // Được gọi khi quay lại trang này từ trang khác
    print('🔄 Quay lại trang Chủ đề - Đang reload...');
    loadTopicsFromSQLite();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadTopicsFromSQLite() async {
    print('🔄 Đang load danh sách chủ đề...');
    final rawTopics = await LocalDatabaseService.getTopics();
    final topicList = rawTopics.map((e) => TopicVoca.fromMap(e['topic'], e)).toList();

    print('📚 Đã load ${topicList.length} chủ đề:');
    for (var topic in topicList) {
      print('  - ${topic.name}: ${topic.percent}% (${topic.length} từ)');
    }

    if (mounted) {
      setState(() {
        items = topicList;
        isLoading = false;
      });
      print('✅ UI đã cập nhật!');
    } else {
      print('❌ Widget chưa mounted, không cập nhật UI');
    }
  }

  Future<void> _refreshTopics() async {
    await loadTopicsFromSQLite();
=======
  Future<void> loadTopicsFromSQLite() async {
    final rawTopics = await LocalDatabaseService.getTopics();
    final topicList = rawTopics.map((e) => TopicVoca.fromMap(e['topic'], e)).toList();

    setState(() {
      items = topicList;
      isLoading = false;
    });
>>>>>>> a84f2bf4f1df15c3e664fc13c72585042fc9c3ff
  }

  Widget buildImage(String path) {
    if (path.startsWith('http')) {
<<<<<<< HEAD
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(path, width: 80, height: 80, fit: BoxFit.cover),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(path, width: 80, height: 80, fit: BoxFit.cover),
      );
=======
      return Image.network(path, width: 100, height: 100, fit: BoxFit.cover);
    } else {
      return Image.asset(path, width: 100, height: 100, fit: BoxFit.cover);
>>>>>>> a84f2bf4f1df15c3e664fc13c72585042fc9c3ff
    }
  }

  Widget buildItemCard(TopicVoca item) {
<<<<<<< HEAD
    final progress = item.percent / 100.0;
    final Color progressColor = progress == 0
        ? Colors.grey[400]!
        : progress < 0.5
            ? Colors.orange[600]!
            : progress < 1.0
                ? Colors.blue[600]!
                : Colors.green[600]!;

=======
>>>>>>> a84f2bf4f1df15c3e664fc13c72585042fc9c3ff
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/flashcard',
          arguments: {
            'topic': item.topic,
            'name': item.name,
          },
<<<<<<< HEAD
        ).then((_) async {
          // Refresh khi quay lại từ flashcard
          print('⬅️ Quay lại từ flashcard - Đang refresh...');
          await loadTopicsFromSQLite();
          print('✅ Refresh hoàn tất!');
        });
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
          child: Column(
            children: [
              Row(
                children: [
                  buildImage(item.image),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${item.length} từ',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Badge % với background màu đậm
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: progressColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: progressColor.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '${item.percent}%',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                    ],
                  ),
                ],
              ),
=======
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              buildImage(item.image),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('${item.length} từ - ${item.percent}% đã học'),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
>>>>>>> a84f2bf4f1df15c3e664fc13c72585042fc9c3ff
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.blue[700]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chủ đề từ vựng',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.blue[700]),
            onPressed: _refreshTopics,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshTopics,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: items.length,
                itemBuilder: (context, index) => buildItemCard(items[index]),
              ),
=======
      appBar: AppBar(title: const Text('VocabSimple')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) => buildItemCard(items[index]),
>>>>>>> a84f2bf4f1df15c3e664fc13c72585042fc9c3ff
            ),
    );
  }
}
