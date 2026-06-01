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

  /// Tablet refactor: SnackBar feedback gdy user próbuje przełączyć rozmowę lub stworzyć nową podczas trwającego streaming. Fixuje Sesja G discovered edge case (concurrent navigation/streaming) dla mobile + tablet uniformly.
  ///
  /// In pl, this message translates to:
  /// **'Trwa generowanie odpowiedzi. Zatrzymaj lub poczekaj.'**
  String get chatStreamingInProgress;

  /// Tablet split view: tooltip dla IconButton(menu_open) w lewym AppBar. Tap zwija sidebar — lista rozmów znika, chat zajmuje całą szerokość. Critical dla tablet portrait (~800dp) gdzie 35% lista zostawia chat tylko ~520dp.
  ///
  /// In pl, this message translates to:
  /// **'Schowaj listę rozmów'**
  String get tabletSidebarCollapse;

  /// Tablet split view: tooltip dla IconButton(menu) w prawym AppBar gdy sidebar collapsed. Tap rozwija sidebar — lista rozmów wraca z animacją cross-fade 200ms.
  ///
  /// In pl, this message translates to:
  /// **'Pokaż listę rozmów'**
  String get tabletSidebarExpand;

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

  /// No description provided for @chatParametersReasoningNone.
  ///
  /// In pl, this message translates to:
  /// **'—'**
  String get chatParametersReasoningNone;

  /// No description provided for @chatParametersReasoningLow.
  ///
  /// In pl, this message translates to:
  /// **'low'**
  String get chatParametersReasoningLow;

  /// No description provided for @chatParametersReasoningMedium.
  ///
  /// In pl, this message translates to:
  /// **'medium'**
  String get chatParametersReasoningMedium;

  /// No description provided for @chatParametersReasoningHigh.
  ///
  /// In pl, this message translates to:
  /// **'high'**
  String get chatParametersReasoningHigh;

  /// No description provided for @chatParametersDefaultHint.
  ///
  /// In pl, this message translates to:
  /// **'domyślne serwera'**
  String get chatParametersDefaultHint;

  /// Tooltip przycisku zarządzania serwerami w AppBar listy rozmów
  ///
  /// In pl, this message translates to:
  /// **'Serwery'**
  String get chatsListServersTooltip;

  /// No description provided for @chatsListError.
  ///
  /// In pl, this message translates to:
  /// **'Błąd: {error}'**
  String chatsListError(Object error);

  /// No description provided for @chatsListRename.
  ///
  /// In pl, this message translates to:
  /// **'Zmień nazwę'**
  String get chatsListRename;

  /// No description provided for @chatsListEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Brak rozmów'**
  String get chatsListEmpty;

  /// No description provided for @chatsListEmptyHint.
  ///
  /// In pl, this message translates to:
  /// **'Stuknij \"Nowa rozmowa\", by zacząć pierwszą.'**
  String get chatsListEmptyHint;

  /// No description provided for @chatsListDeleteConfirmTitle.
  ///
  /// In pl, this message translates to:
  /// **'Usunąć rozmowę?'**
  String get chatsListDeleteConfirmTitle;

  /// No description provided for @chatsListDeleteConfirmContent.
  ///
  /// In pl, this message translates to:
  /// **'Rozmowa \"{title}\" zostanie usunięta wraz ze wszystkimi wiadomościami.'**
  String chatsListDeleteConfirmContent(String title);

  /// No description provided for @chatsListToday.
  ///
  /// In pl, this message translates to:
  /// **'Dziś'**
  String get chatsListToday;

  /// No description provided for @profilesScreenTitle.
  ///
  /// In pl, this message translates to:
  /// **'Serwery'**
  String get profilesScreenTitle;

  /// No description provided for @profilesScreenError.
  ///
  /// In pl, this message translates to:
  /// **'Błąd: {error}'**
  String profilesScreenError(Object error);

  /// No description provided for @profilesScreenKeyLost.
  ///
  /// In pl, this message translates to:
  /// **'Klucz API utracony — wybierz Edytuj, by wpisać ponownie'**
  String get profilesScreenKeyLost;

  /// No description provided for @profilesScreenActionActivate.
  ///
  /// In pl, this message translates to:
  /// **'Ustaw jako aktywny'**
  String get profilesScreenActionActivate;

  /// No description provided for @profilesScreenActionDeactivate.
  ///
  /// In pl, this message translates to:
  /// **'Usuń oznaczenie aktywnego'**
  String get profilesScreenActionDeactivate;

  /// No description provided for @profilesScreenActionEdit.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj'**
  String get profilesScreenActionEdit;

  /// No description provided for @profilesScreenAddProfile.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj serwer'**
  String get profilesScreenAddProfile;

  /// No description provided for @profilesScreenDeleteConfirmTitle.
  ///
  /// In pl, this message translates to:
  /// **'Usunąć serwer?'**
  String get profilesScreenDeleteConfirmTitle;

  /// No description provided for @profilesScreenDeleteConfirmContent.
  ///
  /// In pl, this message translates to:
  /// **'Profil „{name}\" zostanie usunięty wraz z kluczem API. Tej operacji nie można cofnąć.'**
  String profilesScreenDeleteConfirmContent(String name);

  /// No description provided for @profilesScreenEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Brak serwerów'**
  String get profilesScreenEmpty;

  /// No description provided for @profilesScreenEmptyHint.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj swój pierwszy serwer LLM (LM Studio, Ollama…), żeby zacząć rozmowę.'**
  String get profilesScreenEmptyHint;

  /// No description provided for @addProfileTitleNew.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj serwer'**
  String get addProfileTitleNew;

  /// No description provided for @addProfileTitleEdit.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj serwer'**
  String get addProfileTitleEdit;

  /// No description provided for @addProfileNameLabel.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa (opcjonalna)'**
  String get addProfileNameLabel;

  /// No description provided for @addProfileNameHint.
  ///
  /// In pl, this message translates to:
  /// **'np. LM Studio - laptop'**
  String get addProfileNameHint;

  /// No description provided for @addProfileUrlLabel.
  ///
  /// In pl, this message translates to:
  /// **'Adres serwera'**
  String get addProfileUrlLabel;

  /// No description provided for @addProfileMissingUrl.
  ///
  /// In pl, this message translates to:
  /// **'Podaj adres serwera.'**
  String get addProfileMissingUrl;

  /// No description provided for @addProfileCleartextTitle.
  ///
  /// In pl, this message translates to:
  /// **'Połączenie nieszyfrowane'**
  String get addProfileCleartextTitle;

  /// No description provided for @addProfileCleartextContent.
  ///
  /// In pl, this message translates to:
  /// **'Łączysz się przez HTTP z publicznym adresem. Dane (klucz API, rozmowy) mogą zostać przechwycone. Dla sieci lokalnej to zwykle bezpieczne, dla publicznych zalecamy HTTPS.\n\nKontynuować?'**
  String get addProfileCleartextContent;

  /// No description provided for @addProfileContinue.
  ///
  /// In pl, this message translates to:
  /// **'Kontynuuj'**
  String get addProfileContinue;

  /// No description provided for @addProfileApiKeyLost.
  ///
  /// In pl, this message translates to:
  /// **'Klucz API tego serwera został utracony (np. po przywróceniu kopii zapasowej). Wpisz go ponownie poniżej, by przywrócić połączenie.'**
  String get addProfileApiKeyLost;

  /// No description provided for @addProfileApiKeyLabel.
  ///
  /// In pl, this message translates to:
  /// **'Klucz API (opcjonalny)'**
  String get addProfileApiKeyLabel;

  /// No description provided for @addProfileApiKeyHintExisting.
  ///
  /// In pl, this message translates to:
  /// **'zapisany — zostaw puste by nie zmieniać'**
  String get addProfileApiKeyHintExisting;

  /// No description provided for @addProfileApiKeyHintNew.
  ///
  /// In pl, this message translates to:
  /// **'dla serwerów wymagających autoryzacji'**
  String get addProfileApiKeyHintNew;

  /// No description provided for @addProfileClearKey.
  ///
  /// In pl, this message translates to:
  /// **'Usuń zapisany klucz API'**
  String get addProfileClearKey;

  /// No description provided for @addProfileConnecting.
  ///
  /// In pl, this message translates to:
  /// **'Łączenie…'**
  String get addProfileConnecting;

  /// No description provided for @addProfileTestConnection.
  ///
  /// In pl, this message translates to:
  /// **'Testuj połączenie'**
  String get addProfileTestConnection;

  /// No description provided for @addProfileConnected.
  ///
  /// In pl, this message translates to:
  /// **'✅ Połączono — {count, plural, =0{brak dostępnych modeli} one{{count} model dostępny} few{{count} modele dostępne} many{{count} modeli dostępnych} other{{count} modeli dostępnych}}:'**
  String addProfileConnected(int count);

  /// No description provided for @addProfileSaving.
  ///
  /// In pl, this message translates to:
  /// **'Zapisywanie…'**
  String get addProfileSaving;

  /// No description provided for @addProfileSaveChanges.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz zmiany'**
  String get addProfileSaveChanges;

  /// No description provided for @addProfileSaveNew.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz serwer'**
  String get addProfileSaveNew;

  /// No description provided for @addProfileSaveError.
  ///
  /// In pl, this message translates to:
  /// **'Błąd zapisu: {error}'**
  String addProfileSaveError(String error);

  /// No description provided for @diagnosticsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Diagnostyka'**
  String get diagnosticsTitle;

  /// No description provided for @diagnosticsAboutSection.
  ///
  /// In pl, this message translates to:
  /// **'O aplikacji'**
  String get diagnosticsAboutSection;

  /// No description provided for @diagnosticsAppLabel.
  ///
  /// In pl, this message translates to:
  /// **'Aplikacja'**
  String get diagnosticsAppLabel;

  /// No description provided for @diagnosticsBuildModeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Tryb buildu'**
  String get diagnosticsBuildModeLabel;

  /// No description provided for @diagnosticsPackageNameLabel.
  ///
  /// In pl, this message translates to:
  /// **'Package'**
  String get diagnosticsPackageNameLabel;

  /// No description provided for @diagnosticsStateSection.
  ///
  /// In pl, this message translates to:
  /// **'Stan'**
  String get diagnosticsStateSection;

  /// No description provided for @diagnosticsProfileCount.
  ///
  /// In pl, this message translates to:
  /// **'Liczba profili'**
  String get diagnosticsProfileCount;

  /// No description provided for @diagnosticsActiveProfile.
  ///
  /// In pl, this message translates to:
  /// **'Aktywny profil'**
  String get diagnosticsActiveProfile;

  /// No description provided for @diagnosticsChatCount.
  ///
  /// In pl, this message translates to:
  /// **'Liczba rozmów'**
  String get diagnosticsChatCount;

  /// No description provided for @diagnosticsNone.
  ///
  /// In pl, this message translates to:
  /// **'— brak —'**
  String get diagnosticsNone;

  /// No description provided for @diagnosticsLogsSection.
  ///
  /// In pl, this message translates to:
  /// **'Logi ({count})'**
  String diagnosticsLogsSection(int count);

  /// No description provided for @diagnosticsLogsEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Brak logów w tej sesji.'**
  String get diagnosticsLogsEmpty;

  /// No description provided for @diagnosticsShareLogs.
  ///
  /// In pl, this message translates to:
  /// **'Udostępnij logi'**
  String get diagnosticsShareLogs;

  /// No description provided for @diagnosticsClearAll.
  ///
  /// In pl, this message translates to:
  /// **'Wyczyść wszystko'**
  String get diagnosticsClearAll;

  /// No description provided for @diagnosticsClearAllConfirmTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wyczyścić wszystko?'**
  String get diagnosticsClearAllConfirmTitle;

  /// No description provided for @diagnosticsClearAllConfirmContent.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie logi i raporty awarii z tej sesji zostaną usunięte. Tej operacji nie można cofnąć.'**
  String get diagnosticsClearAllConfirmContent;

  /// No description provided for @diagnosticsError.
  ///
  /// In pl, this message translates to:
  /// **'Błąd: {error}'**
  String diagnosticsError(String error);

  /// No description provided for @diagnosticsShareError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się udostępnić: {error}'**
  String diagnosticsShareError(String error);

  /// No description provided for @diagnosticsCrashesSection.
  ///
  /// In pl, this message translates to:
  /// **'Awarie ({count, plural, =0{0} one{{count}} few{{count}} many{{count}} other{{count}}})'**
  String diagnosticsCrashesSection(int count);

  /// No description provided for @diagnosticsNoCrashes.
  ///
  /// In pl, this message translates to:
  /// **'Brak awarii w tej sesji. 🎉'**
  String get diagnosticsNoCrashes;

  /// No description provided for @diagnosticsSendCrashReport.
  ///
  /// In pl, this message translates to:
  /// **'Wyślij raport o awarii'**
  String get diagnosticsSendCrashReport;

  /// No description provided for @diagnosticsCrashReportSubject.
  ///
  /// In pl, this message translates to:
  /// **'Atrament — raport o awarii'**
  String get diagnosticsCrashReportSubject;

  /// No description provided for @diagnosticsTestCrash.
  ///
  /// In pl, this message translates to:
  /// **'Wywołaj testową awarię'**
  String get diagnosticsTestCrash;

  /// No description provided for @diagnosticsTestCrashTriggered.
  ///
  /// In pl, this message translates to:
  /// **'Testowa awaria wywołana — zobacz sekcję Awarie'**
  String get diagnosticsTestCrashTriggered;

  /// No description provided for @reportResponseTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zgłoś problem z odpowiedzią'**
  String get reportResponseTitle;

  /// No description provided for @reportResponseIntro.
  ///
  /// In pl, this message translates to:
  /// **'Twój raport pomoże ulepszyć aplikację. NIC nie zostanie wysłane automatycznie — wybierzesz sam komu udostępnić (email, schowek, itp).'**
  String get reportResponseIntro;

  /// No description provided for @reportResponseCategoryLabel.
  ///
  /// In pl, this message translates to:
  /// **'Kategoria:'**
  String get reportResponseCategoryLabel;

  /// No description provided for @reportCategoryInaccurate.
  ///
  /// In pl, this message translates to:
  /// **'Nieprawdziwe info'**
  String get reportCategoryInaccurate;

  /// No description provided for @reportCategoryOffTopic.
  ///
  /// In pl, this message translates to:
  /// **'Nie na temat'**
  String get reportCategoryOffTopic;

  /// No description provided for @reportCategoryUnsafe.
  ///
  /// In pl, this message translates to:
  /// **'Toksyczne / niebezpieczne'**
  String get reportCategoryUnsafe;

  /// No description provided for @reportCategoryPoorQuality.
  ///
  /// In pl, this message translates to:
  /// **'Złej jakości'**
  String get reportCategoryPoorQuality;

  /// No description provided for @reportCategoryOther.
  ///
  /// In pl, this message translates to:
  /// **'Inne'**
  String get reportCategoryOther;

  /// No description provided for @reportResponseCommentLabel.
  ///
  /// In pl, this message translates to:
  /// **'Komentarz (opcjonalny):'**
  String get reportResponseCommentLabel;

  /// No description provided for @reportResponseCommentHint.
  ///
  /// In pl, this message translates to:
  /// **'Opisz krótko co jest nie tak…'**
  String get reportResponseCommentHint;

  /// No description provided for @reportResponseDisclaimerTitle.
  ///
  /// In pl, this message translates to:
  /// **'Co zostanie udostępnione'**
  String get reportResponseDisclaimerTitle;

  /// No description provided for @reportResponseDisclaimerContent.
  ///
  /// In pl, this message translates to:
  /// **'Twoja kategoria i komentarz, twoje pytanie, raportowana odpowiedź modelu, parametry rozmowy, model, system prompt (jeśli był) oraz ostatnie 20 entries logów technicznych. Klucze API i inne rozmowy NIE są dołączane.'**
  String get reportResponseDisclaimerContent;

  /// No description provided for @reportResponseShare.
  ///
  /// In pl, this message translates to:
  /// **'Udostępnij'**
  String get reportResponseShare;

  /// No description provided for @reportResponseSubject.
  ///
  /// In pl, this message translates to:
  /// **'Atrament — raport problemu z odpowiedzią'**
  String get reportResponseSubject;

  /// No description provided for @reportResponseShareError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się udostępnić raportu: {error}'**
  String reportResponseShareError(String error);

  /// No description provided for @onboardingSkip.
  ///
  /// In pl, this message translates to:
  /// **'Pomiń'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In pl, this message translates to:
  /// **'Dalej'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In pl, this message translates to:
  /// **'Rozpocznij'**
  String get onboardingStart;

  /// No description provided for @onboardingPage1Title.
  ///
  /// In pl, this message translates to:
  /// **'Rozmowy bez chmury'**
  String get onboardingPage1Title;

  /// No description provided for @onboardingPage1Body.
  ///
  /// In pl, this message translates to:
  /// **'Atrament łączy się z lokalnym serwerem LLM na twoim komputerze. Twoje dane nigdy nie opuszczają urządzenia.'**
  String get onboardingPage1Body;

  /// No description provided for @onboardingPage2Title.
  ///
  /// In pl, this message translates to:
  /// **'Pełna kontrola'**
  String get onboardingPage2Title;

  /// No description provided for @onboardingPage2Body.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz model, dostosuj parametry, podejrzyj proces myślowy. Wszystko czego potrzebujesz.'**
  String get onboardingPage2Body;

  /// No description provided for @onboardingPage3Title.
  ///
  /// In pl, this message translates to:
  /// **'Zaczynamy'**
  String get onboardingPage3Title;

  /// No description provided for @onboardingPage3Body.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj swój serwer LM Studio lub Ollama, wybierz model i zacznij rozmowę.'**
  String get onboardingPage3Body;

  /// No description provided for @splitViewEmptyTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz rozmowę'**
  String get splitViewEmptyTitle;

  /// No description provided for @splitViewEmptyBody.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz rozmowę z listy lub stwórz nową, aby zacząć.'**
  String get splitViewEmptyBody;
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
