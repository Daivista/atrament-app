import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../data/chat_models.dart';
import '../data/chat_parameters.dart';
import 'chat_controller.dart';

/// Bottom sheet do edycji parametrów rozmowy (model + parametry inference +
/// system prompt). Trzy tryby UI z manifestu sekcja 6:
///
/// - Prosty: tylko suwak Kreatywność (mapping temperature 0.2-1.2) + system prompt
/// - Średni: + max_tokens, seed
/// - Zaawansowany: wszystkie 13 parametrów (penalties jako suwaki, reszta jako pola)
///
/// Stan lokalny (`_params`, `_systemPrompt`, `_modelId`) jest edytowany na bieżąco;
/// persist do bazy tylko po kliknięciu Zapisz (via ChatController.updateXxx).
/// Cancel zamyka sheet bez zmian w bazie.
class ChatParametersSheet extends ConsumerStatefulWidget {
  const ChatParametersSheet({super.key});

  /// Helper otwierający sheet jako modal bottom sheet. Używany przez
  /// chat_screen z AppBar IconButton.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: const ChatParametersSheet(),
      ),
    );
  }

  @override
  ConsumerState<ChatParametersSheet> createState() =>
      _ChatParametersSheetState();
}

enum _Mode { simple, medium, advanced }

class _ChatParametersSheetState extends ConsumerState<ChatParametersSheet> {
  late ChatParameters _params;
  String? _modelId;
  _Mode _mode = _Mode.simple;

  late TextEditingController _systemPromptCtrl;
  late TextEditingController _maxTokensCtrl;
  late TextEditingController _seedCtrl;
  late TextEditingController _topPCtrl;
  late TextEditingController _topKCtrl;
  late TextEditingController _minPCtrl;
  late TextEditingController _stopCtrl;

  @override
  void initState() {
    super.initState();
    final s = ref.read(chatControllerProvider);
    _params = s.parameters;
    _modelId = s.modelId;
    _systemPromptCtrl = TextEditingController(text: s.systemPrompt ?? '');
    _maxTokensCtrl = TextEditingController(
      text: _params.maxTokens?.toString() ?? '',
    );
    _seedCtrl = TextEditingController(text: _params.seed?.toString() ?? '');
    _topPCtrl = TextEditingController(text: _params.topP?.toString() ?? '');
    _topKCtrl = TextEditingController(text: _params.topK?.toString() ?? '');
    _minPCtrl = TextEditingController(text: _params.minP?.toString() ?? '');
    _stopCtrl = TextEditingController(text: _params.stop.join(', '));
  }

  @override
  void dispose() {
    _systemPromptCtrl.dispose();
    _maxTokensCtrl.dispose();
    _seedCtrl.dispose();
    _topPCtrl.dispose();
    _topKCtrl.dispose();
    _minPCtrl.dispose();
    _stopCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final targetAsync = ref.watch(chatTargetProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.lg,
          Spacing.sm,
          Spacing.lg,
          Spacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: Spacing.md),
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.md),
              child: Text(
                loc.chatParametersTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    targetAsync.when(
                      data: (target) => _buildModelSection(target, loc, cs),
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: Spacing.md),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: Spacing.md,
                        ),
                        child: Text(
                          loc.chatsListError(e),
                          style: TextStyle(color: cs.error),
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                    _buildModeSelector(loc),
                    const SizedBox(height: Spacing.lg),
                    if (_mode == _Mode.simple) ..._buildSimple(loc, cs),
                    if (_mode == _Mode.medium) ..._buildMedium(loc, cs),
                    if (_mode == _Mode.advanced) ..._buildAdvanced(loc, cs),
                    const SizedBox(height: Spacing.lg),
                    _buildSystemPromptField(loc, cs),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Spacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(loc.commonCancel),
                ),
                const SizedBox(width: Spacing.sm),
                FilledButton(onPressed: _onSave, child: Text(loc.commonSave)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelSection(
    ChatTarget? target,
    AppLocalizations loc,
    ColorScheme cs,
  ) {
    if (target == null) {
      return Text(
        loc.chatNoActiveServerTitle,
        style: TextStyle(color: cs.error),
      );
    }
    // Wybierz aktualny model dla dropdown. Gdy _modelId istnieje ale nie ma go
    // już w availableModels (np. model został usunięty z LM Studio), fallback
    // do first żeby dropdown nie wybuchł na nieznanej wartości.
    final effective = _modelId ?? target.model;
    final displayed = target.availableModels.contains(effective)
        ? effective
        : target.availableModels.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: Spacing.xs),
          child: Text(
            loc.chatParametersModel,
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
        ),
        DropdownButtonFormField<String>(
          initialValue: displayed,
          isExpanded: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          items: target.availableModels
              .map(
                (m) => DropdownMenuItem(
                  value: m,
                  child: Text(
                    m,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _modelId = v),
        ),
      ],
    );
  }

