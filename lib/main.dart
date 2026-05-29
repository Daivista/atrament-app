import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:atrament_app/l10n/app_localizations.dart';
import 'package:atrament_app/core/theme.dart';

void main() => runApp(const AtramentApp());

class AtramentApp extends StatelessWidget {
  const AtramentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atrament',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark, // default dark; theme settings później
      // i18n: PL gdy system PL, else EN. Sekcja 7.9 manifestu.
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pl'), Locale('en')],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (deviceLocale?.languageCode == 'pl') return const Locale('pl');
        return const Locale('en');
      },
      home: const StreamTestScreen(),
    );
  }
}

// Sample z blokiem kodu w środku — testuje (a) i (c)
const _shortSample = r'''
# Odpowiedź modelu

Krótkie intro przed kodem, **pogrubienie** i `inline code`.

```dart
void main() {
  final items = [1, 2, 3];
  for (final i in items) {
    print('wartość: $i');
  }
}
```

Tekst po bloku kodu. Lista:
- raz
- dwa
''';

class StreamTestScreen extends StatefulWidget {
  const StreamTestScreen({super.key});
  @override
  State<StreamTestScreen> createState() => _StreamTestScreenState();
}

class _StreamTestScreenState extends State<StreamTestScreen> {
  String _buffer = '';
  Timer? _timer;
  bool _autoClose = true;
  bool _streaming = false;
  String _info = '';
  final _sw = Stopwatch();

  String _longSample() {
    final sb = StringBuffer(
      '# Długi blok kodu (perf)\n\nPrzed blokiem.\n\n```dart\n',
    );
    for (var i = 0; i < 600; i++) {
      sb.writeln("  print('linia numer \$i z bardzo długiego bloku kodu');");
    }
    sb.write('```\n\nTekst po długim bloku.');
    return sb.toString();
  }

  void _startStream(String full) {
    _timer?.cancel();
    setState(() {
      _buffer = '';
      _streaming = true;
      _info = '';
    });
    _sw
      ..reset()
      ..start();
    var pos = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 25), (t) {
      if (pos >= full.length) {
        t.cancel();
        _sw.stop();
        setState(() {
          _streaming = false;
          _info =
              'Strumień zakończony: ${_sw.elapsedMilliseconds} ms, ${full.length} znaków';
        });
        return;
      }
      final next = (pos + 3) > full.length ? full.length : pos + 3;
      setState(() => _buffer = full.substring(0, next));
      pos = next;
    });
  }

  void _showLongInstant() {
    _timer?.cancel();
    final long = _longSample();
    _sw
      ..reset()
      ..start();
    setState(() {
      _streaming = false;
      _buffer = long;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sw.stop();
      if (mounted) {
        setState(
          () => _info =
              'Render długiego bloku: ${_sw.elapsedMilliseconds} ms, ${long.length} znaków',
        );
      }
    });
  }

  String _render() {
    if (!_autoClose) return _buffer;
    final fences = '```'.allMatches(_buffer).length;
    return fences.isOdd ? '$_buffer\n```' : _buffer;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Atrament — test streamingu')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton(
                  onPressed: _streaming
                      ? null
                      : () => _startStream(_shortSample),
                  child: const Text('Stream: blok kodu'),
                ),
                FilledButton.tonal(
                  onPressed: _streaming ? null : _showLongInstant,
                  child: const Text('Długi blok (600 linii)'),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('auto-close ```'),
                    Switch(
                      value: _autoClose,
                      onChanged: (v) => setState(() => _autoClose = v),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_info.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                _info,
                style: const TextStyle(color: Colors.greenAccent),
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: GptMarkdown(_render()),
            ),
          ),
        ],
      ),
    );
  }
}
