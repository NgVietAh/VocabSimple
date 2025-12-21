import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:vocabsimple/src/components/model/grammar.dart';

class GrammarService {
  static Future<List<Grammar>> loadGrammar() async {
    try {
      print('🔍 Loading grammar.json...');
      final jsonString = await rootBundle.loadString(
        'assets/data/grammar.json',
      );
      print('✅ grammar.json loaded successfully');

      final Map<String, dynamic> data = json.decode(jsonString);
      print('📚 Found ${data.length} grammar topics');

      if (data.isEmpty) {
        print('⚠️ Warning: grammar.json is empty');
        throw Exception('File grammar.json trống');
      }

      List<Grammar> grammarList = [];
      data.forEach((key, value) {
        value['id'] = key; // Add id to the grammar object
        grammarList.add(Grammar.fromJson(value));
        print('  ✓ Loaded: $key');
      });

      print('✅ Grammar data loaded: ${grammarList.length} topics');
      return grammarList;
    } catch (e) {
      print('❌ Error loading grammar: $e');
      rethrow; // Throw lại để caller xử lý
    }
  }
}
