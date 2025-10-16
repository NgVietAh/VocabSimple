import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:vocabsimple/src/components/model/topic_voca.dart';

class VocaMainPage extends StatefulWidget {
  const VocaMainPage({super.key});

  @override
  State<VocaMainPage> createState() => _VocaMainPageState();
}

class _VocaMainPageState extends State<VocaMainPage> {
  final databaseRef = FirebaseDatabase.instance.ref().child('vocabulary');
  List<TopicVoca> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTopics();
  }

  Future<void> loadTopics() async {
    final snapshot = await databaseRef.get();
    final data = snapshot.value as Map?;
    if (data != null) {
      data.forEach((key, value) {
        final topic = TopicVoca.fromMap(key, value);
        items.add(topic);
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  Widget buildImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(path, width: 100, height: 100, fit: BoxFit.cover);
    } else {
      return Image.asset(path, width: 100, height: 100, fit: BoxFit.cover);
    }
  }

  Widget buildItemCard(TopicVoca item) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/flashcard',
          arguments: {
            'topic': item.topic,
            'name': item.name,
          },
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VocabSimple')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) => buildItemCard(items[index]),
            ),
    );
  }
}
