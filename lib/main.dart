import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  List<String> models = [];
  String? error;

  try {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );
    final resp = await dio.get('http://10.0.2.2:1234/v1/models');
    final data = resp.data['data'] as List;
    models = data.map((m) => m['id'].toString()).toList();
    debugPrint('=== MODELE Z LM STUDIO: $models ===');
  } catch (e) {
    error = e.toString();
    debugPrint('=== BŁĄD POŁĄCZENIA: $e ===');
  }

  runApp(MyApp(models: models, error: error));
}

class MyApp extends StatelessWidget {
  final List<String> models;
  final String? error;
  const MyApp({super.key, required this.models, this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atrament',
      home: Scaffold(
        appBar: AppBar(title: const Text('Atrament — test LM Studio')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: error != null
              ? Text(
                  '❌ Błąd:\n$error',
                  style: const TextStyle(color: Colors.red),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✅ Połączono — ${models.length} modeli:',
                      style: const TextStyle(fontSize: 20, color: Colors.green),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView(
                        children: models.map((m) => Text('• $m')).toList(),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
