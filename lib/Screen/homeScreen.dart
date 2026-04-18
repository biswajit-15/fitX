import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Provider/home_provider.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late List<Animation<double>> _slideAnims;
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  String _version = "";

  // ── Design tokens ──────────────────────────────────────────────────────────
  static const _bg = Color(0xFF080E1A);
  static const _card = Color(0xFF161F30);
  static const _cardBorder = Color(0xFF1E2D45);
  static const _textPrimary = Color(0xFFEAF0FB);
  static const _textMuted = Color(0xFF5A7099);

  // Macro accent colors
  static const _calColor = Color(0xFF4F8EF7); // blue  – calories
  static const _proColor = Color(0xFF2ECC8A); // green – protein
  static const _fatColor = Color(0xFFFF9F43); // amber – fat
  static const _carbColor = Color(0xFFFF6B9D); // pink  – carbs

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      setState(() => _version = "v${info.version}");
    });
    // Listen to Firebase totals
    final user = FirebaseAuth.instance.currentUser;
    final provider = context.read<homeprovider>();
    final date = DateFormat('yyyy-MM-dd').format(provider.selectedDate);
    provider.listenToTotals(user!.uid, date);
    provider.fetchTargets();

    // Staggered entrance animations
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _slideAnims = List.generate(5, (i) {
      final start = i * 0.12;
      final end = (start + 0.5).clamp(0.0, 1.0);
      return Tween<double>(begin: 40, end: 0).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();

    super.dispose();
  }

  // ── Date picker ─────────────────────────────────────────────────────────────
  Future<void> _pickDate(BuildContext context) async {
    final provider = context.read<homeprovider>();
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder:
          (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: _calColor,
                surface: _card,
                onSurface: _textPrimary,
              ),
            ),
            child: child!,
          ),
    );
    if (picked != null) {
      provider.setDate(picked);
      final user = FirebaseAuth.instance.currentUser;
      final date = DateFormat('yyyy-MM-dd').format(picked);
      provider.listenToTotals(user!.uid, date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      key: _key,
      drawer: _drawer(context),
      body: Consumer<homeprovider>(
        builder: (context, provider, _) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context, provider)),
              SliverToBoxAdapter(child: _buildCalorieRing(provider)),
              SliverToBoxAdapter(child: _buildMacroGrid(provider)),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  Widget _drawer(BuildContext context) {
    final provider = Provider.of<homeprovider>(context);

    return Drawer(
      backgroundColor: const Color(0xFF080E1A), // ✅ matches _bg exactly
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0D1626), Color(0xFF080E1A)], // ✅ navy-tinted, not purple
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF4F8EF7).withOpacity(0.6), // ✅ blue accent, matches calColor
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE84545).withOpacity(0.2),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: provider.url.isNotEmpty
                        ? Image.network(
                      provider.url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _defaultAvatar(),
                    )
                        : _defaultAvatar(),
                  ),
                ),

                const SizedBox(height: 16),

                // Name
                Text(
                  provider.Name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),

                const SizedBox(height: 4),

              ],
            ),
          ),

          // Thin divider
          Container(
            height: 0.5,
            color: Colors.white.withOpacity(0.06),
          ),

          const SizedBox(height: 12),

          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _drawerItem(
                  icon: Icons.person_outline_rounded,
                  label: "Profile",
                  onTap: () {},
                ),
                 Divider(color: Colors.grey,thickness: 0.2,),

                _drawerItem(
                  icon: Icons.settings_outlined,
                  label: "Settings",
                  onTap: () {},
                ),
                Divider(color: Colors.grey,thickness: 0.3,),
                _drawerItem(
                  icon: Icons.info_outline_rounded,
                  label: "Info",
                  onTap: () {},
                ),

              ],
            ),
          ),
          Divider(color: Colors.grey,thickness: 0.6,),

          // Logout at bottom
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
            child: Column(
              children: [
                Container(
                  height: 0.5,
                  color: Colors.white.withOpacity(0.06),
                  margin: const EdgeInsets.only(bottom: 12),
                ),
                _drawerItem(
                  icon: Icons.logout_rounded,
                  label: "Log out",
                  isDestructive: true,
                  onTap: () => showLogoutDialog(context),
                ),
                Text(
                  "Version: $_version",
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      color: const Color(0xFF1E1E2A),
      child: const Icon(Icons.person_rounded, color: Color(0xFF4F8EF7), size: 44),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? const Color(0xFFE84545) : const Color(0xFFB0B0C8);
    final hoverColor = isDestructive
        ? const Color(0xFFE84545).withOpacity(0.08)
        : Colors.white.withOpacity(0.05);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: hoverColor,
        highlightColor: hoverColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: isDestructive ? const Color(0xFFE84545) : Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.1,
                ),
              ),
              if (!isDestructive) ...[
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withOpacity(0.2),
                  size: 18,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, homeprovider provider) {
    return _SlideIn(
      animation: _slideAnims[0],
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                _key.currentState?.openDrawer(); // ✅ THIS is the trigger
              },
              icon: Icon(Icons.menu, color: Colors.white, size: 40),
            ),
            // Date selector
            GestureDetector(
              onTap: () => _pickDate(context),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.getDateText(),
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _calColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: _calColor,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),

            // Streak / goal badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _cardBorder),
              ),
              child: Consumer<homeprovider>(
                builder: (context, data, _) {
                  return Row(
                    children: [
                      Icon(Icons.local_fire_department,color: Colors.red,size: 30,),
                      Text("0",style: TextStyle(color: Colors.white,fontSize: 20),)
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Calorie ring ────────────────────────────────────────────────────────────
  Widget _buildCalorieRing(homeprovider provider) {
    final target = provider.caltarget.toDouble();
    final progress = (provider.calories / target).clamp(0.0, 1.0);
    final remaining = (target - provider.calories)
        .clamp(0.0, target)
        .toStringAsFixed(0);

    return _SlideIn(
      animation: _slideAnims[1],
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _cardBorder),
          boxShadow: [
            BoxShadow(
              color: _calColor.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ring
            SizedBox(
              width: 110,
              height: 110,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 110,
                    height: 110,
                    child: CircularProgressIndicator(
                      value: 1,
                      strokeWidth: 10,
                      color: _calColor.withOpacity(0.1),
                    ),
                  ),
                  SizedBox(
                    width: 110,
                    height: 110,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                      color: _calColor,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        provider.calories.toStringAsFixed(0),
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      const Text(
                        "kcal",
                        style: TextStyle(color: _textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),

            // Stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Calories",
                    style: TextStyle(
                      color: _textMuted,
                      fontSize: 12,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${(progress * 100).toStringAsFixed(0)}%",
                    style: const TextStyle(
                      color: _calColor,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "of ${target.toStringAsFixed(0)} kcal",
                    style: const TextStyle(color: _textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  _StatChip(
                    label: "$remaining kcal left",
                    color: remaining != '0' ? _proColor : Colors.redAccent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Macro grid ──────────────────────────────────────────────────────────────
  Widget _buildMacroGrid(homeprovider provider) {
    final macros = [
      _MacroData(
        "Protein",
        provider.protein,
        provider.proteintarget.toDouble(),
        _proColor,
        "G",
        Icons.fitness_center_rounded,
      ),
      _MacroData(
        "Carbs",
        provider.carbs,
        provider.carbstarget.toDouble(),
        _carbColor,
        "G",
        Icons.grain_rounded,
      ),
      _MacroData(
        "Fat",
        provider.fat,
        provider.fattarget.toDouble(),
        _fatColor,
        "G",
        Icons.water_drop_rounded,
      ),
    ];

    return _SlideIn(
      animation: _slideAnims[2],
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 12, top: 8),
              child: Text(
                "MACROS",
                style: TextStyle(
                  color: _textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            ...macros.asMap().entries.map((entry) {
              final i = entry.key;
              final m = entry.value;
              return _SlideIn(
                animation: _slideAnims[(i + 2).clamp(0, 4)],
                child: _MacroCard(macro: m),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Macro data model ──────────────────────────────────────────────────────────
class _MacroData {
  final String label;
  final double current;
  final double target;
  final Color color;
  final String unit;
  final IconData icon;

  const _MacroData(
    this.label,
    this.current,
    this.target,
    this.color,
    this.unit,
    this.icon,
  );
}

// ── Macro card ────────────────────────────────────────────────────────────────
class _MacroCard extends StatelessWidget {
  final _MacroData macro;
  const _MacroCard({required this.macro});

  @override
  Widget build(BuildContext context) {
    final progress = (macro.current / macro.target).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161F30),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1E2D45)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: macro.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(macro.icon, color: macro.color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      macro.label,
                      style: const TextStyle(
                        color: Color(0xFF5A7099),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          macro.current.toStringAsFixed(0),
                          style: TextStyle(
                            color: macro.color,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                        Text(
                          " / ${macro.target.toStringAsFixed(0)} ${macro.unit}",
                          style: const TextStyle(
                            color: Color(0xFF5A7099),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                "${(progress * 100).toStringAsFixed(0)}%",
                style: TextStyle(
                  color: macro.color,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: macro.color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(macro.color),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat chip ─────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Slide-in animation wrapper ────────────────────────────────────────────────
class _SlideIn extends AnimatedWidget {
  final Widget child;

  const _SlideIn({required Animation<double> animation, required this.child})
    : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final anim = listenable as Animation<double>;
    return Transform.translate(
      offset: Offset(0, anim.value),
      child: Opacity(
        opacity: (1 - anim.value / 40).clamp(0.0, 1.0),
        child: child,
      ),
    );
  }
}

void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.6),
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: _LogoutDialog(),
      );
    },
  );
}

class _LogoutDialog extends StatelessWidget {
  const _LogoutDialog();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111C2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E2D45), width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Icon + Text ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              children: [
                // Logout icon circle
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE24B4A).withOpacity(0.1),
                    border: Border.all(
                      color: const Color(0xFFE24B4A).withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFE24B4A),
                    size: 24,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  "Log out?",
                  style: TextStyle(
                    color: Color(0xFFEAF0FB),
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "You'll need to sign in again to access\nyour nutrition data and streak.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF5A7099),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ───────────────────────────────────────────────
          Container(
            height: 0.5,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            color: const Color(0xFF1E2D45),
          ),

          // ── Buttons ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              children: [
                // Confirm logout
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE24B4A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Yes, log out",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Cancel
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A2640),
                      foregroundColor: const Color(0xFFEAF0FB),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Color(0xFF1E2D45),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}