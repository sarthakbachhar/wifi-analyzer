import 'dart:math';

enum SecurityType {
  open,
  wep,
  wpa,
  wpa2,
  wpa2wpa3,
  wpa3,
  unknown;

  String get label {
    switch (this) {
      case SecurityType.open:
        return 'Open';
      case SecurityType.wep:
        return 'WEP';
      case SecurityType.wpa:
        return 'WPA';
      case SecurityType.wpa2:
        return 'WPA2';
      case SecurityType.wpa2wpa3:
        return 'WPA2/3';
      case SecurityType.wpa3:
        return 'WPA3';
      case SecurityType.unknown:
        return 'Unknown';
    }
  }
}

enum RiskLevel {
  critical,
  high,
  medium,
  low,
  secure,
  unknown;

  String get label {
    switch (this) {
      case RiskLevel.critical:
        return 'Critical';
      case RiskLevel.high:
        return 'High Risk';
      case RiskLevel.medium:
        return 'Medium Risk';
      case RiskLevel.low:
        return 'Low Risk';
      case RiskLevel.secure:
        return 'Secure';
      case RiskLevel.unknown:
        return 'Unknown';
    }
  }

  String get shortLabel {
    switch (this) {
      case RiskLevel.critical:
        return 'CRITICAL';
      case RiskLevel.high:
        return 'HIGH';
      case RiskLevel.medium:
        return 'MEDIUM';
      case RiskLevel.low:
        return 'LOW';
      case RiskLevel.secure:
        return 'SECURE';
      case RiskLevel.unknown:
        return 'UNKNOWN';
    }
  }
}

enum Severity { info, low, medium, high, critical }

class RiskFactor {
  final String id;
  final String title;
  final String description;
  final Severity severity;
  final String attackVector;
  final String mitigation;

  const RiskFactor({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.attackVector,
    required this.mitigation,
  });
}

class WifiNetwork {
  final String ssid;
  final String bssid;
  final int rssi;
  final int frequency;
  final String capabilities;
  final SecurityType securityType;
  final int securityScore;
  final RiskLevel riskLevel;
  final List<RiskFactor> riskFactors;
  final int channel;
  final bool isDuplicateSsid;
  final DateTime timestamp;

  WifiNetwork({
    required this.ssid,
    required this.bssid,
    required this.rssi,
    required this.frequency,
    required this.capabilities,
    required this.securityType,
    required this.securityScore,
    required this.riskLevel,
    required this.riskFactors,
    required this.channel,
    this.isDuplicateSsid = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  String get displaySsid => ssid.isEmpty ? '<Hidden Network>' : ssid;

  String get signalQuality {
    if (rssi >= -50) return 'Excellent';
    if (rssi >= -60) return 'Good';
    if (rssi >= -70) return 'Fair';
    if (rssi >= -80) return 'Weak';
    return 'Very Weak';
  }

  double get signalPercent => ((rssi + 100) / 60).clamp(0.0, 1.0);

  String get frequencyBand {
    if (frequency < 3000) return '2.4 GHz';
    if (frequency < 6000) return '5 GHz';
    return '6 GHz';
  }
}

int frequencyToChannel(int frequency) {
  if (frequency >= 2412 && frequency <= 2484) {
    return (frequency - 2412) ~/ 5 + 1;
  }
  if (frequency >= 5170 && frequency <= 5825) {
    return (frequency - 5000) ~/ 5;
  }
  if (frequency >= 5925 && frequency <= 7125) {
    return (frequency - 5925) ~/ 5 + 1;
  }
  return 0;
}
