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
}
