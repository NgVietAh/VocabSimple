import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:vocabsimple/src/components/model/grammar.dart';

class GrammarService {
  static Future<List<Grammar>> loadGrammar() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/grammar.json');
      final Map<String, dynamic> data = json.decode(jsonString);

      List<Grammar> grammarList = [];
      data.forEach((key, value) {
        value['id'] = key; // Add id to the grammar object
        grammarList.add(Grammar.fromJson(value));
      });

      print('✅ Đã load ${grammarList.length} điểm ngữ pháp');
      return grammarList;
    } catch (e) {
      print('❌ Lỗi load grammar: $e');
      return [];
    }
  }
}

