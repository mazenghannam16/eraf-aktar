import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'content.dart';
import 'store.dart';

const purple = Color(0xff7460d2);
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(KnowMoreApp(store: AppStore(prefs)));
}

class KnowMoreApp extends StatelessWidget {
  final AppStore store;
  const KnowMoreApp({super.key, required this.store});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => MaterialApp(
      title: 'اعرف أكتر',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      themeMode: store.dark ? ThemeMode.dark : ThemeMode.light,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      home: HomeScreen(store: store),
    ),
  );
  ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'NotoArabic',
      colorScheme: ColorScheme.fromSeed(
        seedColor: purple,
        brightness: brightness,
        surface: dark ? const Color(0xff171724) : const Color(0xfffaf9f6),
      ),
      scaffoldBackgroundColor: dark
          ? const Color(0xff171724)
          : const Color(0xfffaf9f6),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: dark ? const Color(0xff232335) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
      ),
    );
  }
}

String ar(num value) => value.toString().replaceAllMapped(
  RegExp('[0-9]'),
  (m) => '٠١٢٣٤٥٦٧٨٩'[int.parse(m[0]!)],
);
String dateLabel(DateTime d) => '${ar(d.day)}/${ar(d.month)}/${ar(d.year)}';
QuizCategory cat(String id) => categories.firstWhere((c) => c.id == id);
IconData catIcon(String id) => switch (id) {
  'space' => Icons.public_rounded,
  'code' => Icons.code_rounded,
  _ => Icons.calculate_outlined,
};

