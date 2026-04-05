import 'package:flutter/material.dart';
import '../models/wifi_network.dart';
import '../theme/app_theme.dart';
import 'security_badge.dart';
import 'signal_bar.dart';

class NetworkCard extends StatelessWidget {
  final WifiNetwork network;
  final VoidCallback onTap;

  const NetworkCard({super.key, required this.network, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final riskColor = riskLevelColor(network.riskLevel);
    final score = network.securityScore;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: riskColor.withOpacity(0.25), width: 1),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left color stripe
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: riskColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: SSID + Score circle
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              network.displaySsid,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _ScoreCircle(score: score, color: riskColor),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Row 2: Badges + signal
                      Row(
                        children: [
                          SecurityBadge(type: network.securityType, small: true),
                          const SizedBox(width: 6),
                          RiskLevelBadge(level: network.riskLevel, small: true),
                          if (network.isDuplicateSsid) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.high.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.high.withOpacity(0.5)),
                              ),
                              child: const Text(
                                'TWIN',
                                style: TextStyle(
                                  color: AppColors.high,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          SignalBar(rssi: network.rssi),
                          const SizedBox(width: 6),
                          Text(
                            '${network.rssi} dBm',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Row 3: BSSID + channel
                      Row(
                        children: [
                          Text(
                            network.bssid.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${network.frequencyBand}  Ch ${network.channel}',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Arrow
              const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreCircle extends StatelessWidget {
  final int score;
  final Color color;

  const _ScoreCircle({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        score.toString(),
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
