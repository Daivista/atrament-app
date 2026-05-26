import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/address_validator.dart';
import '../../../core/providers/providers.dart';
import '../data/profile_providers.dart';

class AddProfileScreen extends ConsumerStatefulWidget {
  const AddProfileScreen({super.key});
  @override
  ConsumerState<AddProfileScreen> createState() => _AddProfileScreenState();
}

class _AddProfileScreenState extends ConsumerState<AddProfileScreen> {
  final _name = TextEditingController();
  final _url = TextEditingController();
  final _apiKey = TextEditingController();

  bool _connecting = false;
  bool _saving = false;
  List<String>? _models;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _url.dispose();
    _apiKey.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final url = _url.text.trim();
    if (url.isEmpty) {
      setState(() => _error = 'Podaj adres serwera.');
      return;
    }
    // Ostrzeżenie cleartext (manifest 11, v1.6.6) — nieblokujące
    if (shouldWarnCleartext(url)) {
      final proceed = await _showCleartextWarning();
      if (proceed != true) return;
    }
    setState(() {
      _connecting = true;
      _error = null;
      _models = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      final key = _apiKey.text.trim();
      final models = await api.fetchModels(
        url,
        apiKey: key.isEmpty ? null : key,
      );
      setState(() => _models = models);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  Future<bool?> _showCleartextWarning() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Połączenie nieszyfrowane'),
        content: const Text(
          'Łączysz się przez HTTP z publicznym adresem. Dane (w tym klucz API '
          'i rozmowy) mogą zostać przechwycone. Dla serwerów w sieci lokalnej '
          'to zwykle bezpieczne, ale dla publicznych zalecamy HTTPS.\n\n'
          'Kontynuować mimo to?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Kontynuuj'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final repo = ref.read(profileRepositoryProvider);
      final key = _apiKey.text.trim();
      final name = _name.text.trim().isEmpty
          ? _url.text.trim()
          : _name.text.trim();
      await repo.saveProfile(
        name: name,
        baseUrl: _url.text.trim(),
        type: 'openai_compat',
        apiKey: key.isEmpty ? null : key,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted)
        setState(() {
          _saving = false;
          _error = 'Błąd zapisu: $e';
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Dodaj serwer')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Nazwa (opcjonalna)',
              hintText: 'np. LM Studio - laptop',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _url,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Adres serwera',
              hintText: 'http://192.168.1.100:1234',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _apiKey,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Klucz API (opcjonalny)',
              hintText: 'dla serwerów wymagających autoryzacji',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _connecting ? null : _connect,
            icon: _connecting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.wifi_tethering),
            label: Text(_connecting ? 'Łączenie…' : 'Połącz'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Card(
              color: cs.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _error!,
                  style: TextStyle(color: cs.onErrorContainer),
                ),
              ),
            ),
          ],
          if (_models != null) ...[
            const SizedBox(height: 24),
            Text(
              '✅ Połączono — ${_models!.length} modeli dostępnych:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ..._models!.map(
              (m) => ListTile(
                dense: true,
                leading: const Icon(Icons.smart_toy_outlined, size: 20),
                title: Text(m),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save),
              label: Text(_saving ? 'Zapisywanie…' : 'Zapisz serwer'),
            ),
          ],
        ],
      ),
    );
  }
}
