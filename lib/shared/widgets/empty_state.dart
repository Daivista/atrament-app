import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// Pusty stan z ikoną, tytułem i opcjonalnym opisem. Używany przez chats_list
/// (gdy brak rozmów) i chat_screen (gdy brak aktywnego serwera).
///
/// Wyodrębniony z `_NoServer` i `_EmptyState` w sub-commit 2 Kroku 2 —
/// oba widgety miały prawie identyczną strukturę (Center > Padding > Column z
/// Icon + Text(title) + Text(body)). Realny DRY: dwa miejsca użycia, jeden
/// widget do utrzymania.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: cs.outline),
            const SizedBox(height: Spacing.lg),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.sm),
            Text(body, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
