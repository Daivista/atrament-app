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

  /// Przycisk kopiowania kodu w bloku ``` do schowka lub treści wiadomości assistant
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

  /// Tooltip dla PopupMenuButton w AppBar lub w bańkach wiadomości
  ///
  /// In pl, this message translates to:
  /// **'Więcej'**
  String get commonMoreMenu;

  /// Tooltip przycisku motywu w AppBar — stan systemowy
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

  /// Tytuł dialogu edycji nazwy rozmowy
  ///
  /// In pl, this message translates to:
  /// **'Zmień nazwę rozmowy'**
  String get chatTitleEditDialog;

  /// Banner gdy ostatnia odpowiedź modelu jest częściowa
  ///
  /// In pl, this message translates to:
  /// **'Odpowiedź przerwana'**
  String get chatResponseInterrupted;

  /// Przycisk w bannerze odpowiedzi przerwanej
  ///
  /// In pl, this message translates to:
  /// **'Kontynuuj'**
  String get chatContinueButton;

  /// Tytuł pustego ekranu gdy żaden profil nie jest aktywny
  ///
  /// In pl, this message translates to:
  /// **'Brak aktywnego serwera'**
  String get chatNoActiveServerTitle;

  /// Tytuł pustego ekranu gdy aktywny profil rzucił błąd
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

  /// Tooltip przycisku zatrzymania strumieniowania
  ///
  /// In pl, this message translates to:
  /// **'Zatrzymaj'**
  String get chatStopTooltip;

  /// Tooltip przycisku wysłania wiadomości
  ///
  /// In pl, this message translates to:
  /// **'Wyślij'**
  String get chatSendTooltip;

  /// Etykieta sekcji reasoning w bańce (akordeon Sesja F)
  ///
  /// In pl, this message translates to:
  /// **'Myślenie'**
  String get chatReasoningLabel;

  /// Pozycja w PopupMenu bańki assistant — otwiera ReportResponseDialog (Sesja E)
  ///
  /// In pl, this message translates to:
  /// **'Raportuj odpowiedź'**
  String get chatReportResponse;

  /// Pozycja w PopupMenu bańki ostatniej assistant message (Sesja G)
  ///
  /// In pl, this message translates to:
  /// **'Regeneruj'**
  String get chatRegenerate;

  /// Tooltip ikony tune w AppBar chat_screen
  ///
  /// In pl, this message translates to:
  /// **'Parametry rozmowy'**
  String get chatParametersTooltip;

  /// Tytuł bottom sheet ChatParametersSheet
  ///
  /// In pl, this message translates to:
  /// **'Parametry rozmowy'**
  String get chatParametersTitle;

  /// Label sekcji wyboru modelu
  ///
  /// In pl, this message translates to:
  /// **'Model'**
  String get chatParametersModel;

  /// Tryb UI: tylko suwak Kreatywność + system prompt
  ///
  /// In pl, this message translates to:
  /// **'Prosty'**
  String get chatParametersModeSimple;

  /// Tryb UI: + max_tokens, seed
  ///
  /// In pl, this message translates to:
  /// **'Średni'**
  String get chatParametersModeMedium;

  /// Tryb UI: wszystkie 13 parametrów
  ///
  /// In pl, this message translates to:
  /// **'Zaawansowany'**
  String get chatParametersModeAdvanced;

  /// Label suwaka Kreatywność
  ///
  /// In pl, this message translates to:
  /// **'Kreatywność'**
  String get chatParametersCreativity;

  /// Etykieta pod lewym końcem suwaka
  ///
  /// In pl, this message translates to:
  /// **'precyzyjny (0.2)'**
  String get chatParametersCreativityPrecise;

  /// Etykieta pod prawym końcem suwaka
  ///
  /// In pl, this message translates to:
  /// **'kreatywny (1.2)'**
  String get chatParametersCreativityCreative;

  /// Label sekcji edycji system promptu
  ///
  /// In pl, this message translates to:
  /// **'System prompt (opcjonalnie)'**
  String get chatParametersSystemPrompt;

  /// Placeholder w polu textarea system prompt
  ///
  /// In pl, this message translates to:
  /// **'Jesteś pomocnym asystentem...'**
  String get chatParametersSystemPromptHint;

  /// Label pola max_tokens
  ///
  /// In pl, this message translates to:
  /// **'Maks. tokenów'**
  String get chatParametersMaxTokens;

  /// Label pola top_p
  ///
  /// In pl, this message translates to:
  /// **'Top-P'**
  String get chatParametersTopP;

  /// Label pola top_k
  ///
  /// In pl, this message translates to:
  /// **'Top-K'**
  String get chatParametersTopK;

  /// Label pola min_p
  ///
  /// In pl, this message translates to:
  /// **'Min-P'**
  String get chatParametersMinP;

  /// Label pola seed
  ///
  /// In pl, this message translates to:
  /// **'Seed'**
  String get chatParametersSeed;

  /// Label suwaka repeat_penalty
  ///
  /// In pl, this message translates to:
  /// **'Repeat penalty'**
  String get chatParametersRepeatPenalty;

  /// Label suwaka frequency_penalty
  ///
  /// In pl, this message translates to:
  /// **'Frequency penalty'**
  String get chatParametersFrequencyPenalty;

  /// Label suwaka presence_penalty
  ///
  /// In pl, this message translates to:
  /// **'Presence penalty'**
  String get chatParametersPresencePenalty;

  /// Label pola stop
  ///
  /// In pl, this message translates to:
  /// **'Stop sequences'**
  String get chatParametersStop;

  /// Placeholder dla pola stop
  ///
  /// In pl, this message translates to:
  /// **'np. END, STOP, ###'**
  String get chatParametersStopHint;

  /// Label segmented button dla reasoning_effort
  ///
  /// In pl, this message translates to:
  /// **'Reasoning effort'**
  String get chatParametersReasoningEffort;

  /// Wartość 'None' dla reasoning_effort
  ///
  /// In pl, this message translates to:
  /// **'—'**
  String get chatParametersReasoningNone;

  /// Wartość 'low' dla reasoning_effort
  ///
  /// In pl, this message translates to:
  /// **'low'**
  String get chatParametersReasoningLow;

  /// Wartość 'medium' dla reasoning_effort
  ///
  /// In pl, this message translates to:
  /// **'medium'**
  String get chatParametersReasoningMedium;

  /// Wartość 'high' dla reasoning_effort
  ///
  /// In pl, this message translates to:
  /// **'high'**
  String get chatParametersReasoningHigh;

  /// Hint w pustych polach numerycznych
  ///
  /// In pl, this message translates to:
  /// **'domyślne serwera'**
  String get chatParametersDefaultHint;

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

  /// Pozycja w popup menu rozmowy
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

  /// Treść dialogu potwierdzenia usunięcia
  ///
  /// In pl, this message translates to:
  /// **'Rozmowa \"{title}\" zostanie usunięta wraz ze wszystkimi wiadomościami.'**
  String chatsListDeleteConfirmContent(String title);

  /// Prefix dla dzisiejszej godziny w subtitle rozmowy
  ///
  /// In pl, this message translates to:
  /// **'Dziś'**
  String get chatsListToday;

  /// AppBar tytuł ekranu listy profili
  ///
  /// In pl, this message translates to:
  /// **'Serwery'**
  String get profilesScreenTitle;

  /// Komunikat błędu
  ///
  /// In pl, this message translates to:
  /// **'Błąd: {error}'**
  String profilesScreenError(Object error);

  /// Subtitle profilu gdy apiKeyNeedsReentry = true
  ///
  /// In pl, this message translates to:
  /// **'Klucz API utracony — wybierz Edytuj, by wpisać ponownie'**
  String get profilesScreenKeyLost;

  /// Popup menu akcja na profilu
  ///
  /// In pl, this message translates to:
  /// **'Ustaw jako aktywny'**
  String get profilesScreenActionActivate;

  /// Popup menu akcja — odznacza aktywność
  ///
  /// In pl, this message translates to:
  /// **'Usuń oznaczenie aktywnego'**
  String get profilesScreenActionDeactivate;

  /// Popup menu akcja — otwiera edycję
  ///
  /// In pl, this message translates to:
  /// **'Edytuj'**
  String get profilesScreenActionEdit;

  /// Label FAB na liście profili
  ///
  /// In pl, this message translates to:
  /// **'Dodaj serwer'**
  String get profilesScreenAddProfile;

  /// Tytuł dialogu potwierdzenia usunięcia profilu
  ///
  /// In pl, this message translates to:
  /// **'Usunąć serwer?'**
  String get profilesScreenDeleteConfirmTitle;

  /// Treść dialogu potwierdzenia
  ///
  /// In pl, this message translates to:
  /// **'Profil „{name}\" zostanie usunięty wraz z kluczem API. Tej operacji nie można cofnąć.'**
  String profilesScreenDeleteConfirmContent(String name);

  /// Tytuł pustego stanu listy profili
  ///
  /// In pl, this message translates to:
  /// **'Brak serwerów'**
  String get profilesScreenEmpty;

  /// Podpowiedź pod 'Brak serwerów'
  ///
  /// In pl, this message translates to:
  /// **'Dodaj swój pierwszy serwer LLM (LM Studio, Ollama…), żeby zacząć rozmowę.'**
  String get profilesScreenEmptyHint;

  /// AppBar tytuł AddProfileScreen w trybie nowym
  ///
  /// In pl, this message translates to:
  /// **'Dodaj serwer'**
  String get addProfileTitleNew;

  /// AppBar tytuł AddProfileScreen w trybie edycji
  ///
  /// In pl, this message translates to:
  /// **'Edytuj serwer'**
  String get addProfileTitleEdit;

  /// Label pola nazwy profilu
  ///
  /// In pl, this message translates to:
  /// **'Nazwa (opcjonalna)'**
  String get addProfileNameLabel;

  /// Hint dla pola nazwy
  ///
  /// In pl, this message translates to:
  /// **'np. LM Studio - laptop'**
  String get addProfileNameHint;

  /// Label pola URL
  ///
  /// In pl, this message translates to:
  /// **'Adres serwera'**
  String get addProfileUrlLabel;

  /// Validation error
  ///
  /// In pl, this message translates to:
  /// **'Podaj adres serwera.'**
  String get addProfileMissingUrl;

  /// Tytuł dialogu cleartext warning
  ///
  /// In pl, this message translates to:
  /// **'Połączenie nieszyfrowane'**
  String get addProfileCleartextTitle;

  /// Content dialogu cleartext warning
  ///
  /// In pl, this message translates to:
  /// **'Łączysz się przez HTTP z publicznym adresem. Dane (klucz API, rozmowy) mogą zostać przechwycone. Dla sieci lokalnej to zwykle bezpieczne, dla publicznych zalecamy HTTPS.\n\nKontynuować?'**
  String get addProfileCleartextContent;

  /// Przycisk 'kontynuuj' w cleartext warning
  ///
  /// In pl, this message translates to:
  /// **'Kontynuuj'**
  String get addProfileContinue;

  /// Warning card w trybie edycji
  ///
  /// In pl, this message translates to:
  /// **'Klucz API tego serwera został utracony (np. po przywróceniu kopii zapasowej). Wpisz go ponownie poniżej, by przywrócić połączenie.'**
  String get addProfileApiKeyLost;

  /// Label pola klucza API
  ///
  /// In pl, this message translates to:
  /// **'Klucz API (opcjonalny)'**
  String get addProfileApiKeyLabel;

  /// Hint pola klucza w edycji gdy klucz istnieje
  ///
  /// In pl, this message translates to:
  /// **'zapisany — zostaw puste by nie zmieniać'**
  String get addProfileApiKeyHintExisting;

  /// Hint pola klucza w nowym lub edycji gdy klucz nie istnieje
  ///
  /// In pl, this message translates to:
  /// **'dla serwerów wymagających autoryzacji'**
  String get addProfileApiKeyHintNew;

  /// Label checkboxa do skasowania klucza
  ///
  /// In pl, this message translates to:
  /// **'Usuń zapisany klucz API'**
  String get addProfileClearKey;

  /// Label przycisku 'Testuj połączenie' podczas requestu
  ///
  /// In pl, this message translates to:
  /// **'Łączenie…'**
  String get addProfileConnecting;

  /// Label przycisku testu połączenia
  ///
  /// In pl, this message translates to:
  /// **'Testuj połączenie'**
  String get addProfileTestConnection;

  /// Komunikat sukcesu połączenia z liczbą modeli (ICU plural PL)
  ///
  /// In pl, this message translates to:
  /// **'✅ Połączono — {count, plural, =0{brak dostępnych modeli} one{{count} model dostępny} few{{count} modele dostępne} many{{count} modeli dostępnych} other{{count} modeli dostępnych}}:'**
  String addProfileConnected(int count);

  /// Label przycisku zapisu podczas writu
  ///
  /// In pl, this message translates to:
  /// **'Zapisywanie…'**
  String get addProfileSaving;

  /// Label przycisku zapisu w edycji
  ///
  /// In pl, this message translates to:
  /// **'Zapisz zmiany'**
  String get addProfileSaveChanges;

  /// Label przycisku zapisu w trybie nowym
  ///
  /// In pl, this message translates to:
  /// **'Zapisz serwer'**
  String get addProfileSaveNew;

  /// Error message gdy zapis do bazy rzuci wyjątek
  ///
  /// In pl, this message translates to:
  /// **'Błąd zapisu: {error}'**
  String addProfileSaveError(String error);

  /// Tytuł ekranu Diagnostyka
  ///
  /// In pl, this message translates to:
  /// **'Diagnostyka'**
  String get diagnosticsTitle;

  /// Nagłówek sekcji 'O aplikacji'
  ///
  /// In pl, this message translates to:
  /// **'O aplikacji'**
  String get diagnosticsAboutSection;

  /// Label wiersza z nazwą + wersją
  ///
  /// In pl, this message translates to:
  /// **'Aplikacja'**
  String get diagnosticsAppLabel;

  /// Label wiersza z trybem kompilacji
  ///
  /// In pl, this message translates to:
  /// **'Tryb buildu'**
  String get diagnosticsBuildModeLabel;

  /// Label wiersza z package name
  ///
  /// In pl, this message translates to:
  /// **'Package'**
  String get diagnosticsPackageNameLabel;

  /// Nagłówek sekcji 'Stan'
  ///
  /// In pl, this message translates to:
  /// **'Stan'**
  String get diagnosticsStateSection;

  /// Label wiersza z liczbą profili
  ///
  /// In pl, this message translates to:
  /// **'Liczba profili'**
  String get diagnosticsProfileCount;

  /// Label wiersza z aktywnym profilem
  ///
  /// In pl, this message translates to:
  /// **'Aktywny profil'**
  String get diagnosticsActiveProfile;

  /// Label wiersza z liczbą rozmów
  ///
  /// In pl, this message translates to:
  /// **'Liczba rozmów'**
  String get diagnosticsChatCount;

  /// Placeholder wartości gdy pole puste
  ///
  /// In pl, this message translates to:
  /// **'— brak —'**
  String get diagnosticsNone;

  /// Nagłówek sekcji logów
  ///
  /// In pl, this message translates to:
  /// **'Logi ({count})'**
  String diagnosticsLogsSection(int count);

  /// Placeholder gdy log buffer pusty
  ///
  /// In pl, this message translates to:
  /// **'Brak logów w tej sesji.'**
  String get diagnosticsLogsEmpty;

  /// Label FAB
  ///
  /// In pl, this message translates to:
  /// **'Udostępnij logi'**
  String get diagnosticsShareLogs;

  /// Tooltip ikony delete
  ///
  /// In pl, this message translates to:
  /// **'Wyczyść wszystko'**
  String get diagnosticsClearAll;

  /// Tytuł dialogu potwierdzenia
  ///
  /// In pl, this message translates to:
  /// **'Wyczyścić wszystko?'**
  String get diagnosticsClearAllConfirmTitle;

  /// Treść dialogu potwierdzenia
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie logi i raporty awarii z tej sesji zostaną usunięte. Tej operacji nie można cofnąć.'**
  String get diagnosticsClearAllConfirmContent;

  /// Komunikat błędu
  ///
  /// In pl, this message translates to:
  /// **'Błąd: {error}'**
  String diagnosticsError(String error);

  /// Snackbar gdy share intent rzuci wyjątek
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się udostępnić: {error}'**
  String diagnosticsShareError(String error);

  /// Nagłówek sekcji awarii z liczbą
  ///
  /// In pl, this message translates to:
  /// **'Awarie ({count, plural, =0{0} one{{count}} few{{count}} many{{count}} other{{count}}})'**
  String diagnosticsCrashesSection(int count);

  /// Placeholder gdy crashes list pusty
  ///
  /// In pl, this message translates to:
  /// **'Brak awarii w tej sesji. 🎉'**
  String get diagnosticsNoCrashes;

  /// Label przycisku w sekcji awarii
  ///
  /// In pl, this message translates to:
  /// **'Wyślij raport o awarii'**
  String get diagnosticsSendCrashReport;

  /// Subject w share intent dla crash reportu
  ///
  /// In pl, this message translates to:
  /// **'Atrament — raport o awarii'**
  String get diagnosticsCrashReportSubject;

  /// Label przycisku DEBUG-ONLY
  ///
  /// In pl, this message translates to:
  /// **'Wywołaj testową awarię'**
  String get diagnosticsTestCrash;

  /// Snackbar po kliknięciu Wywołaj testową awarię
  ///
  /// In pl, this message translates to:
  /// **'Testowa awaria wywołana — zobacz sekcję Awarie'**
  String get diagnosticsTestCrashTriggered;

  /// Tytuł ReportResponseDialog
  ///
  /// In pl, this message translates to:
  /// **'Zgłoś problem z odpowiedzią'**
  String get reportResponseTitle;

  /// Wstęp dialogu
  ///
  /// In pl, this message translates to:
  /// **'Twój raport pomoże ulepszyć aplikację. NIC nie zostanie wysłane automatycznie — wybierzesz sam komu udostępnić (email, schowek, itp).'**
  String get reportResponseIntro;

  /// Label sekcji wyboru kategorii
  ///
  /// In pl, this message translates to:
  /// **'Kategoria:'**
  String get reportResponseCategoryLabel;

  /// Kategoria: fakt nieprawdziwy
  ///
  /// In pl, this message translates to:
  /// **'Nieprawdziwe info'**
  String get reportCategoryInaccurate;

  /// Kategoria: off-topic
  ///
  /// In pl, this message translates to:
  /// **'Nie na temat'**
  String get reportCategoryOffTopic;

  /// Kategoria: toxic
  ///
  /// In pl, this message translates to:
  /// **'Toksyczne / niebezpieczne'**
  String get reportCategoryUnsafe;

  /// Kategoria: poor quality
  ///
  /// In pl, this message translates to:
  /// **'Złej jakości'**
  String get reportCategoryPoorQuality;

  /// Kategoria: inne
  ///
  /// In pl, this message translates to:
  /// **'Inne'**
  String get reportCategoryOther;

  /// Label pola komentarza
  ///
  /// In pl, this message translates to:
  /// **'Komentarz (opcjonalny):'**
  String get reportResponseCommentLabel;

  /// Placeholder w polu komentarza
  ///
  /// In pl, this message translates to:
  /// **'Opisz krótko co jest nie tak…'**
  String get reportResponseCommentHint;

  /// Nagłówek info-boxa z disclaimer privacy
  ///
  /// In pl, this message translates to:
  /// **'Co zostanie udostępnione'**
  String get reportResponseDisclaimerTitle;

  /// Treść disclaimer privacy
  ///
  /// In pl, this message translates to:
  /// **'Twoja kategoria i komentarz, twoje pytanie, raportowana odpowiedź modelu, parametry rozmowy, model, system prompt (jeśli był) oraz ostatnie 20 entries logów technicznych. Klucze API i inne rozmowy NIE są dołączane.'**
  String get reportResponseDisclaimerContent;

  /// Przycisk submit
  ///
  /// In pl, this message translates to:
  /// **'Udostępnij'**
  String get reportResponseShare;

  /// Subject w share intent dla report response
  ///
  /// In pl, this message translates to:
  /// **'Atrament — raport problemu z odpowiedzią'**
  String get reportResponseSubject;

  /// Snackbar gdy share rzuci wyjątek
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się udostępnić raportu: {error}'**
  String reportResponseShareError(String error);

  /// Sesja H: TextButton w prawym górnym rogu OnboardingScreen — pomija onboarding i ustawia flag hasSeenOnboarding=true. Ukryty na ostatnim slajdzie (CTA tam jest 'Rozpocznij').
  ///
  /// In pl, this message translates to:
  /// **'Pomiń'**
  String get onboardingSkip;

  /// Sesja H: CTA button na dole OnboardingScreen dla slajdów 1-2. Przenosi do następnego slajdu.
  ///
  /// In pl, this message translates to:
  /// **'Dalej'**
  String get onboardingNext;

  /// Sesja H: CTA button na dole ostatniego slajdu. Ustawia flag i pushReplacementNamed('/').
  ///
  /// In pl, this message translates to:
  /// **'Rozpocznij'**
  String get onboardingStart;

  /// Sesja H slajd 1 — privacy positioning. Najmocniejsza pozycja konkurencyjna Atramentu wg manifestu.
  ///
  /// In pl, this message translates to:
  /// **'Rozmowy bez chmury'**
  String get onboardingPage1Title;

  /// Sesja H slajd 1 body — kategoryczne 'nigdy' jest świadome (Data Safety form po Sesji D deklaruje 'no data collected').
  ///
  /// In pl, this message translates to:
  /// **'Atrament łączy się z lokalnym serwerem LLM na twoim komputerze. Twoje dane nigdy nie opuszczają urządzenia.'**
  String get onboardingPage1Body;

  /// Sesja H slajd 2 — power features (parametry A1/A2 + reasoning F).
  ///
  /// In pl, this message translates to:
  /// **'Pełna kontrola'**
  String get onboardingPage2Title;

  /// Sesja H slajd 2 body — 'podejrzyj' sugeruje 'zobacz coś czego zwykle nie widać' (reasoning UI).
  ///
  /// In pl, this message translates to:
  /// **'Wybierz model, dostosuj parametry, podejrzyj proces myślowy. Wszystko czego potrzebujesz.'**
  String get onboardingPage2Body;

  /// Sesja H slajd 3 — quick start CTA.
  ///
  /// In pl, this message translates to:
  /// **'Zaczynamy'**
  String get onboardingPage3Title;

  /// Sesja H slajd 3 body — konkretne nazwy serwerów (LM Studio, Ollama) bo to są target users.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj swój serwer LM Studio lub Ollama, wybierz model i zacznij rozmowę.'**
  String get onboardingPage3Body;
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
