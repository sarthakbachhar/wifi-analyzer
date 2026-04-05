import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wifi_network.dart';
import '../providers/wifi_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/network_card.dart';

class ScannerScreen extends StatefulWidget {
  final VoidCallback onNetworkSelected;

  const ScannerScreen({super.key, required this.onNetworkSelected});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WifiProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App bar ──────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.surface,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cyan.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.wifi_find_rounded, color: AppColors.cyan, size: 18),
                ),
                const SizedBox(width: 10),
                const Text('Wi-Fi Auditor'),
              ],
            ),
            actions: [
              if (provider.status == ScanStatus.done && provider.networks.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
                  onPressed: provider.isScanning ? null : provider.startScan,
                  tooltip: 'Rescan',
                ),
              const SizedBox(width: 4),
            ],
          ),

          // ── Body ─────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.only(top: 20, bottom: 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Summary strip ─────────────────────────────────────────
                if (provider.status == ScanStatus.done && provider.networks.isNotEmpty) ...[
                  _SummaryRow(
                    networks: provider.networks,
                    threatCount: provider.threatCount,
                    warningCount: provider.warningCount,
                    secureCount: provider.secureCount,
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Scan button ───────────────────────────────────────────
                _ScanButton(
                  isScanning: provider.isScanning,
                  hasDoneOnce: provider.status == ScanStatus.done,
                  animation: _pulseAnimation,
                  onScan: provider.requestPermissionAndScan,
                ),

                const SizedBox(height: 28),

                // ── Status / error ────────────────────────────────────────
                if (provider.status == ScanStatus.error)
                  _ErrorCard(
                    error: provider.error ?? 'Unknown error',
                    isPermanent: provider.permissionPermanentlyDenied,
                    onRetry: provider.requestPermissionAndScan,
                  ),

                // ── Network list ──────────────────────────────────────────
                if (provider.networks.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Text(
                          'Nearby Networks',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.cyan.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${provider.networks.length}',
                            style: const TextStyle(
                              color: AppColors.cyan,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...provider.networks.map((n) => NetworkCard(
                        network: n,
                        onTap: () {
                          context.read<WifiProvider>().selectNetwork(n);
                          widget.onNetworkSelected();
                        },
                      )),
                ],

                // ── Idle / scanning placeholder ───────────────────────────
                if (provider.networks.isEmpty && provider.status != ScanStatus.error)
                  _IdlePlaceholder(isScanning: provider.isScanning),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final List<WifiNetwork> networks;
  final int threatCount;
  final int warningCount;
  final int secureCount;

  const _SummaryRow({
    required this.networks,
    required this.threatCount,
    required this.warningCount,
    required this.secureCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _Stat(label: 'Threats', value: threatCount, color: AppColors.critical),
          _Divider(),
          _Stat(label: 'Warnings', value: warningCount, color: AppColors.medium),
          _Divider(),
          _Stat(label: 'Safe', value: secureCount, color: AppColors.secure),
          _Divider(),
          _Stat(label: 'Total', value: networks.length, color: AppColors.cyan),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _Stat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1, height: 32, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 4));
}

class _ScanButton extends StatelessWidget {
  final bool isScanning;
  final bool hasDoneOnce;
  final Animation<double> animation;
  final VoidCallback onScan;

  const _ScanButton({
    required this.isScanning,
    required this.hasDoneOnce,
    required this.animation,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) => Transform.scale(
          scale: isScanning ? 1.0 : animation.value,
          child: child,
        ),
        child: GestureDetector(
          onTap: isScanning ? null : onScan,
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              gradient: isScanning
                  ? null
                  : LinearGradient(
                      colors: [AppColors.cyan, AppColors.cyanDim],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
              color: isScanning ? AppColors.card : null,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isScanning ? AppColors.border : AppColors.cyan.withOpacity(0.5),
              ),
              boxShadow: isScanning
                  ? null
                  : [BoxShadow(color: AppColors.cyan.withOpacity(0.3), blurRadius: 20, spreadRadius: 0)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isScanning)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppColors.cyan),
                    ),
                  )
                else
                  const Icon(Icons.radar_rounded, color: AppColors.background, size: 22),
                const SizedBox(width: 10),
                Text(
                  isScanning
                      ? 'Scanning...'
                      : hasDoneOnce
                          ? 'Scan Again'
                          : 'Start Scan',
                  style: TextStyle(
                    color: isScanning ? AppColors.textSecondary : AppColors.background,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String error;
  final bool isPermanent;
  final VoidCallback onRetry;

  const _ErrorCard({required this.error, required this.isPermanent, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.critical.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.critical.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.critical, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(error,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
          if (!isPermanent) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry', style: TextStyle(color: AppColors.cyan, fontSize: 13)),
            ),
          ],
        ],
      ),
    );
  }
}

class _IdlePlaceholder extends StatelessWidget {
  final bool isScanning;

  const _IdlePlaceholder({required this.isScanning});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      child: Column(
        children: [
          Icon(
            isScanning ? Icons.wifi_find_rounded : Icons.wifi_rounded,
            size: 64,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            isScanning ? 'Scanning nearby networks...' : 'Tap Scan to analyze\nnearby Wi-Fi networks',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