  Widget _buildModeSelector(AppLocalizations loc) {
    return SegmentedButton<_Mode>(
      segments: [
        ButtonSegment(
          value: _Mode.simple,
          label: Text(loc.chatParametersModeSimple),
        ),
        ButtonSegment(
          value: _Mode.medium,
          label: Text(loc.chatParametersModeMedium),
        ),
        ButtonSegment(
          value: _Mode.advanced,
          label: Text(loc.chatParametersModeAdvanced),
        ),
      ],
      selected: {_mode},
      onSelectionChanged: (s) => setState(() => _mode = s.first),
      multiSelectionEnabled: false,
      showSelectedIcon: false,
    );
  }

  List<Widget> _buildSimple(AppLocalizations loc, ColorScheme cs) {
    return [_buildCreativitySlider(loc, cs)];
  }

  List<Widget> _buildMedium(AppLocalizations loc, ColorScheme cs) {
    return [
      _buildCreativitySlider(loc, cs),
      const SizedBox(height: Spacing.md),
      _buildNumericField(
        label: loc.chatParametersMaxTokens,
        hint: loc.chatParametersDefaultHint,
        controller: _maxTokensCtrl,
        isInt: true,
      ),
      const SizedBox(height: Spacing.md),
      _buildNumericField(
        label: loc.chatParametersSeed,
        hint: loc.chatParametersDefaultHint,
        controller: _seedCtrl,
        isInt: true,
      ),
    ];
  }

  List<Widget> _buildAdvanced(AppLocalizations loc, ColorScheme cs) {
    return [
      _buildCreativitySlider(loc, cs),
      const SizedBox(height: Spacing.md),
      _buildSliderField(
        label: loc.chatParametersRepeatPenalty,
        value: _params.repeatPenalty,
        min: 0.0,
        max: 2.0,
        onChanged: (v) =>
            setState(() => _params = _params.copyWith(repeatPenalty: v)),
      ),
      const SizedBox(height: Spacing.md),
      _buildSliderField(
        label: loc.chatParametersFrequencyPenalty,
        value: _params.frequencyPenalty,
        min: -2.0,
        max: 2.0,
        onChanged: (v) =>
            setState(() => _params = _params.copyWith(frequencyPenalty: v)),
      ),
      const SizedBox(height: Spacing.md),
      _buildSliderField(
        label: loc.chatParametersPresencePenalty,
        value: _params.presencePenalty,
        min: -2.0,
        max: 2.0,
        onChanged: (v) =>
            setState(() => _params = _params.copyWith(presencePenalty: v)),
      ),
      const SizedBox(height: Spacing.md),
      _buildNumericField(
        label: loc.chatParametersMaxTokens,
        hint: loc.chatParametersDefaultHint,
        controller: _maxTokensCtrl,
        isInt: true,
      ),
      const SizedBox(height: Spacing.md),
      _buildNumericField(
        label: loc.chatParametersTopP,
        hint: loc.chatParametersDefaultHint,
        controller: _topPCtrl,
        isInt: false,
      ),
      const SizedBox(height: Spacing.md),
      _buildNumericField(
        label: loc.chatParametersTopK,
        hint: loc.chatParametersDefaultHint,
        controller: _topKCtrl,
        isInt: true,
      ),
      const SizedBox(height: Spacing.md),
      _buildNumericField(
        label: loc.chatParametersMinP,
        hint: loc.chatParametersDefaultHint,
        controller: _minPCtrl,
        isInt: false,
      ),
      const SizedBox(height: Spacing.md),
      _buildNumericField(
        label: loc.chatParametersSeed,
        hint: loc.chatParametersDefaultHint,
        controller: _seedCtrl,
        isInt: true,
      ),
      const SizedBox(height: Spacing.md),
      TextField(
        controller: _stopCtrl,
        decoration: InputDecoration(
          labelText: loc.chatParametersStop,
          hintText: loc.chatParametersStopHint,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
      const SizedBox(height: Spacing.md),
      _buildReasoningEffort(loc, cs),
    ];
  }

  Widget _buildCreativitySlider(AppLocalizations loc, ColorScheme cs) {
    // Suwak Kreatywność: mapping liniowy temperature 0.2-1.2 (manifest sekcja 6).
    // Hardcoded ChatParameters().temperature = 0.8 z manifestu jest poza tym
    // zakresem (mid-range), więc clamp() łapie też wartości spoza 0.2-1.2 które
    // mogły zostać ustawione przez tryb Zaawansowany w innym session.
    final v = _params.temperature.clamp(0.2, 1.2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: Spacing.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.chatParametersCreativity,
                style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
              ),
              Text(
                v.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        Slider(
          value: v,
          min: 0.2,
          max: 1.2,
          divisions: 10,
          onChanged: (newV) =>
              setState(() => _params = _params.copyWith(temperature: newV)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              loc.chatParametersCreativityPrecise,
              style: TextStyle(fontSize: 11, color: cs.outline),
            ),
            Text(
              loc.chatParametersCreativityCreative,
              style: TextStyle(fontSize: 11, color: cs.outline),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSliderField({
    required String label,
    required double value,
    required double min,
    required double max,
    required void Function(double) onChanged,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
            ),
            Text(
              value.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: 40,
          onChanged: onChanged,
        ),
      ],
    );
  }

  /// Numeric TextField z hint "domyślne serwera" — pusta wartość znaczy
  /// `null` w ChatParameters (nie wysyłaj parametru, użyj defaultu serwera).
  Widget _buildNumericField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isInt,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isInt
          ? const TextInputType.numberWithOptions(decimal: false, signed: true)
          : const TextInputType.numberWithOptions(decimal: true, signed: true),
      inputFormatters: isInt
          ? [FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9]*$'))]
          : [FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9]*\.?[0-9]*$'))],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Widget _buildReasoningEffort(AppLocalizations loc, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: Spacing.xs),
          child: Text(
            loc.chatParametersReasoningEffort,
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          ),
        ),
        SegmentedButton<ReasoningEffort?>(
          segments: [
            ButtonSegment(
              value: null,
              label: Text(loc.chatParametersReasoningNone),
            ),
            ButtonSegment(
              value: ReasoningEffort.low,
              label: Text(loc.chatParametersReasoningLow),
            ),
            ButtonSegment(
              value: ReasoningEffort.medium,
              label: Text(loc.chatParametersReasoningMedium),
            ),
            ButtonSegment(
              value: ReasoningEffort.high,
              label: Text(loc.chatParametersReasoningHigh),
            ),
          ],
          selected: {_params.reasoningEffort},
          onSelectionChanged: (s) => setState(
            () => _params = _params.copyWith(reasoningEffort: s.first),
          ),
          multiSelectionEnabled: false,
          showSelectedIcon: false,
        ),
      ],
    );
  }

