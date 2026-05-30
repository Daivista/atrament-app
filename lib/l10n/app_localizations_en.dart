// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonCopy => 'Copy';

  @override
  String get commonCopied => 'Copied';

  @override
  String get commonUnnamedChat => 'Untitled';

  @override
  String get commonNewChat => 'New conversation';

  @override
  String get commonMoreMenu => 'More';

  @override
  String get themeModeSystem => 'Theme: system';

  @override
  String get themeModeLight => 'Theme: light';

  @override
  String get themeModeDark => 'Theme: dark';

  @override
  String get chatTitleEditDialog => 'Rename conversation';

  @override
  String get chatResponseInterrupted => 'Response interrupted';

  @override
  String get chatContinueButton => 'Continue';

  @override
  String get chatNoActiveServerTitle => 'No active server';

  @override
  String get chatCannotConnectTitle => 'Connection failed';

  @override
  String get chatNoActiveServerHint =>
      'Set an active server (star) in server management.';

  @override
  String get chatEmptyHint => 'Write a message to start the conversation.';

  @override
  String get chatComposerHint => 'Write a message…';

  @override
  String get chatStopTooltip => 'Stop';

  @override
  String get chatSendTooltip => 'Send';

  @override
  String get chatReasoningLabel => 'Thinking';

  @override
  String get chatParametersTooltip => 'Conversation parameters';

  @override
  String get chatParametersTitle => 'Conversation parameters';

  @override
  String get chatParametersModel => 'Model';

  @override
  String get chatParametersModeSimple => 'Simple';

  @override
  String get chatParametersModeMedium => 'Medium';

  @override
  String get chatParametersModeAdvanced => 'Advanced';

  @override
  String get chatParametersCreativity => 'Creativity';

  @override
  String get chatParametersCreativityPrecise => 'precise (0.2)';

  @override
  String get chatParametersCreativityCreative => 'creative (1.2)';

  @override
  String get chatParametersSystemPrompt => 'System prompt (optional)';

  @override
  String get chatParametersSystemPromptHint => 'You are a helpful assistant...';

  @override
  String get chatParametersMaxTokens => 'Max tokens';

  @override
  String get chatParametersTopP => 'Top-P';

  @override
  String get chatParametersTopK => 'Top-K';

  @override
  String get chatParametersMinP => 'Min-P';

  @override
  String get chatParametersSeed => 'Seed';

  @override
  String get chatParametersRepeatPenalty => 'Repeat penalty';

  @override
  String get chatParametersFrequencyPenalty => 'Frequency penalty';

  @override
  String get chatParametersPresencePenalty => 'Presence penalty';

  @override
  String get chatParametersStop => 'Stop sequences';

  @override
  String get chatParametersStopHint => 'e.g. END, STOP, ###';

  @override
  String get chatParametersReasoningEffort => 'Reasoning effort';

  @override
  String get chatParametersReasoningNone => '—';

  @override
  String get chatParametersReasoningLow => 'low';

  @override
  String get chatParametersReasoningMedium => 'medium';

  @override
  String get chatParametersReasoningHigh => 'high';

  @override
  String get chatParametersDefaultHint => 'server default';

  @override
  String get chatsListServersTooltip => 'Servers';

  @override
  String chatsListError(Object error) {
    return 'Error: $error';
  }

  @override
  String get chatsListRename => 'Rename';

  @override
  String get chatsListEmpty => 'No conversations';

  @override
  String get chatsListEmptyHint =>
      'Tap \"New conversation\" to start your first.';

  @override
  String get chatsListDeleteConfirmTitle => 'Delete conversation?';

  @override
  String chatsListDeleteConfirmContent(String title) {
    return 'Conversation \"$title\" will be deleted along with all messages.';
  }

  @override
  String get chatsListToday => 'Today';

  @override
  String get profilesScreenTitle => 'Servers';

  @override
  String profilesScreenError(Object error) {
    return 'Error: $error';
  }

  @override
  String get profilesScreenKeyLost =>
      'API key lost — choose Edit to enter again';

  @override
  String get profilesScreenActionActivate => 'Set as active';

  @override
  String get profilesScreenActionDeactivate => 'Remove active mark';

  @override
  String get profilesScreenActionEdit => 'Edit';

  @override
  String get profilesScreenAddProfile => 'Add server';

  @override
  String get profilesScreenDeleteConfirmTitle => 'Delete server?';

  @override
  String profilesScreenDeleteConfirmContent(String name) {
    return 'Profile \"$name\" will be deleted along with its API key. This action cannot be undone.';
  }

  @override
  String get profilesScreenEmpty => 'No servers';

  @override
  String get profilesScreenEmptyHint =>
      'Add your first LLM server (LM Studio, Ollama…) to start chatting.';

  @override
  String get addProfileTitleNew => 'New server';

  @override
  String get addProfileTitleEdit => 'Edit server';

  @override
  String get addProfileNameLabel => 'Name (optional)';

  @override
  String get addProfileNameHint => 'e.g. LM Studio - laptop';

  @override
  String get addProfileUrlLabel => 'Server address';

  @override
  String get addProfileMissingUrl => 'Enter the server address.';

  @override
  String get addProfileCleartextTitle => 'Unencrypted connection';

  @override
  String get addProfileCleartextContent =>
      'You\'re connecting via HTTP to a public address. Data (API key, conversations) may be intercepted. For local networks this is usually safe, for public ones we recommend HTTPS.\n\nContinue?';

  @override
  String get addProfileContinue => 'Continue';

  @override
  String get addProfileApiKeyLost =>
      'The API key for this server was lost (e.g. after restoring from backup). Enter it again below to restore the connection.';

  @override
  String get addProfileApiKeyLabel => 'API key (optional)';

  @override
  String get addProfileApiKeyHintExisting => 'saved — leave empty to keep';

  @override
  String get addProfileApiKeyHintNew => 'for servers requiring authorization';

  @override
  String get addProfileClearKey => 'Remove saved API key';

  @override
  String get addProfileConnecting => 'Connecting…';

  @override
  String get addProfileTestConnection => 'Test connection';

  @override
  String addProfileConnected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count models available',
      one: '1 model available',
      zero: 'no models available',
    );
    return '✅ Connected — $_temp0:';
  }

  @override
  String get addProfileSaving => 'Saving…';

  @override
  String get addProfileSaveChanges => 'Save changes';

  @override
  String get addProfileSaveNew => 'Save server';

  @override
  String addProfileSaveError(String error) {
    return 'Save error: $error';
  }

  @override
  String get diagnosticsTitle => 'Diagnostics';

  @override
  String get diagnosticsAboutSection => 'About app';

  @override
  String get diagnosticsAppLabel => 'App';

  @override
  String get diagnosticsBuildModeLabel => 'Build mode';

  @override
  String get diagnosticsPackageNameLabel => 'Package';

  @override
  String get diagnosticsStateSection => 'State';

  @override
  String get diagnosticsProfileCount => 'Profiles';

  @override
  String get diagnosticsActiveProfile => 'Active profile';

  @override
  String get diagnosticsChatCount => 'Conversations';

  @override
  String get diagnosticsNone => '— none —';

  @override
  String diagnosticsLogsSection(int count) {
    return 'Logs ($count)';
  }

  @override
  String get diagnosticsLogsEmpty => 'No logs in this session.';

  @override
  String get diagnosticsShareLogs => 'Share logs';

  @override
  String get diagnosticsClearAll => 'Clear all';

  @override
  String get diagnosticsClearAllConfirmTitle => 'Clear everything?';

  @override
  String get diagnosticsClearAllConfirmContent =>
      'All logs and crash reports from this session will be deleted. This action cannot be undone.';

  @override
  String diagnosticsError(String error) {
    return 'Error: $error';
  }

  @override
  String diagnosticsShareError(String error) {
    return 'Failed to share: $error';
  }

  @override
  String diagnosticsCrashesSection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count',
      one: '$count',
      zero: '0',
    );
    return 'Crashes ($_temp0)';
  }

  @override
  String get diagnosticsNoCrashes => 'No crashes in this session. 🎉';

  @override
  String get diagnosticsSendCrashReport => 'Send crash report';

  @override
  String get diagnosticsCrashReportSubject => 'Atrament — crash report';

  @override
  String get diagnosticsTestCrash => 'Trigger test crash';

  @override
  String get diagnosticsTestCrashTriggered =>
      'Test crash triggered — see Crashes section';
}
