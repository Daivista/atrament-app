// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get commonCancel => 'Anuluj';

  @override
  String get commonSave => 'Zapisz';

  @override
  String get commonDelete => 'Usuń';

  @override
  String get commonCopy => 'Kopiuj';

  @override
  String get commonCopied => 'Skopiowano';

  @override
  String get commonUnnamedChat => 'Bez nazwy';

  @override
  String get commonNewChat => 'Nowa rozmowa';

  @override
  String get themeModeSystem => 'Motyw: systemowy';

  @override
  String get themeModeLight => 'Motyw: jasny';

  @override
  String get themeModeDark => 'Motyw: ciemny';

  @override
  String get chatTitleEditDialog => 'Zmień nazwę rozmowy';

  @override
  String get chatResponseInterrupted => 'Odpowiedź przerwana';

  @override
  String get chatContinueButton => 'Kontynuuj';

  @override
  String get chatNoActiveServerTitle => 'Brak aktywnego serwera';

  @override
  String get chatCannotConnectTitle => 'Nie można połączyć';

  @override
  String get chatNoActiveServerHint =>
      'Ustaw aktywny serwer (gwiazdka) w zarządzaniu serwerami.';

  @override
  String get chatEmptyHint => 'Napisz wiadomość, by zacząć rozmowę.';

  @override
  String get chatComposerHint => 'Napisz wiadomość…';

  @override
  String get chatStopTooltip => 'Zatrzymaj';

  @override
  String get chatSendTooltip => 'Wyślij';

  @override
  String get chatReasoningLabel => 'Myślenie';

  @override
  String get chatParametersTooltip => 'Parametry rozmowy';

  @override
  String get chatParametersTitle => 'Parametry rozmowy';

  @override
  String get chatParametersModel => 'Model';

  @override
  String get chatParametersModeSimple => 'Prosty';

  @override
  String get chatParametersModeMedium => 'Średni';

  @override
  String get chatParametersModeAdvanced => 'Zaawansowany';

  @override
  String get chatParametersCreativity => 'Kreatywność';

  @override
  String get chatParametersCreativityPrecise => 'precyzyjny (0.2)';

  @override
  String get chatParametersCreativityCreative => 'kreatywny (1.2)';

  @override
  String get chatParametersSystemPrompt => 'System prompt (opcjonalnie)';

  @override
  String get chatParametersSystemPromptHint => 'Jesteś pomocnym asystentem...';

  @override
  String get chatParametersMaxTokens => 'Maks. tokenów';

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
  String get chatParametersStopHint => 'np. END, STOP, ###';

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
  String get chatParametersDefaultHint => 'domyślne serwera';

  @override
  String get chatsListServersTooltip => 'Serwery';

  @override
  String chatsListError(Object error) {
    return 'Błąd: $error';
  }

  @override
  String get chatsListRename => 'Zmień nazwę';

  @override
  String get chatsListEmpty => 'Brak rozmów';

  @override
  String get chatsListEmptyHint =>
      'Stuknij \"Nowa rozmowa\", by zacząć pierwszą.';

  @override
  String get chatsListDeleteConfirmTitle => 'Usunąć rozmowę?';

  @override
  String chatsListDeleteConfirmContent(String title) {
    return 'Rozmowa \"$title\" zostanie usunięta wraz ze wszystkimi wiadomościami.';
  }

  @override
  String get chatsListToday => 'Dziś';
}