class HomeScreen extends StatefulWidget {
  final AppStore store;
  const HomeScreen({super.key, required this.store});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tab = 0;
  AppStore get store => widget.store;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: purple,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 11),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'اعرف أكتر',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'مساحة صغيرة.. لمعرفة أكبر',
                          style: TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: store.dark ? 'الوضع الفاتح' : 'الوضع الليلي',
                    onPressed: store.toggleDark,
                    icon: Icon(
                      store.dark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              if (store.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    store.error!,
                    style: const TextStyle(color: Colors.deepOrange),
                  ),
                ),
              if (tab == 0) ..._home(context),
              if (tab == 1) ..._library(context),
              if (tab == 2) ..._history(context),
            ],
          ),
        ),
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: tab,
      onDestinationSelected: (i) => setState(() => tab = i),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'الرئيسية',
        ),
        NavigationDestination(
          icon: Icon(Icons.bookmark_border_rounded),
          selectedIcon: Icon(Icons.bookmark_rounded),
          label: 'مكتبتي',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_rounded),
          label: 'إنجازاتي',
        ),
      ],
    ),
  );
  List<Widget> _home(BuildContext context) => [
    const Text(
      'كل يوم، فكرة جديدة ✨',
      style: TextStyle(
        fontSize: 13,
        color: purple,
        fontWeight: FontWeight.w600,
      ),
    ),
    const SizedBox(height: 5),
    const Text(
      'فضولك.. بداية الحكاية',
      style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800),
    ),
    const SizedBox(height: 8),
    const Text(
      'اكتشف معلومة، جرّب كويز، وخلي كل يوم أذكى.',
      style: TextStyle(fontSize: 13, height: 1.8),
    ),
    const SizedBox(height: 24),
    _dailyCard(context),
    const SizedBox(height: 22),
    Row(
      children: [
        _metric(ar(questions.length), 'سؤال وتفسير', Icons.quiz_outlined),
        const SizedBox(width: 10),
        _metric(
          ar(store.results.length),
          'اختبار مكتمل',
          Icons.check_circle_outline,
        ),
        const SizedBox(width: 10),
        _metric('${ar(store.average)}٪', 'متوسط نتيجتك', Icons.trending_up),
      ],
    ),
    const SizedBox(height: 28),
    const Text(
      'جاهز لتحدي صغير؟',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
    ),
    const SizedBox(height: 4),
    const Text(
      'اختار مجالك • ٥ أسئلة في كل جولة',
      style: TextStyle(fontSize: 12),
    ),
    const SizedBox(height: 16),
    LayoutBuilder(
      builder: (context, c) => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: categories
            .map(
              (category) => SizedBox(
                width: c.maxWidth >= 650 ? (c.maxWidth - 24) / 3 : c.maxWidth,
                child: _categoryCard(context, category),
              ),
            )
            .toList(),
      ),
    ),
    const SizedBox(height: 22),
    TextButton.icon(
      onPressed: () => _about(context),
      icon: const Icon(Icons.info_outline, size: 18),
      label: const Text('عن التطبيق والخصوصية'),
    ),
  ];
  Widget _dailyCard(BuildContext context) {
    final fact = factForDay(DateTime.now());
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff7a62d6), Color(0xff4b3f8f)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.wb_sunny_outlined,
                color: Color(0xffffdfa4),
                size: 21,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'جرعة معرفة اليوم',
                  style: TextStyle(color: Color(0xffe1d8ff), fontSize: 12),
                ),
              ),
              IconButton(
                tooltip: store.favorites.contains(fact.id)
                    ? 'إزالة من المحفوظات'
                    : 'احفظ المعلومة',
                onPressed: () => store.toggleFavorite(fact.id),
                icon: Icon(
                  store.favorites.contains(fact.id)
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            fact.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            fact.body,
            style: const TextStyle(
              fontSize: 14,
              height: 1.9,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'المصدر: ${fact.source}',
            style: const TextStyle(
              fontSize: 10,
              height: 1.6,
              color: Color(0xffdfd7fa),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String number, String label, IconData icon) => Expanded(
    child: Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 5),
        child: Column(
          children: [
            Icon(icon, color: purple, size: 20),
            const SizedBox(height: 7),
            Text(
              number,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
            ),
            Text(label, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    ),
  );
  Widget _categoryCard(BuildContext context, QuizCategory category) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => _start(context, category),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Color(category.color).withValues(alpha: .12),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Icon(
                catIcon(category.id),
                color: Color(category.color),
                size: 29,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(category.subtitle, style: const TextStyle(fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.arrow_back_rounded, size: 19),
          ],
        ),
      ),
    ),
  );
  void _start(BuildContext context, QuizCategory category) {
    final pool = questions.where((q) => q.category == category.id).toList()
      ..shuffle(Random());
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuizScreen(
          store: store,
          category: category,
          items: pool.take(5).toList(),
        ),
      ),
    );
  }

  List<Widget> _library(BuildContext context) => [
    const Text(
      'مكتبتك الصغيرة',
      style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800),
    ),
    const SizedBox(height: 6),
    const Text(
      'معلومات تستحق الرجوع لها. اضغط علامة الحفظ لإضافتها.',
      style: TextStyle(fontSize: 12),
    ),
    const SizedBox(height: 20),
    if (store.favorites.isEmpty)
      const Padding(
        padding: EdgeInsets.all(20),
        child: Text('لم تحفظ أي معلومة بعد. تصفح البطاقات التالية ✨'),
      ),
    ...[
      ...facts.where((f) => store.favorites.contains(f.id)),
      ...facts.where((f) => !store.favorites.contains(f.id)),
    ].map(
      (f) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        f.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: store.favorites.contains(f.id)
                          ? 'إزالة من المحفوظات'
                          : 'احفظ المعلومة',
                      onPressed: () => store.toggleFavorite(f.id),
                      icon: Icon(
                        store.favorites.contains(f.id)
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: purple,
                      ),
                    ),
                  ],
                ),
                Text(f.body, style: const TextStyle(height: 1.9, fontSize: 13)),
                const SizedBox(height: 12),
                Text(
                  'المصدر: ${f.source}',
                  style: const TextStyle(fontSize: 10, color: purple),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ];
  List<Widget> _history(BuildContext context) => [
    const Text(
      'خطوة أقرب للمعرفة',
      style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800),
    ),
    const SizedBox(height: 8),
    const Text(
      'نتائجك محفوظة على هذا الجهاز فقط.',
      style: TextStyle(fontSize: 12),
    ),
    const SizedBox(height: 24),
    Row(
      children: [
        _metric(ar(store.results.length), 'جولة مكتملة', Icons.flag_outlined),
        const SizedBox(width: 12),
        _metric('${ar(store.average)}٪', 'متوسط الدقة', Icons.insights),
      ],
    ),
    const SizedBox(height: 24),
    if (store.results.isEmpty)
      Card(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Icon(Icons.emoji_events_outlined, size: 52, color: purple),
              const SizedBox(height: 14),
              const Text('أول إنجاز في انتظارك'),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () => setState(() => tab = 0),
                child: const Text('ابدأ أول كويز'),
              ),
            ],
          ),
        ),
      ),
    ...store.results.map(
      (r) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: purple.withValues(alpha: .12),
              child: Icon(catIcon(r.category), color: purple),
            ),
            title: Text(
              cat(r.category).title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(dateLabel(r.date)),
            trailing: Text(
              '${ar(r.score)} / ${ar(r.total)}',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: purple,
              ),
            ),
          ),
        ),
      ),
    ),
    if (store.results.isNotEmpty)
      TextButton.icon(
        onPressed: () => _clear(context),
        icon: const Icon(Icons.delete_outline),
        label: const Text('مسح سجل النتائج'),
      ),
  ];
  Future<void> _clear(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('تمسح كل النتائج؟'),
        content: const Text(
          'لا يمكن التراجع عن المسح. ستبقى معلوماتك المحفوظة كما هي.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('مسح النتائج'),
          ),
        ],
      ),
    );
    if (yes == true) {
      await store.clearResults();
    }
  }

  void _about(BuildContext context) => showDialog<void>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('اعرف أكتر • ١.٠'),
      content: const SingleChildScrollView(
        child: Text(
          'تطبيق تعليمي تجريبي ضمن بورتفوليو Mazen Dev.\n\n٢٤ سؤالًا و٩ معلومات في الفضاء والتقنية والرياضيات. تتغير معلومة اليوم حسب تاريخ الجهاز، ثم تتكرر بعد ٩ أيام.\n\nالنتائج والمحفوظات والثيم تُحفظ محليًا فقط. لا حسابات، لا تتبع، لا مزامنة، ولا جمع بيانات. مسح بيانات المتصفح أو التطبيق يحذف المحفوظات.\n\nالمحتوى للمعلومات العامة. تمت كتابة التطبيق بمساعدة الذكاء الاصطناعي، ولا يُقدّم كعمل يدوي منفرد.\n\nالمصادر وروابطها وتفاصيل الاختبارات موجودة في README.',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c),
          child: const Text('تمام'),
        ),
      ],
    ),
  );
}

