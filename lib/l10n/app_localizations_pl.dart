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
  String get commonUnnamedChat => 'Bez nazwy';

  @override
  String get commonNewChat => 'Nowa rozmowa';

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
