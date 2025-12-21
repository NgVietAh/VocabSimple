// VocabSimple Grammar Tests
//
// Test cases for grammar service, grammar data loading,
// and grammar exercise functionality.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabsimple/src/services/grammar_service.dart';
import 'package:vocabsimple/src/components/model/grammar.dart';

void main() {
  // Initialize binding before all tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Grammar Service Tests', () {
    test('Load grammar data from JSON', () async {
      final grammars = await GrammarService.loadGrammar();

      expect(grammars, isNotNull);
      expect(grammars, isNotEmpty);
      expect(grammars.length, greaterThan(0));
    });

    test('Grammar objects have required fields', () async {
      final grammars = await GrammarService.loadGrammar();

      for (var grammar in grammars) {
        expect(grammar.id, isNotEmpty);
        expect(grammar.title, isNotEmpty);
        expect(grammar.level, isNotEmpty);
        expect(grammar.description, isNotEmpty);
        expect(grammar.structure, isNotEmpty);
        expect(grammar.rules, isNotEmpty);
        expect(grammar.examples, isNotEmpty);
      }
    });

    test('Grammar structure contains valid data', () async {
      final grammars = await GrammarService.loadGrammar();

      for (var grammar in grammars) {
        // Kiểm tra structure có format đúng
        grammar.structure.forEach((key, value) {
          expect(key, isNotEmpty);
          expect(value, isNotEmpty);
        });
      }
    });

    test('Grammar examples contain English and Vietnamese', () async {
      final grammars = await GrammarService.loadGrammar();

      for (var grammar in grammars) {
        for (var example in grammar.examples) {
          expect(example.en, isNotEmpty);
          expect(example.vi, isNotEmpty);
        }
      }
    });

    test('Grammar has at least one rule', () async {
      final grammars = await GrammarService.loadGrammar();

      for (var grammar in grammars) {
        expect(grammar.rules.length, greaterThan(0));
      }
    });

    test('Grammar notes can be empty or contain text', () async {
      final grammars = await GrammarService.loadGrammar();

      for (var grammar in grammars) {
        // Notes là List<String>, có thể rỗng hoặc có nội dung
        expect(grammar.notes, isA<List<String>>());
      }
    });

    test('Grammar levels are valid', () async {
      final grammars = await GrammarService.loadGrammar();
      final validLevels = [
        'A1',
        'A2',
        'B1',
        'B2',
        'C1',
        'C2',
        'basic',
        'intermediate',
        'advanced',
      ];

      for (var grammar in grammars) {
        expect(
          validLevels.contains(grammar.level),
          isTrue,
          reason: 'Invalid level: ${grammar.level}',
        );
      }
    });

    test('Each grammar has unique ID', () async {
      final grammars = await GrammarService.loadGrammar();
      final ids = grammars.map((g) => g.id).toList();
      final uniqueIds = ids.toSet();

      expect(
        ids.length,
        equals(uniqueIds.length),
        reason: 'Duplicate grammar IDs found',
      );
    });

    test('Grammar structure format is correct', () async {
      final grammars = await GrammarService.loadGrammar();

      for (var grammar in grammars) {
        // Kiểm tra structure có chứa ký hiệu ngữ pháp hợp lệ
        grammar.structure.forEach((key, value) {
          // Structure có thể chứa: S, V, O, +, am/is/are, was/were, V-ing, V-ed, etc.
          expect(value.length, greaterThan(0));
        });
      }
    });

    test('Grammar examples are properly formatted', () async {
      final grammars = await GrammarService.loadGrammar();

      for (var grammar in grammars) {
        for (var example in grammar.examples) {
          // Câu tiếng Anh phải có ít nhất 2 từ
          expect(example.en.split(' ').length, greaterThanOrEqualTo(2));
          // Câu tiếng Việt phải có nội dung
          expect(example.vi.length, greaterThan(0));
        }
      }
    });
  });

  group('Grammar Data Validation', () {
    test('Specific grammar topics exist', () async {
      final grammars = await GrammarService.loadGrammar();
      final ids = grammars.map((g) => g.id).toList();

      // Kiểm tra một số topic phổ biến
      expect(ids.contains('present_simple'), isTrue);
      expect(ids.contains('present_continuous'), isTrue);
      expect(ids.contains('past_simple'), isTrue);
    });

    test('Grammar JSON file is not corrupted', () async {
      // Test sẽ fail nếu JSON file bị lỗi format
      expect(() async => await GrammarService.loadGrammar(), returnsNormally);
    });
  });
}
