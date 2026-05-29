import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
  ];

  /// Przycisk anulowania w dialogach
  ///
  /// In pl, this message translates to:
  /// **'Anuluj'**
  String get commonCancel;

  /// Przycisk zapisu w dialogach i formularzach
  ///
  /// In pl, this message translates to:
  /// **'Zapisz'**
  String get commonSave;

  /// Przycisk/akcja usunięcia w dialogach i menu
  ///
  /// In pl, this message translates to:
  /// **'Usuń'**
  String get commonDelete;

  /// Przycisk kopiowania kodu w bloku ``` do schowka
  ///
  /// In pl, this message translates to:
  /// **'Kopiuj'**
  String get commonCopy;

  /// Snackbar potwierdzający skopiowanie
  ///
  /// In pl, this message translates to:
  /// **'Skopiowano'**
  String get commonCopied;

  /// Fallback tytułu rozmowy gdy brak tytułu
  ///
  /// In pl, this message translates to:
  /// **'Bez nazwy'**
  String get commonUnnamedChat;

  /// Etykieta FAB listy rozmów oraz placeholder tytułu w AppBar dla rozmowy bez id
  ///
  /// In pl, this message translates to:
  /// **'Nowa rozmowa'**
  String get commonNewChat;

  /// Tooltip przycisku motywu w AppBar — stan systemowy (default, idzie za ustawieniem Androida)
  ///
  /// In pl, this message translates to:
  /// **'Motyw: systemowy'**
  String get themeModeSystem;

  /// Tooltip przycisku motywu — wymuszony jasny
  ///
  /// In pl, this message translates to:
  /// **'Motyw: jasny'**
  String get themeModeLight;

  /// Tooltip przycisku motywu — wymuszony ciemny
  ///
  /// In pl, this message translates to:
  /// **'Motyw: ciemny'**
  String get themeModeDark;

  /// Tytuł dialogu edycji nazwy rozmowy (chat_screen i chats_list)
  ///
  /// In pl, this message translates to:
  /// **'Zmień nazwę rozmowy'**
  String get chatTitleEditDialog;

  /// Banner gdy ostatnia odpowiedź modelu jest częściowa (resume flow)
  ///
  /// In pl, this message translates to:
  /// **'Odpowiedź przerwana'**
  String get chatResponseInterrupted;

  /// Przycisk w bannerze odpowiedzi przerwanej — wznawia generowanie
  ///
  /// In pl, this message translates to:
  /// **'Kontynuuj'**
  String get chatContinueButton;

  /// Tytuł pustego ekranu gdy żaden profil nie jest aktywny
  ///
  /// In pl, this message translates to:
  /// **'Brak aktywnego serwera'**
  String get chatNoActiveServerTitle;

  /// Tytuł pustego ekranu gdy aktywny profil rzucił błąd połączenia
  ///
  /// In pl, this message translates to:
  /// **'Nie można połączyć'**
  String get chatCannotConnectTitle;

  /// Podpowiedź pod tytułem 'Brak aktywnego serwera'
  ///
  /// In pl, this message translates to:
  /// **'Ustaw aktywny serwer (gwiazdka) w zarządzaniu serwerami.'**
  String get chatNoActiveServerHint;

  /// Pusty ekran rozmowy zanim user wyśle pierwszą wiadomość
  ///
  /// In pl, this message translates to:
  /// **'Napisz wiadomość, by zacząć rozmowę.'**
  String get chatEmptyHint;

  /// Placeholder w polu wpisywania wiadomości
  ///
  /// In pl, this message translates to:
  /// **'Napisz wiadomość…'**
  String get chatComposerHint;

  /// Tooltip przycisku zatrzymania strumieniowania odpowiedzi
  ///
  /// In pl, this message translates to:
  /// **'Zatrzymaj'**
  String get chatStopTooltip;

  /// Tooltip przycisku wysłania wiadomości
  ///
  /// In pl, this message translates to:
  /// **'Wyślij'**
  String get chatSendTooltip;

  /// Etykieta sekcji reasoning w bańce (renderowana z emoji 🧠 w widgecie)
  ///
  /// In pl, this message translates to:
  /// **'Myślenie'**
  String get chatReasoningLabel;

  /// Tooltip przycisku zarządzania serwerami w AppBar listy rozmów
  ///
  /// In pl, this message translates to:
  /// **'Serwery'**
  String get chatsListServersTooltip;

  /// Komunikat błędu gdy stream rozmów rzuci wyjątek
  ///
  /// In pl, this message translates to:
  /// **'Błąd: {error}'**
  String chatsListError(Object error);

  /// Pozycja w popup menu rozmowy — otwiera dialog edycji nazwy
  ///
  /// In pl, this message translates to:
  /// **'Zmień nazwę'**
  String get chatsListRename;

  /// Tytuł pustego stanu listy rozmów
  ///
  /// In pl, this message translates to:
  /// **'Brak rozmów'**
  String get chatsListEmpty;

  /// Podpowiedź pod tytułem 'Brak rozmów'
  ///
  /// In pl, this message translates to:
  /// **'Stuknij \"Nowa rozmowa\", by zacząć pierwszą.'**
  String get chatsListEmptyHint;

  /// Tytuł dialogu potwierdzenia usunięcia rozmowy
  ///
  /// In pl, this message translates to:
  /// **'Usunąć rozmowę?'**
  String get chatsListDeleteConfirmTitle;

  /// Treść dialogu potwierdzenia usunięcia, z nazwą rozmowy
  ///
  /// In pl, this message translates to:
  /// **'Rozmowa \"{title}\" zostanie usunięta wraz ze wszystkimi wiadomościami.'**
  String chatsListDeleteConfirmContent(String title);

  /// Prefix dla dzisiejszej godziny w subtitle rozmowy. Tracked TODO: pełne formatowanie daty per locale przez intl DateFormat — obecnie format DD.MM.YYYY hardcoded
  ///
  /// In pl, this message translates to:
  /// **'Dziś'**
  String get chatsListToday;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
