import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/nav_tab_provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../devices/devices_screen.dart';
import '../profile/profile_screen.dart';

/// Khung chinh cua khu vuc da dang nhap: bottom navigation voi 3 tab.
/// Dung IndexedStack de giu nguyen trang thai (scroll position, du lieu
/// da tai) cua tung tab khi chuyen qua lai, thay vi dung nested route cua
/// GoRouter - don gian hoa dieu huong vi app chi co 3 tab co dinh.
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  static const _screens = [
    DashboardScreen(),
    DevicesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navTab = context.watch<NavTabProvider>();

    return Scaffold(
      body: IndexedStack(index: navTab.index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navTab.index,
        onDestinationSelected: (index) => context.read<NavTabProvider>().setIndex(index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Tong quan',
          ),
          NavigationDestination(
            icon: Icon(Icons.developer_board_outlined),
            selectedIcon: Icon(Icons.developer_board),
            label: 'Thiet bi',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Ca nhan',
          ),
        ],
      ),
    );
  }
}
