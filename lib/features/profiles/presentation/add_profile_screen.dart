import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../core/network/address_validator.dart';
import '../../../core/providers/providers.dart';
import '../data/profile_providers.dart';

class AddProfileScreen extends ConsumerStatefulWidget {
  final Profile? editing;
  const AddProfileScreen({super.key, this.editing});
  @override
  ConsumerState<AddProfileScreen> createState() => _AddProfileScreenState();
}

class _AddProfileScreenState extends ConsumerState<AddProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _url;
  final _apiKey = TextEditingController();

  bool _connecting = false;
  bool _saving = false;
  bool _clearKey = false;
  List<String>? _models;
  String? _error;

  bool get _isEditing => widget.editing != null;
  bool get _hadKey => widget.editing?.apiKeyRef != null;
  bool get _needsReentry => widget.editing?.apiKeyNeedsReentry ?? false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.editing?.name ?? '');
    _url = TextEditingController(text: widget.editing?.baseUrl ?? '');
  }

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
    if (shouldWarnCleartext(url)) {
      final ok = await _showCleartextWarning();
      if (ok != true) return;
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
          'Łączysz się przez HTTP z publicznym adresem. Dane (klucz API, '
          'rozmowy) mogą zostać przechwycone. Dla sieci lokalnej to zwykle '
          'bezpieczne, dla publicznych zalecamy HTTPS.\n\nKontynuować?',
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
      if (_isEditing) {
        await repo.updateProfile(
          id: widget.editing!.id,
          name: name,
          baseUrl: _url.text.trim(),
          newApiKey: key.isEmpty ? null : key,
          clearApiKey: _clearKey,
        );
      } else {
        await repo.saveProfile(
          name: name,
          baseUrl: _url.text.trim(),
          type: 'openai_compat',
          apiKey: key.isEmpty ? null : key,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Błąd zapisu: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final canSave = _isEditing || _models != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edytuj serwer' : 'Dodaj serwer'),
      ),
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
          if (_isEditing && _needsReentry) ...[
            Card(
              color: Colors.orange.shade100,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange.shade800),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Klucz API tego serwera został utracony (np. po przywróceniu '
                        'kopii zapasowej). Wpisz go ponownie poniżej, by przywrócić połączenie.',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _apiKey,
            obscureText: true,
            enabled: !_clearKey,
            decoration: InputDecoration(
              labelText: 'Klucz API (opcjonalny)',
              hintText: _isEditing && _hadKey
                  ? 'zapisany — zostaw puste by nie zmieniać'
                  : 'dla serwerów wymagających autoryzacji',
              border: const OutlineInputBorder(),
            ),
          ),
          if (_isEditing && _hadKey) ...[
            const SizedBox(height: 4),
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              value: _clearKey,
              onChanged: (v) => setState(() => _clearKey = v ?? false),
              title: const Text('Usuń zapisany klucz API'),
            ),
          ],
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
            label: Text(_connecting ? 'Łączenie…' : 'Testuj połączenie'),
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
          ],
          if (canSave) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save),
              label: Text(
                _saving
                    ? 'Zapisywanie…'
                    : (_isEditing ? 'Zapisz zmiany' : 'Zapisz serwer'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