  Widget _buildSystemPromptField(AppLocalizations loc, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: Spacing.xs),
          child: Text(
            loc.chatParametersSystemPrompt,
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          ),
        ),
        TextField(
          controller: _systemPromptCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: loc.chatParametersSystemPromptHint,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
      ],
    );
  }

  Future<void> _onSave() async {
    // Parsuj wartości z TextEditingControllers (zarówno z trybu Średni jak
    // Zaawansowany — zachowujemy wszystkie kontrolery niezależnie od mode,
    // żeby user mógł przełączać tryby bez utraty wpisanych wartości).
    // Pusta wartość = null = nie wysyłaj tego parametru (default serwera).
    final maxTokens = int.tryParse(_maxTokensCtrl.text.trim());
    final seed = int.tryParse(_seedCtrl.text.trim());
    final topP = double.tryParse(_topPCtrl.text.trim());
    final topK = int.tryParse(_topKCtrl.text.trim());
    final minP = double.tryParse(_minPCtrl.text.trim());
    final stopText = _stopCtrl.text.trim();
    final stop = stopText.isEmpty
        ? <String>[]
        : stopText
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();

    final updated = _params.copyWith(
      maxTokens: maxTokens,
      seed: seed,
      topP: topP,
      topK: topK,
      minP: minP,
      stop: stop,
    );

    final ctrl = ref.read(chatControllerProvider.notifier);
    await ctrl.updateParameters(updated);
    await ctrl.updateSystemPrompt(_systemPromptCtrl.text);

    // Walidacja modelu przed zapisem: jeśli wybrany model nie jest w
    // availableModels (rzadki case), zapisz null = use profile default.
    final target = await ref.read(chatTargetProvider.future);
    final modelToSave =
        (_modelId != null &&
            target != null &&
            target.availableModels.contains(_modelId))
        ? _modelId
        : null;
    await ctrl.updateModel(modelToSave);

    if (!mounted) return;
    Navigator.pop(context);
  }
}
