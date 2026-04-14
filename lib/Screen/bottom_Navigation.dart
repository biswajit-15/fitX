import 'package:fitx/Screen/addMeal.dart';
import 'package:fitx/Screen/historyScreen.dart';
import 'package:fitx/Screen/homeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0;

  // Match the dark theme used in HomeScreen & AddMeal
  static const _navBg     = Color(0xFF101825); // same as _surface
  static const _activeClr = Color(0xFF4F8EF7); // same as _accent blue
  static const _iconClr   = Colors.white;

  final List<Widget> _pages = const [
    HomeScreen(),
    AddMeal(),
    History(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF080E1A),
        body: _pages[_currentIndex],
        bottomNavigationBar: CircleNavBar(
          activeIndex: _currentIndex,
          color: _navBg,
          circleColor: _activeClr,
          circleGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4F8EF7), Color(0xFF2563EB)],
          ),
          shadowColor: const Color(0x554F8EF7),
          elevation: 12,
          height: 65,
          circleWidth: 58,
          activeIcons: const [
            Icon(Icons.home_rounded,       color: _iconClr, size: 40),
            Icon(Icons.add_rounded,        color: _iconClr, size: 40),
            Icon(Icons.bar_chart_rounded,  color: _iconClr, size: 40),
          ],
          inactiveIcons: const [
            _NavLabel(icon: Icons.home_rounded,      label: "Home"),
            _NavLabel(icon: Icons.add_rounded,       label: "Log"),
            _NavLabel(icon: Icons.bar_chart_rounded, label: "History"),
          ],
          onTap: (index) {
            if (index == _currentIndex) return;
            HapticFeedback.lightImpact();
            setState(() => _currentIndex = index);
          },
        ),
      ),
    );
  }
}

/// Inactive tab — icon + label stacked, muted color
class _NavLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _NavLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color:Colors.white, size: 35),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF3A4E6A),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}