import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';

import '../analysis/security_analyzer.dart';
import '../models/wifi_network.dart';

enum ScanStatus { idle, requesting, scanning, done, error }

class WifiProvider extends ChangeNotifier {
  List<WifiNetwork> _networks = [];
  ScanStatus _status = ScanStatus.idle;
  String? _error;
  WifiNetwork? _selectedNetwork;
  DateTime? _lastScanTime;
  bool _permissionDenied = false;
  bool _permissionPermanentlyDenied = false;

  // ─── Getters ───────────────────────────────────────────────────────────────

  List<WifiNetwork> get networks => _networks;
  ScanStatus get status => _status;
  String? get error => _error;
  WifiNetwork? get selectedNetwork => _selectedNetwork;
  DateTime? get lastScanTime => _lastScanTime;
  bool get permissionDenied => _permissionDenied;
  bool get permissionPermanentlyDenied => _permissionPermanentlyDenied;
  bool get isScanning => _status == ScanStatus.scanning || _status == ScanStatus.requesting;

  int get criticalCount => _networks.where((n) => n.riskLevel == RiskLevel.critical).length;
  int get highCount => _networks.where((n) => n.riskLevel == RiskLevel.high).length;
  int get threatCount => criticalCount + highCount;
  int get warningCount => _networks.where((n) => n.riskLevel == RiskLevel.medium).length;
  int get secureCount =>
      _networks.where((n) => n.riskLevel == RiskLevel.secure || n.riskLevel == RiskLevel.low).length;

  // ─── Permission handling ───────────────────────────────────────────────────

  Future<void> requestPermissionAndScan() async {
    _status = ScanStatus.requesting;
    _error = null;
    _permissionDenied = false;
    _permissionPermanentlyDenied = false;
    notifyListeners();

    final status = await Permission.locationWhenInUse.request();

    if (status.isGranted) {
      await _performScan();
    } else if (status.isPermanentlyDenied) {
      _permissionPermanentlyDenied = true;
      _status = ScanStatus.error;
      _error = 'Location permission permanently denied. Please enable it in app Settings.';
      notifyListeners();
    } else {
      _permissionDenied = true;
      _status = ScanStatus.error;
      _error = 'Location permission is required to scan Wi-Fi networks.';
      notifyListeners();
    }
  }

  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  // ─── Scanning ─────────────────────────────────────────────────────────────

  Future<void> startScan() async {
    final permStatus = await Permission.locationWhenInUse.status;
    if (!permStatus.isGranted) {
      await requestPermissionAndScan();
      return;
    }
    await _performScan();
  }

  Future<void> _performScan() async {
    _status = ScanStatus.scanning;
    _error = null;
    notifyListeners();

    try {
      // Try to trigger a fresh scan (may be throttled on Android 9+)
      final canScan = await WiFiScan.instance.canStartScan(askPermissions: false);
      if (canScan == CanStartScan.yes) {
        await WiFiScan.instance.startScan();
        // Small delay to allow scan results to populate
        await Future.delayed(const Duration(milliseconds: 800));
      }

      await _loadResults();
    } catch (e) {
      _status = ScanStatus.error;
      _error = 'Scan failed: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> _loadResults() async {
    try {
      final canGet = await WiFiScan.instance.canGetScannedResults(askPermissions: false);
      if (canGet != CanGetScannedResults.yes) {
        _status = ScanStatus.error;
        _error = _canGetResultsError(canGet);
        notifyListeners();
        return;
      }

      final raw = await WiFiScan.instance.getScannedResults();

      // Build (ssid, bssid) pairs for duplicate detection
      final pairs = raw.map((r) => (r.ssid, r.bssid)).toList();

      final analyzed = raw.map((r) => SecurityAnalyzer.analyzeNetwork(
            ssid: r.ssid,
            bssid: r.bssid,
            rssi: r.level,
            frequency: r.frequency,
            capabilities: r.capabilities,
            allNetworks: pairs,
          ));

      _networks = analyzed.toList()
        ..sort((a, b) => a.securityScore.compareTo(b.securityScore)); // most dangerous first

      _lastScanTime = DateTime.now();
      _status = ScanStatus.done;
    } catch (e) {
      _status = ScanStatus.error;
      _error = 'Could not read scan results: ${e.toString()}';
    }
    notifyListeners();
  }

  String _canGetResultsError(CanGetScannedResults reason) {
    switch (reason) {
      case CanGetScannedResults.noLocationPermissionRequired:
      case CanGetScannedResults.noLocationPermissionDenied:
        return 'Location permission is required to read Wi-Fi scan results.';
      case CanGetScannedResults.noLocationServiceDisabled:
        return 'Location services are disabled. Please enable them in Settings.';
      default:
        return 'Cannot retrieve scan results on this device.';
    }
  }

  // ─── Network selection ────────────────────────────────────────────────────

  void selectNetwork(WifiNetwork network) {
    _selectedNetwork = network;
    notifyListeners();
  }

  void clearSelectedNetwork() {
    _selectedNetwork = null;
    notifyListeners();
  }
}
