import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wifi_provider.dart';
import '../screens/education_screen.dart';
import '../screens/network_detail_screen.dart';
import '../screens/scanner_screen.dart';
import '../theme/app_theme.dart';

class AppNavigation extends StatefulWidget {
  const AppNavigation({super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int _selectedIndex = 0;
  bool _showDetail = false;

  void _onNetworkSelected() {
    setState(() => _showDetail = true);
  }

  void _onDetailBack() {
    context.read<WifiProvider>().clearSelectedNetwork();
    setState(() => _showDetail = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WifiProvider>();

    // Full-screen detail overlay
    if (_showDetail && provider.selectedNetwork != null) {
      return NetworkDetailScreen(
        network: provider.selectedNetwork!,
        onBack: _onDetailBack,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          ScannerScreen(onNetworkSelected: _onNetworkSelected),
          const EducationScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.card,
        elevation: 0,
        height: 64,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.wifi_find_rounded),
            selectedIcon: Icon(Icons.wifi_find_rounded),
            label: 'Scanner',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school_rounded),
            label: 'Learn',
          ),
        ],
      ),
    );
  }
}
