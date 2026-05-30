import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/logging/log_buffer.dart';
import '../../../core/theme.dart';
import '../../../l10n/app_localizations.dart';
import 'chat_controller.dart';

/// Dialog do raportowania niewłaściwej odpowiedzi modelu.
///
/// **Privacy:** to JEDYNE miejsce w aplikacji gdzie treść wiadomości może
/// opuścić urządzenie. **Świadomy opt-in per-message:**
/// 1. User tappnie „Raportuj odpowiedź" w bańce
/// 2. Otworzy się ten dialog z disclaimerem co zostanie udostępnione
/// 3. User wybierze kategorię + opcjonalnie komentarz
/// 4. Tap „Udostępnij" → share intent z wyborem komu (Gmail/Schowek/itp)
/// 5. NIC nie wychodzi automatycznie — user explicit wybiera adresata
///
/// To NIE jest globalna telemetria. To jest mechanism user-driven feedback
/// gdzie user świadomie udostępnia kontekst diagnostyczny dla konkretnej
/// problematycznej odpowiedzi.
class ReportResponseDialog extends ConsumerStatefulWidget {
  /// Indeks raportowanej wiadomości w `ChatState.messages` —
  /// dialog z tego sam pobiera treść + poprzednią wiadomość user'a (pytanie).
  final int messageIndex;
  const ReportResponseDialog({required this.messageIndex, super.key});

  static Future<void> show(BuildContext context, int messageIndex) {
    return showDialog<void>(
      context: context,
      builder: (_) => ReportResponseDialog(messageIndex: messageIndex),
    );
  }

  @override
  ConsumerState<ReportResponseDialog> createState() =>
      _ReportResponseDialogState();
}

enum _Category { inaccurate, offTopic, unsafe, poorQuality, other }

class _ReportResponseDialogState extends ConsumerState<ReportResponseDialog> {
  _Category? _selected;
  final _commentCtrl = TextEditingController();
  bool _sharing = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  String _categoryLabel(_Category c, AppLocalizations loc) {
    switch (c) {
      case _Category.inaccurate:
        return loc.reportCategoryInaccurate;
      case _Category.offTopic:
        return loc.reportCategoryOffTopic;
      case _Category.unsafe:
        return loc.reportCategoryUnsafe;
      case _Category.poorQuality:
        return loc.reportCategoryPoorQuality;
      case _Category.other:
        return loc.reportCategoryOther;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(loc.reportResponseTitle),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.reportResponseIntro,
                style: TextStyle(
                  fontSize: 13,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Spacing.md),
              Text(
                loc.reportResponseCategoryLabel,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _Category.values
                    .map(
                      (c) => ChoiceChip(
                        label: Text(_categoryLabel(c, loc)),
                        selected: _selected == c,
                        onSelected: (v) =>
                            setState(() => _selected = v ? c : null),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: Spacing.md),
              Text(
                loc.reportResponseCommentLabel,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              TextField(
                controller: _commentCtrl,
                maxLines: 3,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: loc.reportResponseCommentHint,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              // Privacy disclaimer w wyraźnym info-boxie. User musi widzieć
              // CO ZOSTANIE UDOSTĘPNIONE zanim kliknie Udostępnij.
              Container(
                padding: const EdgeInsets.all(Spacing.sm),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: cs.outlineVariant,
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: cs.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          loc.reportResponseDisclaimerTitle,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      loc.reportResponseDisclaimerContent,
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _sharing ? null : () => Navigator.pop(context),
          child: Text(loc.commonCancel),
        ),
        FilledButton(
          // Submit disabled dopóki kategoria nie wybrana — przymusza
          // świadomy wybór, nie pusty raport.
          onPressed: (_selected == null || _sharing)
              ? null
              : () => _onSubmit(loc),
          child: _sharing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(loc.reportResponseShare),
        ),
      ],
    );
  }

  Future<void> _onSubmit(AppLocalizations loc) async {
    setState(() => _sharing = true);
    try {
      final chat = ref.read(chatControllerProvider);
      final target = await ref.read(chatTargetProvider.future);

      // Pobierz raportowaną wiadomość + poprzednie user message (pytanie).
      // messageIndex wskazuje assistant message; user message zazwyczaj jest
      // bezpośrednio przed nim (parent w drzewie konwersacji).
      String? userQuestion;
      String assistantResponse = '';
      if (widget.messageIndex >= 0 &&
          widget.messageIndex < chat.messages.length) {
        assistantResponse = chat.messages[widget.messageIndex].content;
        if (widget.messageIndex > 0) {
          final prev = chat.messages[widget.messageIndex - 1];
          if (prev.role == 'user') {
            userQuestion = prev.content;
          }
        }
      }

      // Pobierz PackageInfo (app version, build number).
      final info = await PackageInfo.fromPlatform();
      final buildMode = kDebugMode
          ? 'debug'
          : (kProfileMode ? 'profile' : 'release');

      // Zbuduj mapę parametrów inference (manifest sekcja 9.2 + ChatParameters).
      final p = chat.parameters;
      final parameters = <String, String>{
        'Temperature': p.temperature.toStringAsFixed(2),
        if (p.maxTokens != null) 'Max tokens': '${p.maxTokens}',
        if (p.topP != null) 'Top-P': '${p.topP}',
        if (p.topK != null) 'Top-K': '${p.topK}',
        if (p.minP != null) 'Min-P': '${p.minP}',
        'Repeat penalty': p.repeatPenalty.toStringAsFixed(2),
        'Frequency penalty': p.frequencyPenalty.toStringAsFixed(2),
        'Presence penalty': p.presencePenalty.toStringAsFixed(2),
        if (p.seed != null) 'Seed': '${p.seed}',
        if (p.reasoningEffort != null)
          'Reasoning effort': p.reasoningEffort!.name,
        if (p.stop.isNotEmpty) 'Stop': p.stop.join(', '),
      };

      final modelName = chat.modelId ?? target?.model ?? 'unknown';
      final categoryLabel = _categoryLabel(_selected!, loc);

      final reportText = LogBuffer().buildResponseReportText(
        appName: info.appName,
        appVersion: '${info.version}+${info.buildNumber}',
        buildMode: buildMode,
        model: modelName,
        parameters: parameters,
        systemPrompt: chat.systemPrompt,
        userQuestion: userQuestion,
        assistantResponse: assistantResponse,
        category: categoryLabel,
        userComment: _commentCtrl.text.trim().isEmpty
            ? null
            : _commentCtrl.text.trim(),
      );

      await SharePlus.instance.share(
        ShareParams(
          text: reportText,
          subject: loc.reportResponseSubject,
        ),
      );

      // Po share intent loguj że user świadomie zaraportował — daje
      // diagnostyce widoczność że to się stało (bez treści).
      LogBuffer().info(
        'report',
        'User reported assistant response: '
            'messageIndex=${widget.messageIndex}, '
            'category=$categoryLabel, '
            'hasComment=${_commentCtrl.text.trim().isNotEmpty}',
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      LogBuffer().error('report', 'Failed to share response report: $e');
      if (mounted) {
        setState(() => _sharing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.reportResponseShareError('$e'))),
        );
      }
    }
  }
}
