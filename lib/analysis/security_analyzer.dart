import '../models/wifi_network.dart';

class SecurityAnalyzer {
  // ─── Security type detection ───────────────────────────────────────────────

  static SecurityType parseSecurityType(String capabilities) {
    if (capabilities.isEmpty) return SecurityType.open;
    final c = capabilities.toUpperCase();
    if (c.contains('WPA3') && c.contains('WPA2')) return SecurityType.wpa2wpa3;
    if (c.contains('WPA3')) return SecurityType.wpa3;
    if (c.contains('WPA2')) return SecurityType.wpa2;
    if (c.contains('WPA')) return SecurityType.wpa;
    if (c.contains('WEP')) return SecurityType.wep;
    return SecurityType.open; // [ESS] only → open network
  }

  // ─── Score (0 = very dangerous, 100 = very secure) ────────────────────────

  static int calculateSecurityScore({
    required SecurityType securityType,
    required bool isDuplicate,
    required int rssi,
    required String ssid,
  }) {
    int score = 100;

    switch (securityType) {
      case SecurityType.open:
        score -= 70;
        break;
      case SecurityType.wep:
        score -= 60;
        break;
      case SecurityType.wpa:
        score -= 30;
        break;
      case SecurityType.wpa2:
        score -= 10;
        break;
      case SecurityType.wpa2wpa3:
        score -= 5;
        break;
      case SecurityType.wpa3:
        score -= 0;
        break;
      case SecurityType.unknown:
        score -= 40;
        break;
    }

    if (isDuplicate) score -= 20;

    // Suspicious open-network SSID patterns
    if (securityType == SecurityType.open) {
      final lower = ssid.toLowerCase();
      final suspicious = ['free', 'public', 'wifi', 'hotspot', 'guest', 'open'];
      if (suspicious.any(lower.contains)) score -= 5;
    }

    return score.clamp(0, 100);
  }

  static RiskLevel determineRiskLevel(int score) {
    if (score >= 85) return RiskLevel.secure;
    if (score >= 65) return RiskLevel.low;
    if (score >= 45) return RiskLevel.medium;
    if (score >= 25) return RiskLevel.high;
    return RiskLevel.critical;
  }

  // ─── Risk factor generation ────────────────────────────────────────────────

