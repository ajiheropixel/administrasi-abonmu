import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'dashboard/dashboard_screen.dart';
import 'products/product_list_screen.dart';
import 'productions/production_list_screen.dart';
import 'sales/sale_list_screen.dart';
import 'expenses/expense_list_screen.dart';
import 'customers/customer_list_screen.dart';
import 'employees/employee_list_screen.dart';
import 'reports/report_screen.dart';
import '../widgets/app_confirm_dialog.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Dashboard'),
    _NavItem(icon: Icons.factory_outlined, activeIcon: Icons.factory, label: 'Produksi'),
    _NavItem(icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2, label: 'Produk'),
    _NavItem(icon: Icons.shopping_cart_outlined, activeIcon: Icons.shopping_cart, label: 'Penjualan'),
    _NavItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, label: 'Pengeluaran'),
    _NavItem(icon: Icons.people_outline, activeIcon: Icons.people, label: 'Pelanggan'),
    _NavItem(icon: Icons.badge_outlined, activeIcon: Icons.badge, label: 'Karyawan'),
    _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'Laporan'),
  ];

  final List<Widget> _screens = const [
    DashboardScreen(),
    ProductionListScreen(),
    ProductListScreen(),
    SaleListScreen(),
    ExpenseListScreen(),
    CustomerListScreen(),
    EmployeeListScreen(),
    ReportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 768;

    if (isWide) {
      // Tablet/Desktop: sidebar layout
      return Scaffold(
        body: Row(
          children: [
            _Sidebar(
              currentIndex: _currentIndex,
              navItems: _navItems,
              onTap: (i) => setState(() => _currentIndex = i),
            ),
            Expanded(
              child: _screens[_currentIndex],
            ),
          ],
        ),
      );
    }

    // Mobile: bottom nav
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    // Show only first 5 items in bottom nav, rest in drawer
    final visibleItems = _navItems.take(5).toList();
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.sidebarDark,
        border: Border(top: BorderSide(color: AppColors.sidebarBorder)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              ...visibleItems.asMap().entries.map((e) {
                final i = e.key;
                final item = e.value;
                final selected = _currentIndex == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _currentIndex = i),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          selected ? item.activeIcon : item.icon,
                          size: 22,
                          color: selected ? Colors.white : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            color: selected ? Colors.white : const Color(0xFF94A3B8),
                            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              // More button
              Expanded(
                child: GestureDetector(
                  onTap: () => _showMoreDrawer(context),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.menu,
                        size: 22,
                        color: _currentIndex >= 5
                            ? Colors.white
                            : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Menu',
                        style: TextStyle(
                          fontSize: 10,
                          color: _currentIndex >= 5
                              ? Colors.white
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMoreDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.sidebarDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _MoreDrawer(
        navItems: _navItems,
        currentIndex: _currentIndex,
        onTap: (i) {
          Navigator.pop(context);
          setState(() => _currentIndex = i);
        },
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}

// Sidebar untuk tablet/desktop
class _Sidebar extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> navItems;
  final ValueChanged<int> onTap;

  const _Sidebar({
    required this.currentIndex,
    required this.navItems,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.sidebarDark, AppColors.sidebarDeep],
        ),
      ),
      child: Column(
        children: [
          // Logo area
          Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.sidebarBorder)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 10),
                const Text('Rumah Produksi Abon',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                const Text('Sistem Administrasi',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
              ],
            ),
          ),
          // Nav items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: navItems.asMap().entries.map((e) {
                final i = e.key;
                final item = e.value;
                final selected = currentIndex == i;
                return _SidebarItem(
                  icon: selected ? item.activeIcon : item.icon,
                  label: item.label,
                  selected: selected,
                  onTap: () => onTap(i),
                );
              }).toList(),
            ),
          ),
          // User info + logout
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.sidebarBorder)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        child: Text(
                          (auth.user?.name ?? 'U').substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(auth.user?.name ?? '-',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(auth.user?.role ?? '-',
                                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _SidebarItem(
                  icon: Icons.logout,
                  label: 'Logout',
                  selected: false,
                  isLogout: true,
                  onTap: () async {
                    final ok = await showConfirmDialog(context,
                        title: 'Keluar', message: 'Yakin ingin keluar?', confirmLabel: 'Keluar');
                    if (ok && context.mounted) context.read<AuthProvider>().logout();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool isLogout;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.sidebarHover
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18,
                color: isLogout
                    ? const Color(0xFFF87171)
                    : selected ? Colors.white : const Color(0xFFCBD5E1)),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(
                  fontSize: 13,
                  color: isLogout
                      ? const Color(0xFFF87171)
                      : selected ? Colors.white : const Color(0xFFCBD5E1),
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                )),
          ],
        ),
      ),
    );
  }
}

// Bottom sheet untuk menu tambahan di mobile
class _MoreDrawer extends StatelessWidget {
  final List<_NavItem> navItems;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _MoreDrawer({required this.navItems, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // User info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.sidebarHover,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(
                    (auth.user?.name ?? 'U').substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(auth.user?.name ?? '-',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(auth.user?.role ?? '-',
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Menu items 5-7
          ...navItems.asMap().entries.skip(5).map((e) {
            final i = e.key;
            final item = e.value;
            return ListTile(
              leading: Icon(item.icon, color: const Color(0xFFCBD5E1), size: 20),
              title: Text(item.label,
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
              selected: currentIndex == i,
              selectedTileColor: AppColors.sidebarHover,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onTap: () => onTap(i),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            );
          }),
          const Divider(color: AppColors.sidebarBorder),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFFF87171), size: 20),
            title: const Text('Logout', style: TextStyle(color: Color(0xFFF87171), fontSize: 14)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            onTap: () async {
              Navigator.pop(context);
              final ok = await showConfirmDialog(context,
                  title: 'Keluar', message: 'Yakin ingin keluar?', confirmLabel: 'Keluar');
              if (ok && context.mounted) context.read<AuthProvider>().logout();
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
