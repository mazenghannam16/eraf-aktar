import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'content.dart';

class QuizResult {
  final String category;
  final int score, total;
  final DateTime date;
  const QuizResult(this.category, this.score, this.total, this.date);
  Map<String, dynamic> toJson() => {
    'category': category,
    'score': score,
    'total': total,
    'date': date.toIso8601String(),
  };
  static QuizResult? fromJson(dynamic value) {
    try {
      final m = Map<String, dynamic>.from(value as Map);
      final score = m['score'] as int, total = m['total'] as int;
      final category = m['category'] as String;
      if (total < 1 ||
          score < 0 ||
          score > total ||
          !categories.any((c) => c.id == category)) {
        return null;
      }
      return QuizResult(
        category,
        score,
        total,
        DateTime.parse(m['date'] as String),
      );
    } catch (_) {
      return null;
    }
  }
}

class QuizSession {
  final List<Question> items;
  int index = 0;
  final List<int> answers = [];
  QuizSession(this.items) {
    if (items.isEmpty) {
      throw ArgumentError('Quiz cannot be empty');
    }
  }
  Question get current => items[index];
  bool get answered => answers.length > index;
  bool get isLast => index == items.length - 1;
  int get score => List.generate(
    answers.length,
    (i) => answers[i] == items[i].correct ? 1 : 0,
  ).fold(0, (a, b) => a + b);
  void answer(int choice) {
    if (answered || choice < 0 || choice >= current.options.length) {
      return;
    }
    answers.add(choice);
  }

  bool next() {
    if (!answered || isLast) {
      return false;
    }
    index++;
    return true;
  }
}

class AppStore extends ChangeNotifier {
  final SharedPreferences prefs;
  bool dark = false;
  String? error;
  List<QuizResult> results = [];
  Set<String> favorites = {};
  AppStore(this.prefs) {
    dark = prefs.getBool('dark') ?? false;
    try {
      final decoded = jsonDecode(prefs.getString('results') ?? '[]');
      if (decoded is List) {
        results = decoded
            .map(QuizResult.fromJson)
            .whereType<QuizResult>()
            .take(100)
            .toList();
      }
    } catch (_) {
      error = 'تعذر قراءة بعض النتائج القديمة. يمكنك بدء اختبار جديد.';
    }
    favorites = (prefs.getStringList('favorites') ?? [])
        .where((id) => facts.any((f) => f.id == id))
        .toSet();
  }
  Future<void> _save(Future<bool> Function() action) async {
    try {
      if (!await action()) {
        throw StateError('Storage rejected write');
      }
      error = null;
    } catch (_) {
      error = 'تعذر الحفظ على الجهاز. قد لا تبقى التغييرات بعد إغلاق التطبيق.';
    }
    notifyListeners();
  }

  Future<void> toggleDark() async {
    dark = !dark;
    notifyListeners();
    await _save(() => prefs.setBool('dark', dark));
  }

  Future<void> toggleFavorite(String id) async {
    if (favorites.contains(id)) {
      favorites.remove(id);
    } else {
      favorites.add(id);
    }
    notifyListeners();
    await _save(() => prefs.setStringList('favorites', favorites.toList()));
  }

  Future<void> addResult(QuizResult result) async {
    results.insert(0, result);
    results = results.take(100).toList();
    notifyListeners();
    await _save(
      () => prefs.setString(
        'results',
        jsonEncode(results.map((e) => e.toJson()).toList()),
      ),
    );
  }

  Future<void> clearResults() async {
    results.clear();
    notifyListeners();
    await _save(() => prefs.remove('results'));
  }

  int get average => results.isEmpty
      ? 0
      : (results.map((r) => r.score / r.total * 100).reduce((a, b) => a + b) /
                results.length)
            .round();
}