  static List<RiskFactor> generateRiskFactors({
    required SecurityType securityType,
    required bool isDuplicate,
    required int rssi,
    required String ssid,
  }) {
    final factors = <RiskFactor>[];

    switch (securityType) {
      case SecurityType.open:
        factors.addAll([
          const RiskFactor(
            id: 'open_network',
            title: 'No Encryption',
            description:
                'All data is transmitted in plain text. Anyone in range can read your traffic with freely available tools.',
            severity: Severity.critical,
            attackVector:
                'An attacker within range uses tools like Wireshark to capture everything you send or receive — passwords, messages, and personal data.',
            mitigation:
                'Avoid open networks entirely. If you must connect, always use a VPN to encrypt your traffic.',
          ),
          const RiskFactor(
            id: 'mitm_risk',
            title: 'Man-in-the-Middle Risk',
            description:
                'Open networks are prime targets for MITM attacks where attackers silently intercept your communications.',
            severity: Severity.high,
            attackVector:
                'Attackers use ARP spoofing or a rogue hotspot to sit between your device and the router, reading and optionally modifying all traffic.',
            mitigation:
                'Only visit HTTPS sites. Use a VPN. Avoid logging into accounts or banking on open Wi-Fi.',
          ),
        ]);
        break;

      case SecurityType.wep:
        factors.add(const RiskFactor(
          id: 'wep_broken',
          title: 'WEP Encryption (Broken)',
          description:
              'WEP was cryptographically broken in 2001 and can be cracked in minutes using modern tools.',
          severity: Severity.critical,
          attackVector:
              'Tools like aircrack-ng capture a few thousand data packets and recover the WEP key in under 2 minutes on a busy network.',
          mitigation:
              'Treat this network as completely unencrypted. Ask the admin to upgrade to WPA3 or WPA2. Use a VPN.',
        ));
        break;

      case SecurityType.wpa:
        factors.add(const RiskFactor(
          id: 'wpa_legacy',
          title: 'Legacy WPA (Deprecated)',
          description:
              'WPA\'s TKIP encryption has known vulnerabilities and is considered deprecated since 2012.',
          severity: Severity.high,
          attackVector:
              'TKIP has known weaknesses. WPA handshakes are vulnerable to offline dictionary attacks if a weak password is used.',
          mitigation:
              'Ask the network admin to upgrade to WPA3 or WPA2-AES. Avoid sensitive transactions on this network.',
        ));
        break;

      case SecurityType.wpa2:
        factors.add(const RiskFactor(
          id: 'wpa2_standard',
          title: 'WPA2 Encryption',
          description:
              'WPA2 is the current standard. It\'s generally secure but vulnerable to KRACK attacks on unpatched devices.',
          severity: Severity.low,
          attackVector:
              'The 2017 KRACK vulnerability can allow decryption of WPA2 traffic on unpatched devices. Weak passwords remain a risk via offline dictionary attacks.',
          mitigation:
              'Keep your device OS updated. Use a strong, unique password. Consider WPA3 for maximum security.',
        ));
        break;

      case SecurityType.wpa2wpa3:
        factors.add(const RiskFactor(
          id: 'mixed_mode',
          title: 'Mixed WPA2/WPA3 Mode',
          description:
              'The network supports both WPA2 and WPA3. Your connection strength depends on what your device negotiates.',
          severity: Severity.low,
          attackVector:
              'Older devices fall back to WPA2. Some implementations are vulnerable to downgrade attacks that force WPA2 negotiation.',
          mitigation:
              'Update your device to ensure WPA3 is used. WPA3-capable devices are well protected on this network.',
        ));
        break;

      case SecurityType.wpa3:
        factors.add(const RiskFactor(
          id: 'wpa3_secure',
          title: 'WPA3 Encryption',
          description:
              'WPA3 uses SAE (Dragonfly handshake) which protects against offline dictionary attacks. This is the strongest Wi-Fi security available.',
          severity: Severity.info,
          attackVector:
              'No practical attacks on WPA3 are currently known. SAE prevents password guessing even if traffic is captured.',
          mitigation:
              'No action needed. Keep your device firmware updated to maintain this security level.',
        ));
        break;

      case SecurityType.unknown:
        factors.add(const RiskFactor(
          id: 'unknown_security',
          title: 'Unknown Security Type',
          description:
              'The security configuration of this network could not be determined from broadcast data.',
          severity: Severity.medium,
          attackVector:
              'Without knowing the encryption type, specific attack vectors cannot be assessed. Treat as potentially insecure.',
          mitigation: 'Exercise caution. Verify the network security with the owner before connecting.',
        ));
        break;
    }

    if (isDuplicate) {
      factors.add(const RiskFactor(
        id: 'evil_twin',
        title: 'Possible Evil Twin Attack',
        description:
            'Multiple access points share the same network name. This is a classic indicator of a rogue AP attack.',
        severity: Severity.high,
        attackVector:
            'An attacker sets up a fake AP cloning a legitimate network name. When you connect, all traffic passes through them — credential harvesting, injection attacks, and traffic manipulation are all possible.',
        mitigation:
            'Verify the correct BSSID (MAC address) with the network owner. Never connect to a duplicate SSID on a public network without verification.',
      ));
    }

    if (rssi < -80) {
      factors.add(const RiskFactor(
        id: 'weak_signal',
        title: 'Very Weak Signal',
        description:
            'The signal is very weak, which may indicate the AP is far away or something is interfering.',
        severity: Severity.info,
        attackVector:
            'A weak legitimate signal can cause your device to prefer nearby rogue APs broadcasting a stronger signal.',
        mitigation:
            'Move closer to the access point. Very weak connections are unreliable and may cause reconnection attempts.',
      ));
    }

    return factors;
  }

  // ─── Main analysis entry point ─────────────────────────────────────────────

  static WifiNetwork analyzeNetwork({
    required String ssid,
    required String bssid,
    required int rssi,
    required int frequency,
    required String capabilities,
    required List<(String, String)> allNetworks, // (ssid, bssid) pairs
  }) {
    final securityType = parseSecurityType(capabilities);
    final isDuplicate = allNetworks.where((n) => n.$1 == ssid).length > 1;

    final riskFactors = generateRiskFactors(
      securityType: securityType,
      isDuplicate: isDuplicate,
      rssi: rssi,
      ssid: ssid,
    );

    final score = calculateSecurityScore(
      securityType: securityType,
      isDuplicate: isDuplicate,
      rssi: rssi,
      ssid: ssid,
    );

    return WifiNetwork(
      ssid: ssid.isEmpty ? '' : ssid,
      bssid: bssid,
      rssi: rssi,
      frequency: frequency,
      capabilities: capabilities,
      securityType: securityType,
      securityScore: score,
      riskLevel: determineRiskLevel(score),
      riskFactors: riskFactors,
      channel: frequencyToChannel(frequency),
      isDuplicateSsid: isDuplicate,
    );
  }
}
