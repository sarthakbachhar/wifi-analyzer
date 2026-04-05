import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.surface,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.purple.withOpacity(0.4)),
                  ),
                  child: const Icon(Icons.school_rounded, color: AppColors.purple, size: 18),
                ),
                const SizedBox(width: 10),
                const Text('Learn'),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Threats section ───────────────────────────────────────
                const _SectionHeader('Common Wi-Fi Threats'),
                ..._threats.map((t) => _ThreatCard(threat: t)),

                // ── Safe practices ────────────────────────────────────────
                const _SectionHeader('How to Stay Safe'),
                const _SafePracticesCard(),

                // ── Encryption guide ──────────────────────────────────────
                const _SectionHeader('Encryption Standards'),
                const _EncryptionGuideCard(),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Threat data ──────────────────────────────────────────────────────────────

class _ThreatData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String overview;
  final String howItWorks;
  final String prevention;

  const _ThreatData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.overview,
    required this.howItWorks,
    required this.prevention,
  });
}

const _threats = [
  _ThreatData(
    title: 'Open Networks',
    subtitle: 'No encryption — all traffic visible',
    icon: Icons.lock_open_rounded,
    color: AppColors.critical,
    overview:
        'Open Wi-Fi networks transmit all data without any encryption. Every byte you send or receive — passwords, emails, browsing history — is visible to anyone within range using basic tools.',
    howItWorks:
        'An attacker connects to the same open network (or just places a wireless card nearby in monitor mode). Using free tools like Wireshark, they can see all unencrypted traffic in real time — including HTTP form submissions, cookies, and credentials.',
    prevention:
        'Always use a VPN on open networks. Only visit HTTPS websites. Never log into banking, email, or sensitive accounts on open Wi-Fi. If you see your phone auto-connect to a familiar open network — reconnect manually after verifying.',
  ),
  _ThreatData(
    title: 'Man-in-the-Middle (MITM)',
    subtitle: 'Attackers intercept your traffic',
    icon: Icons.compare_arrows_rounded,
    color: AppColors.high,
    overview:
        'A MITM attack positions an attacker invisibly between your device and the network gateway. All your communication passes through them, allowing silent interception and optional modification.',
    howItWorks:
        'On open or weakly secured networks, the attacker uses ARP poisoning to redirect your traffic through their machine. They can read plaintext data, inject malicious code into web pages, or strip HTTPS downgrade your connections.',
    prevention:
        'Use a VPN (encrypts end-to-end). Verify SSL certificates. Enable HSTS in your browser. Watch for certificate warnings — never click "proceed anyway" on public Wi-Fi.',
  ),
  _ThreatData(
    title: 'Evil Twin / Rogue AP',
    subtitle: 'Fake networks mimicking real ones',
    icon: Icons.wifi_tethering_rounded,
    color: AppColors.high,
    overview:
        'An attacker creates a fake access point that looks identical to a legitimate network — same SSID (name), sometimes the same BSSID. Your device may automatically connect to it.',
    howItWorks:
        'The attacker broadcasts a stronger signal using the same SSID as a nearby trusted network. Phones prioritize signal strength, so they connect to the rogue AP. The attacker then proxies your internet traffic, capturing everything.',
    prevention:
        'Verify the BSSID (MAC address) with network staff before connecting. Disable auto-connect for public networks. This app flags multiple APs sharing the same name. Use a VPN on all public networks.',
  ),
  _ThreatData(
    title: 'WEP Vulnerabilities',
    subtitle: 'Cryptographically broken since 2001',
    icon: Icons.broken_image_rounded,
    color: AppColors.critical,
    overview:
        'WEP (Wired Equivalent Privacy) uses RC4 encryption with a fundamental flaw in how it generates initialization vectors (IVs). It can be cracked in under 2 minutes with modern hardware.',
    howItWorks:
        'Tools like aircrack-ng passively collect 5,000–40,000 data packets from the network. By analyzing the weak IVs, they can statistically recover the full WEP key without ever needing to brute-force it.',
    prevention:
        'Never use WEP-protected networks for anything sensitive. If you manage a network, upgrade to WPA3 immediately. WEP provides essentially zero real-world security.',
  ),
  _ThreatData(
    title: 'KRACK Attack (WPA2)',
    subtitle: 'Key reinstallation vulnerability',
    icon: Icons.replay_rounded,
    color: AppColors.medium,
    overview:
        'KRACK (Key Reinstallation Attack), disclosed in 2017, is a vulnerability in the WPA2 four-way handshake that can allow an attacker to decrypt and replay traffic on WPA2 networks.',
    howItWorks:
        'By manipulating and replaying cryptographic handshake messages, attackers force nonce reuse on the victim\'s device. This breaks the encryption, potentially allowing traffic decryption and injection on unpatched devices.',
    prevention:
        'Keep all devices updated — most vendors patched KRACK within weeks of disclosure. A fully patched device is not vulnerable. Use HTTPS/TLS regardless, which adds another layer of protection.',
  ),
  _ThreatData(
    title: 'Deauthentication Attacks',
    subtitle: 'Forcing devices off networks',
    icon: Icons.wifi_off_rounded,
    color: AppColors.medium,
    overview:
        'Wi-Fi 802.11 deauthentication frames are unauthenticated in WPA2. An attacker can send forged deauth frames to force any device off a network, then capture the reconnection handshake.',
    howItWorks:
        'The attacker sends deauth frames spoofed as the access point, knocking your device off the network. As it reconnects, they capture the WPA2 four-way handshake, which can then be cracked offline using dictionary attacks.',
    prevention:
        'WPA3 uses Protected Management Frames (PMF) which prevents this attack. On WPA2, use strong unique passwords that resist dictionary attacks. Update to WPA3 when possible.',
  ),
];

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _ThreatCard extends StatefulWidget {
  final _ThreatData threat;

  const _ThreatCard({required this.threat});

  @override
  State<_ThreatCard> createState() => _ThreatCardState();
}

