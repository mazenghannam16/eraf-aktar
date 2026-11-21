import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eraf_aktar/content.dart';
import 'package:eraf_aktar/main.dart';
import 'package:eraf_aktar/store.dart';

void main() {
  group('Content integrity', () {
    test('24 unique questions, 8 per category, all choices valid', () {
      expect(questions.length, 24);
      expect(questions.map((q) => q.id).toSet().length, 24);
      for (final c in categories) {
        expect(questions.where((q) => q.category == c.id).length, 8);
      }
      for (final q in questions) {
        expect(q.options.length, 4);
        expect(q.correct, inInclusiveRange(0, 3));
        expect(q.options.toSet().length, 4);
        expect(q.explanation, isNotEmpty);
      }
    });
    test('9 unique sourced facts', () {
      expect(facts.length, 9);
      expect(facts.map((f) => f.id).toSet().length, 9);
      for (final f in facts) {
        expect(f.source, isNotEmpty);
      }
    });
    test('daily fact stable within a date', () {
      expect(
        factForDay(DateTime(2026, 11, 21, 1)).id,
        factForDay(DateTime(2026, 11, 21, 23)).id,
      );
    });
    test('daily rotation changes and wraps after 9 days', () {
      final date = DateTime(2026, 11, 21);
      expect(
        factForDay(date).id,
        isNot(factForDay(date.add(const Duration(days: 1))).id),
      );
      expect(
        factForDay(date).id,
        factForDay(date.add(const Duration(days: 9))).id,
      );
    });
    test('daily fact handles dates before epoch', () {
      expect(facts, contains(factForDay(DateTime(2000))));
    });
    test('Arabic numerals', () {
      expect(ar(2026), '٢٠٢٦');
    });
  });
  group('Quiz session', () {
    test('cannot be empty', () {
      expect(() => QuizSession([]), throwsArgumentError);
    });
    test('cannot advance without an answer', () {
      final s = QuizSession(questions.take(2).toList());
      expect(s.next(), false);
      expect(s.index, 0);
    });
    test('ignores out of range answers', () {
      final s = QuizSession(questions.take(2).toList());
      s.answer(-1);
      s.answer(4);
      expect(s.answered, false);
    });
    test('locks answer and counts correct once', () {
      final s = QuizSession(questions.take(2).toList());
      s.answer(s.current.correct);
      s.answer(0);
      expect(s.score, 1);
      expect(s.answers.length, 1);
    });
    test('full round score, transition, final boundary', () {
      final s = QuizSession(questions.take(5).toList());
      for (var i = 0; i < 5; i++) {
        s.answer(s.current.correct);
        expect(s.next(), i < 4);
      }
      expect(s.score, 5);
      expect(s.isLast, true);
    });
    test('wrong answers score zero', () {
      final s = QuizSession(questions.take(1).toList());
      s.answer((s.current.correct + 1) % 4);
      expect(s.score, 0);
    });
  });
  group('Persistence', () {
    late SharedPreferences prefs;
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });
    test('empty defaults', () {
      final s = AppStore(prefs);
      expect(s.results, isEmpty);
      expect(s.average, 0);
      expect(s.dark, false);
    });
    test('result roundtrip and average', () async {
      final s = AppStore(prefs);
      await s.addResult(QuizResult('space', 4, 5, DateTime(2026, 11, 21)));
      final reload = AppStore(prefs);
      expect(reload.results.single.score, 4);
      expect(reload.average, 80);
    });
    test('favorites and theme survive recreation', () async {
      final s = AppStore(prefs);
      await s.toggleFavorite('f1');
      await s.toggleDark();
      final reload = AppStore(prefs);
      expect(reload.favorites, {'f1'});
      expect(reload.dark, true);
      await reload.toggleFavorite('f1');
      expect(AppStore(prefs).favorites, isEmpty);
    });
    test('clear removes history but keeps favorites', () async {
      final s = AppStore(prefs);
      await s.toggleFavorite('f1');
      await s.addResult(QuizResult('math', 1, 5, DateTime(2026)));
      await s.clearResults();
      expect(AppStore(prefs).results, isEmpty);
      expect(AppStore(prefs).favorites, {'f1'});
    });
    test('malformed storage recovers', () async {
      await prefs.setString('results', 'not json');
      final s = AppStore(prefs);
      expect(s.results, isEmpty);
      expect(s.error, isNotNull);
    });
    test('invalid rows ignored', () async {
      await prefs.setString(
        'results',
        jsonEncode([
          {'category': 'space', 'score': 20, 'total': 5, 'date': 'bad'},
          null,
        ]),
      );
      expect(AppStore(prefs).results, isEmpty);
    });
    test('history capped at 100 newest rows', () async {
      final s = AppStore(prefs);
      for (var i = 0; i < 102; i++) {
        await s.addResult(
          QuizResult('math', i % 6, 5, DateTime(2026, 1, 1, i)),
        );
      }
      expect(s.results.length, 100);
      expect(AppStore(prefs).results.length, 100);
    });
  });
  group('Widget flows', () {
    Future<AppStore> setup(
      WidgetTester t, {
      Size size = const Size(390, 844),
      double scale = 1,
    }) async {
      t.view.physicalSize = size;
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      final s = AppStore(await SharedPreferences.getInstance());
      await t.pumpWidget(KnowMoreApp(store: s));
      await t.pumpAndSettle();
      return s;
    }

    testWidgets('mobile home RTL no overflow', (t) async {
      await setup(t);
      expect(find.text('اعرف أكتر'), findsOneWidget);
      expect(
        Directionality.of(t.element(find.text('اعرف أكتر'))),
        TextDirection.rtl,
      );
      expect(t.takeException(), isNull);
    });
    testWidgets('small screen scroll reaches all categories', (t) async {
      await setup(t, size: const Size(320, 640));
      await t.scrollUntilVisible(find.text('الرياضيات'), 300);
      expect(find.text('الرياضيات'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
    testWidgets('desktop home no overflow', (t) async {
      await setup(t, size: const Size(1440, 1000));
      expect(find.text('الفضاء'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
    testWidgets('library bookmark + empty history', (t) async {
      final s = await setup(t);
      await t.tap(find.text('مكتبتي'));
      await t.pumpAndSettle();
      await t.tap(find.byTooltip('احفظ المعلومة').first);
      await t.pumpAndSettle();
      expect(s.favorites.length, 1);
      await t.tap(find.text('إنجازاتي'));
      await t.pumpAndSettle();
      expect(find.text('أول إنجاز في انتظارك'), findsOneWidget);
    });
    testWidgets('complete quiz, review and persist result', (t) async {
      final s = await setup(t);
      await t.scrollUntilVisible(find.text('الفضاء'), 200);
      await t.drag(find.byType(ListView).first, const Offset(0, -230));
      await t.pumpAndSettle();
      await t.tap(find.text('الفضاء'));
      await t.pumpAndSettle();
      for (var i = 0; i < 5; i++) {
        await t.tap(find.byKey(const ValueKey('option-0')));
        await t.pumpAndSettle();
        await t.scrollUntilVisible(find.byKey(const ValueKey('next')), 200);
        await t.tap(find.byKey(const ValueKey('next')));
        await t.pumpAndSettle();
      }
      expect(s.results.length, 1);
      expect(find.text('راجع اللي اتعلمته'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
    testWidgets('unfinished quiz exit confirmation', (t) async {
      final s = await setup(t);
      await t.scrollUntilVisible(find.text('الفضاء'), 200);
      await t.drag(find.byType(ListView).first, const Offset(0, -230));
      await t.pumpAndSettle();
      await t.tap(find.text('الفضاء'));
      await t.pumpAndSettle();
      await t.tap(find.byTooltip('إغلاق الجولة'));
      await t.pumpAndSettle();
      expect(find.text('تخرج من الجولة؟'), findsOneWidget);
      await t.tap(find.text('خروج'));
      await t.pumpAndSettle();
      expect(find.byType(QuizScreen), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(s.results, isEmpty);
    });
    testWidgets('dark toggle works', (t) async {
      final s = await setup(t);
      await t.tap(find.byTooltip('الوضع الليلي'));
      await t.pumpAndSettle();
      expect(s.dark, true);
      expect(t.takeException(), isNull);
    });
  });
}
