import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:re_highlight/re_highlight.dart';
import 'package:re_highlight/languages/all.dart';
import 'package:re_highlight/styles/atom-one-dark.dart';
import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';

/// Widget bloku kodu używany jako codeBuilder w gpt_markdown.
///
/// Tło: surfaceContainerLowest (najciemniejszy tier M3) — wyraźny kontrast
/// z bańką assistant (surfaceContainerHighest). Plus 1px border outlineVariant
/// dla dodatkowego wyodrębnienia od otoczenia.
class CodeBlock extends StatelessWidget {
  final String language;
  final String code;
  final bool closed;

  const CodeBlock({
    super.key,
    required this.language,
    required this.code,
    required this.closed,
  });

  static final Highlight _highlight = Highlight()
    ..registerLanguages(builtinAllLanguages);

  TextSpan _buildSpan(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final defaultStyle = TextStyle(
      fontFamily: 'monospace',
      fontSize: 13,
      height: 1.4,
      color: cs.onSurface,
    );

    if (language.isEmpty) {
      return TextSpan(text: code, style: defaultStyle);
    }

    try {
      final result = _highlight.highlightAuto(code, [language]);
      final renderer = TextSpanRenderer(defaultStyle, atomOneDarkTheme);
      result.render(renderer);
      return renderer.span ?? TextSpan(text: code, style: defaultStyle);
    } catch (_) {
      return TextSpan(text: code, style: defaultStyle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: Spacing.sm),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (language.isNotEmpty || closed)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.xs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      language,
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.outline,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  if (closed)
                    TextButton.icon(
                      icon: const Icon(Icons.copy, size: 14),
                      label: Text(loc.commonCopy),
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.sm,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: code));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(loc.commonCopied),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.md,
              0,
              Spacing.md,
              Spacing.sm,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText.rich(_buildSpan(context)),
            ),
          ),
        ],
      ),
    );
  }
}