class _ThreatCardState extends State<_ThreatCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.threat;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: t.color.withOpacity(_expanded ? 0.3 : 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: t.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(t.icon, color: t.color, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t.subtitle,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
            if (_expanded) ...[
              Container(height: 1, color: AppColors.border),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LearnSection(label: 'Overview', text: t.overview, color: AppColors.info),
                    const SizedBox(height: 14),
                    _LearnSection(
                        label: 'How Attackers Exploit It', text: t.howItWorks, color: AppColors.high),
                    const SizedBox(height: 14),
                    _LearnSection(label: 'How to Stay Safe', text: t.prevention, color: AppColors.secure),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LearnSection extends StatelessWidget {
  final String label;
  final String text;
  final Color color;

  const _LearnSection({required this.label, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.6),
        ),
      ],
    );
  }
}

class _SafePracticesCard extends StatelessWidget {
  const _SafePracticesCard();

  static const _practices = [
    (Icons.vpn_key_rounded, AppColors.cyan, 'Use a VPN',
        'Always enable a VPN before connecting to any public or unknown network. It encrypts all traffic end-to-end.'),
    (Icons.verified_rounded, AppColors.secure, 'Verify Networks',
        'Confirm the SSID and BSSID (MAC address) with staff before joining hotel, café, or airport Wi-Fi.'),
    (Icons.https_rounded, AppColors.low, 'HTTPS Only',
        'Only submit information on sites with HTTPS (padlock icon). Never ignore certificate warnings.'),
    (Icons.system_update_rounded, AppColors.medium, 'Keep Devices Updated',
        'Security patches protect against known attacks like KRACK. Enable automatic updates on all devices.'),
    (Icons.wifi_off_rounded, AppColors.textSecondary, 'Forget Public Networks',
        'After using public Wi-Fi, forget the network. This prevents auto-reconnect to networks that may have rogue twins.'),
    (Icons.phonelink_lock_rounded, AppColors.purple, 'Enable MFA',
        'Multi-factor authentication means stolen credentials alone are not enough to access your accounts.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: _practices.asMap().entries.map((e) {
          final i = e.key;
          final (icon, color, title, desc) = e.value;
          return Column(
            children: [
              if (i > 0) const Divider(height: 1, color: AppColors.border, indent: 58),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: color, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 3),
                          Text(desc,
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 12, height: 1.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _EncryptionGuideCard extends StatelessWidget {
  const _EncryptionGuideCard();

  static const _standards = [
    ('Open', 'None', AppColors.critical, 'Avoid entirely'),
    ('WEP', 'RC4 (broken)', AppColors.critical, 'Treat as open'),
    ('WPA', 'TKIP (weak)', AppColors.high, 'Upgrade needed'),
    ('WPA2', 'AES-CCMP', AppColors.medium, 'Generally OK'),
    ('WPA3', 'SAE + AES', AppColors.secure, 'Best available'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header row
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text('Standard',
                        style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5))),
                Expanded(
                    flex: 3,
                    child: Text('Encryption',
                        style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600))),
                Expanded(
                    flex: 3,
                    child: Text('Verdict',
                        style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          ..._standards.map(
            (s) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: Text(s.$1,
                              style: TextStyle(
                                  color: s.$3, fontSize: 13, fontWeight: FontWeight.w700))),
                      Expanded(
                          flex: 3,
                          child: Text(s.$2,
                              style:
                                  const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
                      Expanded(
                          flex: 3,
                          child: Text(s.$4,
                              style: TextStyle(color: s.$3, fontSize: 12, fontWeight: FontWeight.w500))),
                    ],
                  ),
                ),
                if (s.$1 != 'WPA3')
                  const Divider(height: 1, color: AppColors.border, indent: 16, endIndent: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
