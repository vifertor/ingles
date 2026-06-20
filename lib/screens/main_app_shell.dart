import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';
import 'dashboard_screen.dart';
import 'map_screen.dart';
import 'puzzles_screen.dart';
import 'ranking_screen.dart';
import 'profile_screen.dart';
import 'teacher_dashboard_screen.dart';
import 'teacher_students_screen.dart';

class MainAppShell extends StatefulWidget {
  final bool isTeacher;

  const MainAppShell({super.key, required this.isTeacher});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _navController;

  @override
  void initState() {
    super.initState();
    _navController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _navController.dispose();
    super.dispose();
  }

  List<Widget> get _studentScreens => [
        const DashboardScreen(),
        const MapScreen(),
        const PuzzlesScreen(),
        const RankingScreen(),
        ProfileScreen(user: MockData.currentUser),
      ];

  List<Widget> get _teacherScreens => [
        const TeacherDashboardScreen(),
        const TeacherStudentsScreen(),
        const PuzzlesScreen(),
        const RankingScreen(),
        ProfileScreen(user: MockData.teacherUser),
      ];

  List<BottomNavItem> get _studentNavItems => [
        BottomNavItem(icon: Icons.home_rounded, label: 'Home'),
        BottomNavItem(icon: Icons.map_rounded, label: 'Map'),
        BottomNavItem(icon: Icons.extension_rounded, label: 'Puzzles'),
        BottomNavItem(icon: Icons.leaderboard_rounded, label: 'Ranking'),
        BottomNavItem(icon: Icons.person_rounded, label: 'Profile'),
      ];

  List<BottomNavItem> get _teacherNavItems => [
        BottomNavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
        BottomNavItem(icon: Icons.people_rounded, label: 'Students'),
        BottomNavItem(icon: Icons.extension_rounded, label: 'Puzzles'),
        BottomNavItem(icon: Icons.leaderboard_rounded, label: 'Ranking'),
        BottomNavItem(icon: Icons.person_rounded, label: 'Profile'),
      ];

  @override
  Widget build(BuildContext context) {
    final screens = widget.isTeacher ? _teacherScreens : _studentScreens;
    final navItems = widget.isTeacher ? _teacherNavItems : _studentNavItems;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: _buildBottomNavBar(navItems),
    );
  }

  Widget _buildBottomNavBar(List<BottomNavItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = i == _currentIndex;
              return GestureDetector(
                onTap: () => setState(() => _currentIndex = i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: selected ? AppColors.primaryGradient : null,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryPurple.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[i].icon,
                        color: selected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.35),
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[i].label,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.35),
                          fontSize: 10,
                          fontWeight: selected
                              ? FontWeight.w800
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final String label;

  BottomNavItem({required this.icon, required this.label});
}
