import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../core/logging/log_buffer.dart';
import '../../../core/network/address_validator.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme.dart';
import '../../../l10n/app_localizations.dart';
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
    final loc = AppLocalizations.of(context);
    final url = _url.text.trim();
    if (url.isEmpty) {
      setState(() => _error = loc.addProfileMissingUrl);
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
    final loc = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.addProfileCleartextTitle),
        content: Text(loc.addProfileCleartextContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(loc.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(loc.addProfileContinue),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final loc = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      final repo = ref.read(profileRepositoryProvider);
      final key = _apiKey.text.trim();
      final name = _name.text.trim().isEmpty
          ? _url.text.trim()
          : _name.text.trim();
      if (_isEditing) {
        // Update path — bez zmian w active state. URL/nazwa update nie
        // powinno zmieniać który profil jest aktywny.
        await repo.updateProfile(
          id: widget.editing!.id,
          name: name,
          baseUrl: _url.text.trim(),
          newApiKey: key.isEmpty ? null : key,
          clearApiKey: _clearKey,
        );
      } else {
        // Create path — discovered podczas testów Sesji H że bez
        // auto-activate user ląduje w ChatsList z "Brak aktywnego serwera"
        // tuż po świeżym dodaniu serwera. User: "ktoś kto nie rozumie tej
        // apki pomyśli że to bug". Auto-activate dla każdego nowego
        // profilu — power user ma jeden tap gwiazdki w ProfilesScreen
        // żeby przełączyć z powrotem do starego, jeśli zamierzał backup.
        final newId = await repo.saveProfile(
          name: name,
          baseUrl: _url.text.trim(),
          type: 'openai_compat',
          apiKey: key.isEmpty ? null : key,
        );
        await repo.setActiveProfileId(newId);
        LogBuffer().info(
          'profile',
          'Auto-activated new profile: id=$newId',
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = loc.addProfileSaveError(e.toString());
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final appColors = Theme.of(context).extension<AppColors>()!;
    final canSave = _isEditing || _models != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? loc.addProfileTitleEdit : loc.addProfileTitleNew,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            decoration: InputDecoration(
              labelText: loc.addProfileNameLabel,
              hintText: loc.addProfileNameHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _url,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: loc.addProfileUrlLabel,
              // Hardcoded — przykład IP/portu, nieprzetłumaczalny.
              hintText: 'http://192.168.1.100:1234',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          if (_isEditing && _needsReentry) ...[
            // Theme-aware warning card: AppColors.warningContainer/warning/
            // onWarningContainer zamiast Colors.orange.shadeXXX, żeby
            // dostosowywało się do dark/light motywu (sub-commit dnia 6
            // ustanowił ten wzorzec dla bannera "Odpowiedź przerwana").
            Card(
              color: appColors.warningContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: appColors.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        loc.addProfileApiKeyLost,
                        style: TextStyle(
                          color: appColors.onWarningContainer,
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
              labelText: loc.addProfileApiKeyLabel,
              hintText: _isEditing && _hadKey
                  ? loc.addProfileApiKeyHintExisting
                  : loc.addProfileApiKeyHintNew,
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
              title: Text(loc.addProfileClearKey),
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
            label: Text(
              _connecting ? loc.addProfileConnecting : loc.addProfileTestConnection,
            ),
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
              loc.addProfileConnected(_models!.length),
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
                    ? loc.addProfileSaving
                    : (_isEditing ? loc.addProfileSaveChanges : loc.addProfileSaveNew),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
