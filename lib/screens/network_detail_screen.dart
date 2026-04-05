import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/wifi_network.dart';
import '../theme/app_theme.dart';
import '../widgets/risk_gauge.dart';
import '../widgets/security_badge.dart';
import '../widgets/signal_bar.dart';

class NetworkDetailScreen extends StatelessWidget {
  final WifiNetwork network;
  final VoidCallback onBack;

  const NetworkDetailScreen({super.key, required this.network, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final riskColor = riskLevelColor(network.riskLevel);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App bar ──────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textSecondary),
              onPressed: onBack,
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  network.displaySsid,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Network Analysis',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.only(bottom: 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Risk gauge ────────────────────────────────────────────
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: riskColor.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      RiskGauge(score: network.securityScore, size: 170),
                      const SizedBox(height: 12),
                      RiskLevelBadge(level: network.riskLevel),
                      const SizedBox(height: 6),
                      const Text(
                        'Security Score',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // ── Network info ──────────────────────────────────────────
                const _SectionHeader('Network Information'),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.wifi_rounded,
                        label: 'Network Name',
                        value: network.displaySsid,
                      ),
                      _Divider(),
                      _InfoRow(
                        icon: Icons.router_rounded,
                        label: 'BSSID (MAC)',
                        value: network.bssid.toUpperCase(),
                        monospace: true,
                        copyable: true,
                      ),
                      _Divider(),
                      _InfoRow(
                        icon: Icons.lock_rounded,
                        label: 'Security',
                        valueWidget: SecurityBadge(type: network.securityType),
                      ),
                      _Divider(),
                      _InfoRow(
                        icon: Icons.signal_cellular_alt_rounded,
                        label: 'Signal Strength',
                        value: '${network.rssi} dBm — ${network.signalQuality}',
                        valueWidget: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${network.rssi} dBm  ${network.signalQuality}',
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                            ),
                            const SizedBox(width: 8),
                            SignalBar(rssi: network.rssi, maxHeight: 14),
                          ],
                        ),
                      ),
                      _Divider(),
                      _InfoRow(
                        icon: Icons.wifi_channel_rounded,
                        label: 'Channel',
                        value: 'Ch ${network.channel}  •  ${network.frequencyBand}',
                      ),
                      _Divider(),
                      _InfoRow(
                        icon: Icons.radio_rounded,
                        label: 'Frequency',
                        value: '${network.frequency} MHz',
                      ),
                      if (network.isDuplicateSsid) ...[
                        _Divider(),
                        _InfoRow(
                          icon: Icons.warning_amber_rounded,
                          label: 'Duplicate SSID',
                          value: 'Multiple APs with this name detected',
                          valueColor: AppColors.high,
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Risk analysis ─────────────────────────────────────────
                const _SectionHeader('Risk Analysis'),
                ...network.riskFactors.map(
                  (factor) => _RiskFactorCard(factor: factor),
                ),

                // ── Recommendations ───────────────────────────────────────
                if (network.riskFactors.isNotEmpty) ...[
                  const _SectionHeader('Recommendations'),
                  _RecommendationsCard(riskFactors: network.riskFactors),
                ],

                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Color? valueColor;
  final Widget? valueWidget;
  final bool monospace;
  final bool copyable;

  const _InfoRow({
    required this.icon,
    required this.label,
    this.value,
    this.valueColor,
    this.valueWidget,
    this.monospace = false,
    this.copyable = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget valueChild = valueWidget ??
        Text(
          value ?? '',
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimary,
            fontSize: 13,
            fontFamily: monospace ? 'monospace' : null,
          ),
        );

    if (copyable && value != null) {
      valueChild = GestureDetector(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: value!));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Copied to clipboard'),
              duration: Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: valueChild,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textMuted, size: 18),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const Spacer(),
          valueChild,
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, indent: 46, color: AppColors.border);
}

class _RiskFactorCard extends StatefulWidget {
  final RiskFactor factor;

  const _RiskFactorCard({required this.factor});

  @override
  State<_RiskFactorCard> createState() => _RiskFactorCardState();
}

class _RiskFactorCardState extends State<_RiskFactorCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final factor = widget.factor;
    final color = severityColor(factor.severity);

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  SeverityIcon(severity: factor.severity, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          factor.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          factor.description,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                          maxLines: _expanded ? 100 : 2,
                          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ],
              ),
            ),
            if (_expanded) ...[
              Container(height: 1, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 14)),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ExpandedSection(
                      icon: Icons.bug_report_outlined,
                      label: 'Attack Vector',
                      text: factor.attackVector,
                      color: AppColors.high,
                    ),
                    const SizedBox(height: 12),
                    _ExpandedSection(
                      icon: Icons.shield_outlined,
                      label: 'How to Protect Yourself',
                      text: factor.mitigation,
                      color: AppColors.secure,
                    ),
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

class _ExpandedSection extends StatelessWidget {
  final IconData icon;
  final String label;
  final String text;
  final Color color;

  const _ExpandedSection({
    required this.icon,
    required this.label,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          text,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.5),
        ),
      ],
    );
  }
}

class _RecommendationsCard extends StatelessWidget {
  final List<RiskFactor> riskFactors;

  const _RecommendationsCard({required this.riskFactors});

  List<String> get _tips {
    final tips = <String>[];
    for (final f in riskFactors) {
      tips.add(f.mitigation);
    }
    return tips;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secure.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secure.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_rounded, color: AppColors.secure, size: 18),
              SizedBox(width: 8),
              Text(
                'What to do',
                style: TextStyle(
                  color: AppColors.secure,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppColors.secure, fontSize: 13)),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
