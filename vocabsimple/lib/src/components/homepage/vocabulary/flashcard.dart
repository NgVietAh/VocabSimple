import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_tts/flutter_tts.dart';

class FlashcardPage extends StatefulWidget {
  final String topic;
  final String name;

  const FlashcardPage({super.key, required this.topic, required this.name});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  final List<Map<String, dynamic>> words = [];
  final FlutterTts flutterTts = FlutterTts();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadWords();
  }

  Future<void> loadWords() async {
    final ref = FirebaseDatabase.instance
        .ref()
        .child('vocabulary')
        .child(widget.topic)
        .child('words');

    final snapshot = await ref.get();
    final data = snapshot.value as Map?;
    if (data != null) {
      data.forEach((key, value) {
        words.add({
          'name': value['name'] ?? '',
          'phonetic': value['phonetic'] ?? '',
          'translate': value['translate'] ?? '',
        });
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget buildCard(Map<String, dynamic> word) {
    return FlipCard(
      direction: FlipDirection.HORIZONTAL,
      front: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: Text(
            word['name'],
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      back: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.volume_up),
              label: const Text("Phát âm"),
              onPressed: () => flutterTts.speak(word['name']),
            ),
            const SizedBox(height: 8),
            Text('/${word['phonetic']}/', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(word['translate'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
              itemCount: words.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: buildCard(words[index]),
              ),
            ),
    );
  }
}
