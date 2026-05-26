import 'package:flutter/material.dart';
import 'core/network/address_validator.dart';
import 'data/secure/secure_key_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const testUrls = [
    'http://192.168.1.100:1234',
    'http://10.0.2.2:1234',
    'http://localhost:1234',
    'https://api.openai.com',
    'http://8.8.8.8:8080',
    'http://172.20.0.5:1234',
  ];

  // Secure storage round-trip
  final store = SecureKeyStore();
  String secureResult;
  try {
    await store.setApiKey('test-id', 'sk-tajny-klucz-123');
    final read = await store.getApiKey('test-id');
    final ok = read == 'sk-tajny-klucz-123';
    await store.deleteApiKey('test-id');
    final afterDelete = await store.getApiKey('test-id');
    secureResult = (ok && afterDelete == null)
        ? '✅ zapis → odczyt → usunięcie OK'
        : '❌ niezgodność (read="$read", po usunięciu="$afterDelete")';
  } catch (e) {
    secureResult = '❌ błąd secure storage: $e';
  }

  runApp(TestApp(urls: testUrls, secureResult: secureResult));
}

class TestApp extends StatelessWidget {
  final List<String> urls;
  final String secureResult;
  const TestApp({super.key, required this.urls, required this.secureResult});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atrament',
      home: Scaffold(
        appBar: AppBar(title: const Text('Test: walidacja + secure storage')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Secure storage: $secureResult',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 32),
            const Text(
              'Walidacja adresów:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...urls.map((u) {
              final priv = isPrivateAddress(u);
              final warn = shouldWarnCleartext(u);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      u,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '  ${priv ? "prywatny" : "publiczny"} • '
                      '${isCleartext(u) ? "HTTP" : "HTTPS"} • '
                      '${warn ? "⚠️ OSTRZEŻ" : "ok bez ostrzeżenia"}',
                      style: TextStyle(
                        color: warn ? Colors.orange.shade800 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
