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
  String get commonMoreMenu => 'Więcej';

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
  String get chatReportResponse => 'Raportuj odpowiedź';

  @override
  String get chatRegenerate => 'Regeneruj';

  @override
  String get chatStreamingInProgress =>
      'Trwa generowanie odpowiedzi. Zatrzymaj lub poczekaj.';

  @override
  String get tabletSidebarCollapse => 'Schowaj listę rozmów';

  @override
  String get tabletSidebarExpand => 'Pokaż listę rozmów';

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

  @override
  String get profilesScreenTitle => 'Serwery';

  @override
  String profilesScreenError(Object error) {
    return 'Błąd: $error';
  }

  @override
  String get profilesScreenKeyLost =>
      'Klucz API utracony — wybierz Edytuj, by wpisać ponownie';

  @override
  String get profilesScreenActionActivate => 'Ustaw jako aktywny';

  @override
  String get profilesScreenActionDeactivate => 'Usuń oznaczenie aktywnego';

  @override
  String get profilesScreenActionEdit => 'Edytuj';

  @override
  String get profilesScreenAddProfile => 'Dodaj serwer';

  @override
  String get profilesScreenDeleteConfirmTitle => 'Usunąć serwer?';

  @override
  String profilesScreenDeleteConfirmContent(String name) {
    return 'Profil „$name\" zostanie usunięty wraz z kluczem API. Tej operacji nie można cofnąć.';
  }

  @override
  String get profilesScreenEmpty => 'Brak serwerów';

  @override
  String get profilesScreenEmptyHint =>
      'Dodaj swój pierwszy serwer LLM (LM Studio, Ollama…), żeby zacząć rozmowę.';

  @override
  String get addProfileTitleNew => 'Dodaj serwer';

  @override
  String get addProfileTitleEdit => 'Edytuj serwer';

  @override
  String get addProfileNameLabel => 'Nazwa (opcjonalna)';

  @override
  String get addProfileNameHint => 'np. LM Studio - laptop';

  @override
  String get addProfileUrlLabel => 'Adres serwera';

  @override
  String get addProfileMissingUrl => 'Podaj adres serwera.';

  @override
  String get addProfileCleartextTitle => 'Połączenie nieszyfrowane';

  @override
  String get addProfileCleartextContent =>
      'Łączysz się przez HTTP z publicznym adresem. Dane (klucz API, rozmowy) mogą zostać przechwycone. Dla sieci lokalnej to zwykle bezpieczne, dla publicznych zalecamy HTTPS.\n\nKontynuować?';

  @override
  String get addProfileContinue => 'Kontynuuj';

  @override
  String get addProfileApiKeyLost =>
      'Klucz API tego serwera został utracony (np. po przywróceniu kopii zapasowej). Wpisz go ponownie poniżej, by przywrócić połączenie.';

  @override
  String get addProfileApiKeyLabel => 'Klucz API (opcjonalny)';

  @override
  String get addProfileApiKeyHintExisting =>
      'zapisany — zostaw puste by nie zmieniać';

  @override
  String get addProfileApiKeyHintNew => 'dla serwerów wymagających autoryzacji';

  @override
  String get addProfileClearKey => 'Usuń zapisany klucz API';

  @override
  String get addProfileConnecting => 'Łączenie…';

  @override
  String get addProfileTestConnection => 'Testuj połączenie';

  @override
  String addProfileConnected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modeli dostępnych',
      many: '$count modeli dostępnych',
      few: '$count modele dostępne',
      one: '$count model dostępny',
      zero: 'brak dostępnych modeli',
    );
    return '✅ Połączono — $_temp0:';
  }

  @override
  String get addProfileSaving => 'Zapisywanie…';

  @override
  String get addProfileSaveChanges => 'Zapisz zmiany';

  @override
  String get addProfileSaveNew => 'Zapisz serwer';

  @override
  String addProfileSaveError(String error) {
    return 'Błąd zapisu: $error';
  }

  @override
  String get diagnosticsTitle => 'Diagnostyka';

  @override
  String get diagnosticsAboutSection => 'O aplikacji';

  @override
  String get diagnosticsAppLabel => 'Aplikacja';

  @override
  String get diagnosticsBuildModeLabel => 'Tryb buildu';

  @override
  String get diagnosticsPackageNameLabel => 'Package';

  @override
  String get diagnosticsStateSection => 'Stan';

  @override
  String get diagnosticsProfileCount => 'Liczba profili';

  @override
  String get diagnosticsActiveProfile => 'Aktywny profil';

  @override
  String get diagnosticsChatCount => 'Liczba rozmów';

  @override
  String get diagnosticsNone => '— brak —';

  @override
  String diagnosticsLogsSection(int count) {
    return 'Logi ($count)';
  }

  @override
  String get diagnosticsLogsEmpty => 'Brak logów w tej sesji.';

  @override
  String get diagnosticsShareLogs => 'Udostępnij logi';

  @override
  String get diagnosticsClearAll => 'Wyczyść wszystko';

  @override
  String get diagnosticsClearAllConfirmTitle => 'Wyczyścić wszystko?';

  @override
  String get diagnosticsClearAllConfirmContent =>
      'Wszystkie logi i raporty awarii z tej sesji zostaną usunięte. Tej operacji nie można cofnąć.';

  @override
  String diagnosticsError(String error) {
    return 'Błąd: $error';
  }

  @override
  String diagnosticsShareError(String error) {
    return 'Nie udało się udostępnić: $error';
  }

  @override
  String diagnosticsCrashesSection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count',
      many: '$count',
      few: '$count',
      one: '$count',
      zero: '0',
    );
    return 'Awarie ($_temp0)';
  }

  @override
  String get diagnosticsNoCrashes => 'Brak awarii w tej sesji. 🎉';

  @override
  String get diagnosticsSendCrashReport => 'Wyślij raport o awarii';

  @override
  String get diagnosticsCrashReportSubject => 'Atrament — raport o awarii';

  @override
  String get diagnosticsTestCrash => 'Wywołaj testową awarię';

  @override
  String get diagnosticsTestCrashTriggered =>
      'Testowa awaria wywołana — zobacz sekcję Awarie';

  @override
  String get reportResponseTitle => 'Zgłoś problem z odpowiedzią';

  @override
  String get reportResponseIntro =>
      'Twój raport pomoże ulepszyć aplikację. NIC nie zostanie wysłane automatycznie — wybierzesz sam komu udostępnić (email, schowek, itp).';

  @override
  String get reportResponseCategoryLabel => 'Kategoria:';

  @override
  String get reportCategoryInaccurate => 'Nieprawdziwe info';

  @override
  String get reportCategoryOffTopic => 'Nie na temat';

  @override
  String get reportCategoryUnsafe => 'Toksyczne / niebezpieczne';

  @override
  String get reportCategoryPoorQuality => 'Złej jakości';

  @override
  String get reportCategoryOther => 'Inne';

  @override
  String get reportResponseCommentLabel => 'Komentarz (opcjonalny):';

  @override
  String get reportResponseCommentHint => 'Opisz krótko co jest nie tak…';

  @override
  String get reportResponseDisclaimerTitle => 'Co zostanie udostępnione';

  @override
  String get reportResponseDisclaimerContent =>
      'Twoja kategoria i komentarz, twoje pytanie, raportowana odpowiedź modelu, parametry rozmowy, model, system prompt (jeśli był) oraz ostatnie 20 entries logów technicznych. Klucze API i inne rozmowy NIE są dołączane.';

  @override
  String get reportResponseShare => 'Udostępnij';

  @override
  String get reportResponseSubject =>
      'Atrament — raport problemu z odpowiedzią';

  @override
  String reportResponseShareError(String error) {
    return 'Nie udało się udostępnić raportu: $error';
  }

  @override
  String get onboardingSkip => 'Pomiń';

  @override
  String get onboardingNext => 'Dalej';

  @override
  String get onboardingStart => 'Rozpocznij';

  @override
  String get onboardingPage1Title => 'Rozmowy bez chmury';

  @override
  String get onboardingPage1Body =>
      'Atrament łączy się z lokalnym serwerem LLM na twoim komputerze. Twoje dane nigdy nie opuszczają urządzenia.';

  @override
  String get onboardingPage2Title => 'Pełna kontrola';

  @override
  String get onboardingPage2Body =>
      'Wybierz model, dostosuj parametry, podejrzyj proces myślowy. Wszystko czego potrzebujesz.';

  @override
  String get onboardingPage3Title => 'Zaczynamy';

  @override
  String get onboardingPage3Body =>
      'Dodaj swój serwer LM Studio lub Ollama, wybierz model i zacznij rozmowę.';

  @override
  String get splitViewEmptyTitle => 'Wybierz rozmowę';

  @override
  String get splitViewEmptyBody =>
      'Wybierz rozmowę z listy lub stwórz nową, aby zacząć.';
}