class QuizScreen extends StatefulWidget {
  final AppStore store;
  final QuizCategory category;
  final List<Question> items;
  const QuizScreen({
    super.key,
    required this.store,
    required this.category,
    required this.items,
  });
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final QuizSession session = QuizSession(widget.items);
  bool finished = false, saving = false;
  Future<bool> _leave() async {
    if (finished) {
      return true;
    }
    return await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('تخرج من الجولة؟'),
            content: const Text('لن تُحفظ الجولة غير المكتملة.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('نكمل'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(c, true),
                child: const Text('خروج'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _next() async {
    if (saving) {
      return;
    }
    if (!session.isLast) {
      setState(() => session.next());
      return;
    }
    setState(() => saving = true);
    await widget.store.addResult(
      QuizResult(
        widget.category.id,
        session.score,
        session.items.length,
        DateTime.now(),
      ),
    );
    if (mounted) {
      setState(() {
        finished = true;
        saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: finished,
    onPopInvokedWithResult: (didPop, result) async {
      if (!didPop && await _leave() && context.mounted) {
        Navigator.of(context).pop();
      }
    },
    child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.category.title),
        actions: [
          IconButton(
            tooltip: 'إغلاق الجولة',
            onPressed: () async {
              if (await _leave() && context.mounted) {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: finished ? _result() : _question(),
            ),
          ),
        ),
      ),
    ),
  );
  List<Widget> _question() {
    final q = session.current;
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'السؤال ${ar(session.index + 1)} من ${ar(session.items.length)}',
            style: const TextStyle(color: purple, fontWeight: FontWeight.w700),
          ),
          Text('${ar(session.score)} صح', style: const TextStyle(fontSize: 12)),
        ],
      ),
      const SizedBox(height: 16),
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: (session.index + 1) / session.items.length,
          minHeight: 7,
          color: purple,
        ),
      ),
      const SizedBox(height: 34),
      Text(
        q.text,
        style: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w800,
          height: 1.8,
        ),
      ),
      const SizedBox(height: 26),
      ...List.generate(q.options.length, (i) {
        final selected =
            session.answered && session.answers[session.index] == i;
        final correct = session.answered && i == q.correct;
        final color = correct
            ? const Color(0xff238477)
            : selected
            ? const Color(0xffbd5263)
            : purple;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: OutlinedButton(
            key: ValueKey('option-$i'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(18),
              foregroundColor: session.answered ? color : null,
              backgroundColor: correct || selected
                  ? color.withValues(alpha: .10)
                  : null,
              side: BorderSide(
                color: correct || selected
                    ? color
                    : Theme.of(context).colorScheme.outlineVariant,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(19),
              ),
            ),
            onPressed: session.answered
                ? null
                : () => setState(() => session.answer(i)),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: .12),
                  ),
                  child: Text(ar(i + 1), style: TextStyle(color: color)),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    q.options[i],
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.8,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                if (correct)
                  const Icon(Icons.check_circle, color: Color(0xff238477)),
                if (selected && !correct)
                  const Icon(Icons.cancel_outlined, color: Color(0xffbd5263)),
              ],
            ),
          ),
        );
      }),
      if (session.answered) ...[
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.answers[session.index] == q.correct
                      ? 'إجابة موفقة ✨'
                      : 'معلومة جديدة تضاف لك',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: purple,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  q.explanation,
                  style: const TextStyle(height: 1.9, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        FilledButton(
          key: const ValueKey('next'),
          onPressed: saving ? null : _next,
          child: Text(
            saving
                ? 'جارٍ حفظ النتيجة…'
                : session.isLast
                ? 'شوف نتيجتك'
                : 'السؤال التالي',
          ),
        ),
      ],
    ];
  }

  List<Widget> _result() => [
    const SizedBox(height: 24),
    const Icon(Icons.emoji_events_rounded, size: 88, color: Color(0xffd6a64b)),
    const SizedBox(height: 20),
    Center(
      child: Text(
        session.score >= 3 ? 'فضولك بيكبر كل يوم!' : 'كل تجربة بتعلمك حاجة',
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
      ),
    ),
    const SizedBox(height: 18),
    Center(
      child: Text(
        '${ar(session.score)} / ${ar(session.items.length)}',
        style: const TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.w800,
          color: purple,
        ),
      ),
    ),
    const SizedBox(height: 8),
    Center(
      child: Text(
        widget.store.error ?? 'تم حفظ النتيجة على جهازك',
        style: const TextStyle(fontSize: 12),
      ),
    ),
    const SizedBox(height: 30),
    const Text(
      'راجع اللي اتعلمته',
      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
    ),
    const SizedBox(height: 16),
    ...List.generate(
      session.items.length,
      (i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.items[i].text,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'إجابتك: ${session.items[i].options[session.answers[i]]}',
                  style: TextStyle(
                    color: session.answers[i] == session.items[i].correct
                        ? const Color(0xff238477)
                        : const Color(0xffbd5263),
                    fontSize: 12,
                  ),
                ),
                Text(
                  session.items[i].explanation,
                  style: const TextStyle(fontSize: 12, height: 1.9),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    const SizedBox(height: 16),
    FilledButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('العودة للرئيسية'),
    ),
  ];
}
