import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/logging/log_buffer.dart';
import '../../../core/logging/log_providers.dart';
import '../../../core/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../chat/data/chat_providers.dart';
import '../../profiles/data/profile_providers.dart';

/// FutureProvider dla informacji o aplikacji (wersja, package, build number).
final _packageInfoProvider = FutureProvider<PackageInfo>(
  (ref) => PackageInfo.fromPlatform(),
);

final _diagnosticsStatsProvider = FutureProvider<_DiagnosticsStats>((ref) async {
  final profileRepo = ref.watch(profileRepositoryProvider);
  final profiles = await profileRepo.getAllProfiles();
  final activeId = await profileRepo.watchActiveProfileId().first;
  final activeProfile = (activeId == null || profiles.isEmpty)
      ? null
      : profiles.where((p) => p.id == activeId).firstOrNull;
  final chats = await ref.watch(chatsListProvider.future);
  return _DiagnosticsStats(
    profileCount: profiles.length,
    activeProfileName: activeProfile?.name,
    chatCount: chats.length,
  );
});

class _DiagnosticsStats {
  final int profileCount;
  final String? activeProfileName;
  final int chatCount;
  const _DiagnosticsStats({
    required this.profileCount,
    required this.activeProfileName,
    required this.chatCount,
  });
}

class DiagnosticsScreen extends ConsumerWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final logBuffer = ref.watch(logBufferProvider);
    final packageInfoAsync = ref.watch(_packageInfoProvider);
    final statsAsync = ref.watch(_diagnosticsStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.diagnosticsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: loc.diagnosticsClearAll,
            onPressed: () => _confirmClearAll(context, ref, loc),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.md),
        children: [
          _buildAppInfoCard(context, packageInfoAsync, loc),
          const SizedBox(height: Spacing.md),
          _buildStatsCard(context, statsAsync, loc),
          const SizedBox(height: Spacing.md),
          _buildCrashesCard(
            context,
            ref,
            logBuffer,
            packageInfoAsync,
            statsAsync,
            loc,
          ),
          const SizedBox(height: Spacing.md),
          _buildLogsCard(context, logBuffer, loc),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            _shareExport(context, ref, packageInfoAsync, statsAsync, loc),
        icon: const Icon(Icons.share),
        label: Text(loc.diagnosticsShareLogs),
      ),
    );
  }

  Widget _buildAppInfoCard(
    BuildContext context,
    AsyncValue<PackageInfo> packageInfoAsync,
    AppLocalizations loc,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.diagnosticsAboutSection,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: Spacing.sm),
            packageInfoAsync.when(
              data: (info) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row(
                    context,
                    loc.diagnosticsAppLabel,
                    '${info.appName} ${info.version}+${info.buildNumber}',
                  ),
                  _row(
                    context,
                    loc.diagnosticsBuildModeLabel,
                    kDebugMode
                        ? 'debug'
                        : (kProfileMode ? 'profile' : 'release'),
                  ),
                  _row(
                    context,
                    loc.diagnosticsPackageNameLabel,
                    info.packageName,
                  ),
                ],
              ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: Spacing.sm),
                child: LinearProgressIndicator(),
              ),
              error: (e, _) => Text(
                loc.diagnosticsError('$e'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(
    BuildContext context,
    AsyncValue<_DiagnosticsStats> statsAsync,
    AppLocalizations loc,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.diagnosticsStateSection,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: Spacing.sm),
            statsAsync.when(
              data: (stats) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row(
                    context,
                    loc.diagnosticsProfileCount,
                    '${stats.profileCount}',
                  ),
                  _row(
                    context,
                    loc.diagnosticsActiveProfile,
                    stats.activeProfileName ?? loc.diagnosticsNone,
                  ),
                  _row(
                    context,
                    loc.diagnosticsChatCount,
                    '${stats.chatCount}',
                  ),
                ],
              ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: Spacing.sm),
                child: LinearProgressIndicator(),
              ),
              error: (e, _) => Text(
                loc.diagnosticsError('$e'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sekcja Awarie — pokazuje liczbę i listę crashy. Plus button do
  /// świadomego wysłania crash report przez share intent. W debug mode plus
  /// button do empirycznego sprawdzenia że error handlers działają.
  Widget _buildCrashesCard(
    BuildContext context,
    WidgetRef ref,
    LogBuffer buffer,
    AsyncValue<PackageInfo> packageInfoAsync,
    AsyncValue<_DiagnosticsStats> statsAsync,
    AppLocalizations loc,
  ) {
    final crashes = buffer.crashes.reversed.toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.diagnosticsCrashesSection(buffer.crashCount),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: Spacing.sm),
            if (crashes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
                child: Text(
                  loc.diagnosticsNoCrashes,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else ...[
              // Preview ostatnich 5 crashy — user widzi że są, klika button
              // żeby zobaczyć pełny report w shared intent.
              SizedBox(
                height: crashes.length > 3 ? 240 : null,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: crashes.length > 3
                      ? const ClampingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  itemCount: crashes.length > 5 ? 5 : crashes.length,
                  itemBuilder: (_, i) => _CrashEntryTile(entry: crashes[i]),
                ),
              ),
              const SizedBox(height: Spacing.sm),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  icon: const Icon(Icons.bug_report_outlined),
                  label: Text(loc.diagnosticsSendCrashReport),
                  onPressed: () => _shareCrashReport(
                    context,
                    ref,
                    packageInfoAsync,
                    statsAsync,
                    loc,
                  ),
                ),
              ),
            ],
            // W debug mode pokazujemy button do empirycznego sprawdzenia że
            // global error handlers działają. NIE pokazywany w release —
            // żeby nie zaśmiecać UX produkcyjnego "test buttonem".
            if (kDebugMode) ...[
              const SizedBox(height: Spacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.warning_amber_outlined, size: 18),
                  label: Text(loc.diagnosticsTestCrash),
                  onPressed: () => _triggerTestCrash(context, loc),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLogsCard(
    BuildContext context,
    LogBuffer buffer,
    AppLocalizations loc,
  ) {
    final entries = buffer.entries.reversed.toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.diagnosticsLogsSection(buffer.length),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: Spacing.sm),
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                child: Text(
                  loc.diagnosticsLogsEmpty,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              SizedBox(
                height: 360,
                child: ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (_, i) => _LogEntryTile(entry: entries[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearAll(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations loc,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.diagnosticsClearAllConfirmTitle),
        content: Text(loc.diagnosticsClearAllConfirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(loc.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(loc.commonDelete),
          ),
        ],
      ),
    );
    if (ok == true) {
      ref.read(logBufferProvider).clearAll();
    }
  }

  Future<void> _shareExport(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<PackageInfo> packageInfoAsync,
    AsyncValue<_DiagnosticsStats> statsAsync,
    AppLocalizations loc,
  ) async {
    final info = packageInfoAsync.value;
    final stats = statsAsync.value;
    final buildMode = kDebugMode
        ? 'debug'
        : (kProfileMode ? 'profile' : 'release');

    final exportText = ref.read(logBufferProvider).buildExportText(
      appName: info?.appName ?? 'Atrament',
      appVersion: info != null
          ? '${info.version}+${info.buildNumber}'
          : 'unknown',
      buildMode: buildMode,
      stats: {
        loc.diagnosticsProfileCount:
            stats != null ? '${stats.profileCount}' : '?',
        loc.diagnosticsActiveProfile:
            stats?.activeProfileName ?? loc.diagnosticsNone,
        loc.diagnosticsChatCount:
            stats != null ? '${stats.chatCount}' : '?',
      },
    );

    try {
      await SharePlus.instance.share(
        ShareParams(text: exportText, subject: 'Atrament diagnostics'),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.diagnosticsShareError('$e'))),
        );
      }
    }
  }

  Future<void> _shareCrashReport(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<PackageInfo> packageInfoAsync,
    AsyncValue<_DiagnosticsStats> statsAsync,
    AppLocalizations loc,
  ) async {
    final info = packageInfoAsync.value;
    final stats = statsAsync.value;
    final buildMode = kDebugMode
        ? 'debug'
        : (kProfileMode ? 'profile' : 'release');

    final reportText = ref.read(logBufferProvider).buildCrashReportText(
      appName: info?.appName ?? 'Atrament',
      appVersion: info != null
          ? '${info.version}+${info.buildNumber}'
          : 'unknown',
      buildMode: buildMode,
      stats: {
        loc.diagnosticsProfileCount:
            stats != null ? '${stats.profileCount}' : '?',
        loc.diagnosticsActiveProfile:
            stats?.activeProfileName ?? loc.diagnosticsNone,
        loc.diagnosticsChatCount:
            stats != null ? '${stats.chatCount}' : '?',
      },
    );

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: reportText,
          subject: loc.diagnosticsCrashReportSubject,
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.diagnosticsShareError('$e'))),
        );
      }
    }
  }

  /// Wywołuje testowy crash żeby user empirycznie zweryfikował że error
  /// handlers działają. Wyrzuca exception z `Future.microtask` żeby trafić
  /// w PlatformDispatcher.instance.onError (async path), a nie tylko w
  /// FlutterError.onError (sync path) — pokrywa szerszy zakres handlerów.
  void _triggerTestCrash(BuildContext context, AppLocalizations loc) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc.diagnosticsTestCrashTriggered),
        duration: const Duration(seconds: 2),
      ),
    );
    // Wyzwol async exception — global handler złapie i zapisze jako crash.
    Future.microtask(() {
      throw StateError(
        'Test crash from diagnostics screen — empirical pipeline verification',
      );
    });
  }
}

class _CrashEntryTile extends StatelessWidget {
  final LogEntry entry;
  const _CrashEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: cs.error.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, size: 14, color: cs.error),
              const SizedBox(width: 6),
              Text(
                entry.formattedShort,
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w500,
                  color: cs.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            entry.message,
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: cs.onSurface,
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _LogEntryTile extends StatelessWidget {
  final LogEntry entry;
  const _LogEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final appColors = Theme.of(context).extension<AppColors>()!;
    final levelColor = _levelColor(entry.level, cs, appColors);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.formattedShort,
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: levelColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              entry.level.name.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
                color: levelColor,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: cs.onSurface,
                ),
                children: [
                  TextSpan(
                    text: '[${entry.tag}] ',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                  TextSpan(text: entry.message),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _levelColor(LogLevel l, ColorScheme cs, AppColors appColors) {
    switch (l) {
      case LogLevel.debug:
        return cs.onSurfaceVariant;
      case LogLevel.info:
        return cs.primary;
      case LogLevel.warn:
        return appColors.warning;
      case LogLevel.error:
        return cs.error;
    }
  }
}

extension _FirstWhereOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
