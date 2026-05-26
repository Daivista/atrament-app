/// Walidacja adresów serwera dla decyzji o ostrzeżeniu cleartext.
/// Ironia (i sedno decyzji v1.6.6): CIDR działa tu w Dart, czego
/// Android network_security_config.xml nie potrafi. Bezpieczeństwo
/// przeniesione z warstwy XML do warstwy aplikacji.

/// Czy host w URL należy do prywatnej/lokalnej sieci.
bool isPrivateAddress(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  final host = uri.host.toLowerCase();
  if (host.isEmpty) return false;

  if (host == 'localhost') return true;

  // IPv6 (podstawowo): loopback, ULA fc00::/7, link-local fe80::/10
  if (host == '::1') return true;
  if (host.startsWith('fc') || host.startsWith('fd')) return true;
  if (host.startsWith('fe80')) return true;

  // IPv4
  final parts = host.split('.');
  if (parts.length == 4) {
    final octets = parts.map(int.tryParse).toList();
    if (octets.any((o) => o == null || o < 0 || o > 255)) return false;
    final a = octets[0]!, b = octets[1]!;
    if (a == 10) return true; //                10.0.0.0/8
    if (a == 172 && b >= 16 && b <= 31) return true; // 172.16.0.0/12
    if (a == 192 && b == 168) return true; //   192.168.0.0/16
    if (a == 127) return true; //               127.0.0.0/8 loopback
    if (a == 169 && b == 254) return true; //   169.254.0.0/16 link-local
    return false;
  }

  // nazwa domeny (nie IP) → traktujemy jako publiczny
  return false;
}

/// Czy URL używa niezaszyfrowanego HTTP (nie HTTPS).
bool isCleartext(String url) {
  final uri = Uri.tryParse(url);
  return uri?.scheme.toLowerCase() == 'http';
}

/// Czy pokazać ostrzeżenie: niezaszyfrowane połączenie z publicznym adresem.
/// (punkt 3: to tylko sygnał dla UI — ostrzeżenie nie blokuje)
bool shouldWarnCleartext(String url) =>
    isCleartext(url) && !isPrivateAddress(url);
