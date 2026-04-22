import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../Provider/home_provider.dart';

class ProfileSetup extends StatefulWidget {
  const ProfileSetup({super.key});

  @override
  State<ProfileSetup> createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup>
    with TickerProviderStateMixin {
  Map<String, String> editedData = {};

  // ─── Theme Colors ──────────────────────────────────────────────────
  static const _bg = Color(0xFF080E1A);
  static const Color _surface = Color(0xFF161618);
  static const Color _card = Color(0xFF1C1C1F);
  static const Color _accent = Color(0xFF00E5A0); // neon teal-green
  static const Color _accentDim = Color(0x2200E5A0);
  static const Color _textPrimary = Color(0xFFEEEEF0);
  static const Color _textSecondary = Color(0xFF7A7A85);
  static const Color _border = Color(0xFF2A2A2E);

  // ─── Field grouping ────────────────────────────────────────────────
  final List<Map<String, dynamic>> _sections = [
    {
      'title': 'Personal',
      'icon': Icons.person_outline_rounded,
      'fields': ['Name', 'Age', 'Gender','Height','Weight'],
    },
    {
      'title': 'Lifestyle',
      'icon': Icons.restaurant_menu_outlined,
      'fields': ['Diet Type', 'Goal'],
    },
    {
      'title': 'Daily Targets',
      'icon': Icons.track_changes_rounded,
      'fields': [
        'Targeted cal',
        'Targeted Protein',
        'Targeted Carbs',
        'Targeted Fat'
      ],
    },
  ];

  final Map<String, IconData> _fieldIcons = {
    'Name': Icons.badge_outlined,
    'Age': Icons.cake_outlined,
    'Gender': Icons.wc_outlined,
    'Height': Icons.height_rounded,
    'Weight': Icons.monitor_weight_outlined,
    'Diet Type': Icons.eco_outlined,
    'Goal': Icons.flag_outlined,
    'Targeted cal': Icons.local_fire_department_outlined,
    'Targeted Protein': Icons.fitness_center_outlined,
    'Targeted Carbs': Icons.grain_outlined,
    'Targeted Fat': Icons.water_drop_outlined,
  };

  final Map<String, String> _fieldUnits = {
    'Targeted cal': 'kcal',
    'Targeted Protein': 'g',
    'Targeted Carbs': 'g',
    'Targeted Fat': 'g',
    'Height':'cm',
    'Weight':'kg',
    'Age': 'yrs',
  };

  @override
  void initState() {
    super.initState();

    final provider = context.read<homeprovider>();
    provider.fetchTargets();

    editedData = {
      "Name": provider.Name,
      "Age": provider.age.toString(),
      "Gender": provider.gender,
      "Diet Type": provider.diteType,
      "Goal": provider.goal,
      "Targeted cal": provider.caltarget.toString(),
      "Targeted Protein": provider.proteintarget.toString(),
      "Targeted Carbs": provider.carbstarget.toString(),
      "Targeted Fat": provider.fattarget.toString(),
      "Height":provider.height.toString(),
      "Weight":provider.weight.toString(),
    };
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ─── Edit dialog ───────────────────────────────────────────────────
  void editField(String key) {
    HapticFeedback.lightImpact();
    final String currentValue = editedData[key] ?? "";

    List<String>? options;
    if (key == "Gender") {
      options = ["Male", "Female", "Other"];
    } else if (key == "Diet Type") {
      options = ["Non-Vegetarian", "Vegetarian", "Vegan"];
    } else if (key == "Goal") {
      options = ["Lose Weight", "Build Muscle", "Stay in Shape"];
    }

    final controller = TextEditingController(text: currentValue);
    String tempValue = currentValue;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: _border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Label
                Row(
                  children: [
                    Icon(_fieldIcons[key] ?? Icons.edit_outlined,
                        color: _accent, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      key,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Input: dropdown or text field
                if (options != null)
                  Column(
                    children: options.map((opt) {
                      final isSelected = tempValue == opt;
                      return GestureDetector(
                        onTap: () => setSheet(() => tempValue = opt),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? _accentDim : _surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? _accent : _border,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  opt,
                                  style: TextStyle(
                                    color: isSelected
                                        ? _accent
                                        : _textPrimary,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded,
                                    color: _accent, size: 18),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  )
                else
                  TextField(
                    controller: controller,
                    keyboardType: (key == 'Age' ||
                        key.startsWith('Targeted'))
                        ? TextInputType.number
                        : TextInputType.text,
                    style: const TextStyle(color: _textPrimary, fontSize: 16),
                    cursorColor: _accent,
                    decoration: InputDecoration(
                      hintText: "Enter $key",
                      hintStyle: const TextStyle(color: _textSecondary),
                      suffixText: _fieldUnits[key],
                      suffixStyle:
                      const TextStyle(color: _accent, fontSize: 14),
                      filled: true,
                      fillColor: _surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                        const BorderSide(color: _accent, width: 1.5),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      setState(() {
                        editedData[key] =
                        options != null ? tempValue : controller.text;
                      });
                      HapticFeedback.mediumImpact();
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Single field row ──────────────────────────────────────────────
  Widget _fieldTile(String key) {
    final unit = _fieldUnits[key];
    final value = editedData[key] ?? '—';
    final displayValue = unit != null ? "$value $unit" : value;

    return GestureDetector(
      onTap: () => editField(key),
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _accentDim,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_fieldIcons[key] ?? Icons.edit_outlined,
                  color: _accent, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    key,
                    style: const TextStyle(
                      color: _textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayValue,
                    style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: _textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  // ─── Section card ──────────────────────────────────────────────────
  Widget _sectionCard(Map<String, dynamic> section) {
    final fields = section['fields'] as List<String>;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Row(
              children: [
                Icon(section['icon'] as IconData,
                    color: _accent, size: 15),
                const SizedBox(width: 6),
                Text(
                  (section['title'] as String).toUpperCase(),
                  style: const TextStyle(
                    color: _accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Container(height: 1, color: _border, margin: const EdgeInsets.symmetric(horizontal: 16)),
          // Fields
          ...fields.asMap().entries.map((entry) {
            final isLast = entry.key == fields.length - 1;
            return Column(
              children: [
                _fieldTile(entry.value),
                if (!isLast)
                  Container(
                    height: 1,
                    color: _border,
                    margin: const EdgeInsets.only(left: 66, right: 16),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ─── Macro chip (summary strip) ────────────────────────────────────
  Widget _macroChip(String label, String field, Color color) {
    final value = editedData[field] ?? '0';
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: _textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<homeprovider>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _bg,
        body:  CustomScrollView(
            slivers: [
              // ── App Bar ────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                backgroundColor: _bg,
                surfaceTintColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: _textPrimary, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        context.read<homeprovider>().updateAllFields(editedData);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    color: Colors.black, size: 18),
                                SizedBox(width: 8),
                                Text("Profile saved!",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            backgroundColor: _accent,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.all(16),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _accent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Save",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Stack(
                    children: [
                      // Subtle gradient background
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF0D1A16), _bg],
                            ),
                          ),
                        ),
                      ),
                      // Glow behind avatar
                      Positioned(
                        top: 60,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _accent.withOpacity(0.25),
                                  blurRadius: 60,
                                  spreadRadius: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Avatar + name
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: _accent, width: 2.5),
                                    color: _surface,
                                  ),
                                  child: ClipOval(
                                    child: provider.url.isNotEmpty
                                        ? Image.network(
                                      provider.url,
                                      fit: BoxFit.cover,
                                    )
                                        : const Icon(
                                      Icons.person_rounded,
                                      color: _accent,
                                      size: 44,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: _accent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: _bg, width: 2),
                                  ),
                                  child: const Icon(Icons.camera_alt_rounded,
                                      color: Colors.black, size: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              editedData['Name'] ?? 'Your Name',
                              style: const TextStyle(
                                color: _textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "${editedData['Goal'] ?? ''} · ${editedData['Diet Type'] ?? ''}",
                              style: const TextStyle(
                                color: _textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Macro summary strip ────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: Row(
                    children: [
                      _macroChip("KCAL", "Targeted cal",
                          const Color(0xFFFF6B35)),
                      const SizedBox(width: 8),
                      _macroChip("PROTEIN", "Targeted Protein",
                          const Color(0xFF4FC3F7)),
                      const SizedBox(width: 8),
                      _macroChip("CARBS", "Targeted Carbs",
                          const Color(0xFFFFD54F)),
                      const SizedBox(width: 8),
                      _macroChip("FAT", "Targeted Fat",
                          const Color(0xFFCE93D8)),
                    ],
                  ),
                ),
              ),

              // ── Sections ───────────────────────────────────────────
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _sectionCard(_sections[index]),
                  childCount: _sections.length,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
    );
  }
}