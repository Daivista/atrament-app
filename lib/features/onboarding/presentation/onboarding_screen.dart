import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme.dart';
import '../../../l10n/app_localizations.dart';

/// Pierwszy startup flow — 3 slajdy prezentujące core values Atramentu:
/// 1. Privacy (lokalny serwer, brak chmury)
/// 2. Control (model + parametry + reasoning)
/// 3. Easy start (CTA do dodania serwera)
///
/// Pokazywany TYLKO raz — flag `hasSeenOnboarding` w SharedPreferences
/// blokuje powtórne pokazanie. Skip i Get started oba ustawiają flag.
///
/// Po complete: pushReplacementNamed('/') — usuwa onboarding z stack
/// żeby Back z chats_list nie wracał do onboardingu.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  static const _totalPages = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    // Ustaw flag w SharedPreferences. Drugie uruchomienie aplikacji
    // odczyta flag w main() i pominie OnboardingScreen.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (!mounted) return;
    // pushReplacementNamed (nie pushNamed) — usuwa onboarding z navigation
    // stack żeby Back z chats_list nie wracał do onboardingu.
    Navigator.of(context).pushReplacementNamed('/');
  }

  void _onNext() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isLastPage = _currentPage == _totalPages - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button — top right, ukryty na ostatnim slajdzie
            // (na ostatnim CTA już jest "Rozpocznij" więc Skip byłby zbędny).
            SizedBox(
              height: 48,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                  child: AnimatedOpacity(
                    opacity: isLastPage ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: TextButton(
                      onPressed: isLastPage ? null : _completeOnboarding,
                      child: Text(loc.onboardingSkip),
                    ),
                  ),
                ),
              ),
            ),
            // PageView z 3 slajdami
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _OnboardingPage(
                    icon: Icons.cloud_off_outlined,
                    title: loc.onboardingPage1Title,
                    body: loc.onboardingPage1Body,
                  ),
                  _OnboardingPage(
                    icon: Icons.tune,
                    title: loc.onboardingPage2Title,
                    body: loc.onboardingPage2Body,
                  ),
                  _OnboardingPage(
                    icon: Icons.rocket_launch_outlined,
                    title: loc.onboardingPage3Title,
                    body: loc.onboardingPage3Body,
                  ),
                ],
              ),
            ),
            // Page indicators — kropki które wskazują aktualną stronę
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Spacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_totalPages, (i) {
                  final isActive = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
            // CTA button — "Dalej" dla slajdów 1-2, "Rozpocznij" dla 3
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.lg,
                Spacing.sm,
                Spacing.lg,
                Spacing.lg,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _onNext,
                  child: Text(
                    isLastPage ? loc.onboardingStart : loc.onboardingNext,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ikona w circle container z primaryContainer background. Material 3
          // konwencja: ikona w surface tonal container, nie raw icon.
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 56, color: cs.onPrimaryContainer),
          ),
          const SizedBox(height: Spacing.xl),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.md),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
