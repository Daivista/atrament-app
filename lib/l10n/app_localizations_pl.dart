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
  String get commonUnnamedChat => 'Bez nazwy';

  @override
  String get chatTitleEditDialog => 'Zmień nazwę rozmowy';

  @override
  String get chatNewChatTitle => 'Nowa rozmowa';

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
}
