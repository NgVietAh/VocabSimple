class Grammar {
  String id;
  String title;
  String level;
  String description;
  Map<String, String> structure;
  List<String> rules;
  List<GrammarExample> examples;
  List<String> notes;

  Grammar({
    required this.id,
    required this.title,
    required this.level,
    required this.description,
    required this.structure,
    required this.rules,
    required this.examples,
    required this.notes,
  });

  factory Grammar.fromJson(Map<String, dynamic> json) {
    return Grammar(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      level: json['level'] ?? 'basic',
      description: json['description'] ?? '',
      structure: Map<String, String>.from(json['structure'] ?? {}),
      rules: List<String>.from(json['rules'] ?? []),
      examples: (json['examples'] as List?)
              ?.map((e) => GrammarExample.fromJson(e))
              .toList() ??
          [],
      notes: List<String>.from(json['notes'] ?? []),
    );
  }
}

class GrammarExample {
  String en;
  String vi;

  GrammarExample({required this.en, required this.vi});

  factory GrammarExample.fromJson(Map<String, dynamic> json) {
    return GrammarExample(
      en: json['en'] ?? '',
      vi: json['vi'] ?? '',
    );
  }
}

