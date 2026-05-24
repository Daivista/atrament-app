import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value, Variable;
import 'package:uuid/uuid.dart';
import 'data/database/database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  final now = DateTime.now().millisecondsSinceEpoch;

  // 1. Utwórz czat
  final chatId = const Uuid().v4();
  await db
      .into(db.chats)
      .insert(
        ChatsCompanion.insert(
          id: chatId,
          createdAt: now,
          updatedAt: now,
          title: const Value('Czat testowy'),
        ),
      );

  // 2. Dodaj wiadomość (trigger messages_fts_ai powinien wypełnić FTS)
  await db
      .into(db.messages)
      .insert(
        MessagesCompanion.insert(
          id: const Uuid().v4(),
          chatId: chatId,
          role: 'user',
          createdAt: now,
          content: const Value('Pierwsza wiadomosc testowa o programowaniu'),
        ),
      );

  // 3. Test FTS5 — szukaj słowa "testowa"
  final ftsResults = await db
      .customSelect(
        'SELECT message_id FROM messages_fts WHERE messages_fts MATCH ?',
        variables: [Variable.withString('testowa')],
      )
      .get();

  // 4. Policz tabele główne
  final chatCount = await db.select(db.chats).get();
  final msgCount = await db.select(db.messages).get();

  debugPrint(
    '=== Czaty: ${chatCount.length}, Wiadomosci: ${msgCount.length} ===',
  );
  debugPrint('=== FTS5 MATCH "testowa": ${ftsResults.length} trafien ===');

  runApp(
    MyApp(
      chats: chatCount.length,
      messages: msgCount.length,
      ftsHits: ftsResults.length,
    ),
  );
}

class MyApp extends StatelessWidget {
  final int chats;
  final int messages;
  final int ftsHits;
  const MyApp({
    super.key,
    required this.chats,
    required this.messages,
    required this.ftsHits,
  });

  @override
  Widget build(BuildContext context) {
    final ftsOk = ftsHits > 0;
    return MaterialApp(
      title: 'Atrament',
      home: Scaffold(
        appBar: AppBar(title: const Text('Atrament — test schematu v1')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Czaty: $chats', style: const TextStyle(fontSize: 22)),
              Text(
                'Wiadomości: $messages',
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(height: 16),
              Text(
                ftsOk
                    ? '✅ FTS5 działa ($ftsHits trafień)'
                    : '❌ FTS5 nie zwrócił wyników',
                style: TextStyle(
                  fontSize: 22,
                  color: ftsOk ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
