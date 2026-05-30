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
/// PackageInfo.fromPlatform() jest async (pobiera z platform channels Android/iOS).
final _packageInfoProvider = FutureProvider<PackageInfo>(
  (ref) => PackageInfo.fromPlatform(),
);

/// FutureProvider dla statystyk diagnostycznych — łączy dane z profile_repo
/// i message_repo. Auto-refresh gdy któryś z repo source zmieni stan.
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
            tooltip: loc.diagnosticsClearLogs,
            onPressed: () => _confirmClear(context, ref, loc),
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

  Widget _buildLogsCard(
    BuildContext context,
    LogBuffer buffer,
    AppLocalizations loc,
  ) {
    final entries = buffer.entries.reversed.toList(); // najnowsze na górze
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

  Future<void> _confirmClear(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations loc,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.diagnosticsClearLogsConfirmTitle),
        content: Text(loc.diagnosticsClearLogsConfirmContent),
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
      ref.read(logBufferProvider).clear();
    }
  }

  Future<void> _shareExport(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<PackageInfo> packageInfoAsync,
    AsyncValue<_DiagnosticsStats> statsAsync,
    AppLocalizations loc,
  ) async {
    // Cierpliwie czekamy aż obie AsyncValue załadują się; jeśli któraś
    // jest w loading/error, użyj fallback "unknown".
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
      // share_plus 10.x API. Jeśli wersja jest starsza i to nie kompiluje,
      // fallback do `Share.share(exportText, ...)` jest dostępny w starszych
      // wersjach paczki — wtedy `SharePlus.instance.share(ShareParams(...))`
      // trzeba zamienić.
      await SharePlus.instance.share(
        ShareParams(
          text: exportText,
          subject: 'Atrament diagnostics',
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
