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
