import 'package:fitx/Provider/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class History extends StatelessWidget {
  const History({super.key});

  // ── Constants ──────────────────────────────────────────────────────────────
  static const _bg          = Color(0xFF080E1A);
  static const _card        = Color(0xFF161F30);
  static const _cardBorder  = Color(0xFF1E2D45);
  static const _textPrimary = Color(0xFFEAF0FB);
  static const _textMuted   = Color(0xFF5A7099);
  static const _calColor    = Color(0xFF4F8EF7);
  static const _proColor    = Color(0xFF2ECC8A);
  static const _fatColor    = Color(0xFFFF9F43);
  static const _carbColor   = Color(0xFFFF6B9D);

  static const double _calTarget  = 2400;
  static const double _proTarget  = 150;
  static const double _fatTarget  = 70;
  static const double _carbTarget = 300;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HistoryProvider>();

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: provider.isLoading
            ? const Center(
            child: CircularProgressIndicator(color: Color(0xFF4F8EF7)))
            : provider.error != null
            ? _errorView(provider)
            : CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _header(provider)),
            SliverToBoxAdapter(child: _weeklySummaryCard(provider)),
            SliverToBoxAdapter(child: _dayListSection(provider)),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _header(HistoryProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => provider.previousWeek(),
            icon: const Icon(Icons.chevron_left, size: 32, color: _textPrimary),
          ),
          Column(
            children: [
              Text(provider.formattedRange,
                  style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
              Text(provider.startOfWeek.year.toString(),
                  style: const TextStyle(color: _textMuted, fontSize: 12)),
            ],
          ),
          provider.weekOffset != 0
              ? IconButton(
            onPressed: () => provider.nextWeek(),
            icon: const Icon(Icons.chevron_right,
                size: 32, color: _textPrimary),
          )
              : const SizedBox(width: kMinInteractiveDimension),
        ],
      ),
    );
  }

  // ── Weekly summary card ────────────────────────────────────────────────────
  Widget _weeklySummaryCard(HistoryProvider provider) {
    final totals = provider.weekTotals;
    final avg    = provider.weekAverages;
    final logged = provider.weekLogs.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Weekly Summary',
                    style: TextStyle(
                        color: _textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _calColor.withOpacity(.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('$logged/7 days logged',
                      style: const TextStyle(
                          color: _calColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Text('TOTALS',
                style: TextStyle(
                    color: _textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2)),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _summaryTile('Calories', totals.calories, 'kcal', _calColor,
                    Icons.local_fire_department_rounded),
                _summaryTile('Protein', totals.protein, 'g', _proColor,
                    Icons.fitness_center_rounded),
                _summaryTile('Fat', totals.fat, 'g', _fatColor,
                    Icons.water_drop_rounded),
                _summaryTile('Carbs', totals.carbs, 'g', _carbColor,
                    Icons.grain_rounded),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: _cardBorder, height: 1),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Text('DAILY AVERAGE',
                style: TextStyle(
                    color: _textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2)),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _avgChip('Cal',  avg.calories, 'kcal', _calColor),
                _avgChip('Pro',  avg.protein,  'g',    _proColor),
                _avgChip('Fat',  avg.fat,      'g',    _fatColor),
                _avgChip('Carbs',avg.carbs,    'g',    _carbColor),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Day list section ───────────────────────────────────────────────────────
  Widget _dayListSection(HistoryProvider provider) {
    final days = provider.currentWeekDays;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Text('DAY WISE',
              style: TextStyle(
                  color: _textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2)),
        ),
        ...days.map((entry) => _dayCard(entry.date, entry.log)),
      ],
    );
  }

  // ── Single day card ────────────────────────────────────────────────────────
  Widget _dayCard(DateTime date, DayLog? log) {
    final isToday = _isToday(date);
    final hasData = log != null;

    final calPct  = hasData ? (log.calories / _calTarget).clamp(0.0, 1.0)  : 0.0;
    final proPct  = hasData ? (log.protein  / _proTarget).clamp(0.0, 1.0)  : 0.0;
    final fatPct  = hasData ? (log.fat      / _fatTarget).clamp(0.0, 1.0)  : 0.0;
    final carbPct = hasData ? (log.carbs    / _carbTarget).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isToday ? _calColor.withOpacity(.4) : _cardBorder,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(_dayLabel(date),
                    style: TextStyle(
                        color: isToday ? _calColor : _textMuted,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .6)),
                const SizedBox(height: 2),
                Text(date.day.toString(),
                    style: TextStyle(
                        color: isToday ? _calColor : _textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(width: 1, height: 36, color: _cardBorder),
          const SizedBox(width: 12),
          Expanded(
            child: hasData
                ? Column(
              children: [
                _miniBar('Cal',  calPct,  _calColor),
                const SizedBox(height: 5),
                _miniBar('Pro',  proPct,  _proColor),
                const SizedBox(height: 5),
                _miniBar('Fat',  fatPct,  _fatColor),
                const SizedBox(height: 5),
                _miniBar('Carb', carbPct, _carbColor),
              ],
            )
                : const Text('No data',
                style: TextStyle(color: _textMuted, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ── Mini progress bar ──────────────────────────────────────────────────────
  Widget _miniBar(String label, double pct, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 26,
          child: Text(label,
              style: const TextStyle(color: _textMuted, fontSize: 9)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 5,
              backgroundColor: color.withOpacity(.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 28,
          child: Text('${(pct * 100).toStringAsFixed(0)}%',
              textAlign: TextAlign.right,
              style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  // ── Summary tile ───────────────────────────────────────────────────────────
  Widget _summaryTile(String label, double value, String unit,
      Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
              color: color.withOpacity(.12), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 6),
        Text(value.toStringAsFixed(0),
            style: TextStyle(
                color: color, fontSize: 14, fontWeight: FontWeight.w700)),
        Text(unit,
            style: const TextStyle(color: _textMuted, fontSize: 10)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                color: _textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  // ── Average chip ───────────────────────────────────────────────────────────
  Widget _avgChip(String label, double value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(.2)),
      ),
      child: Column(
        children: [
          Text(value.toStringAsFixed(1),
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.w700)),
          Text('$label/$unit',
              style: const TextStyle(color: _textMuted, fontSize: 9)),
        ],
      ),
    );
  }

  // ── Error view ─────────────────────────────────────────────────────────────
  Widget _errorView(HistoryProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, color: _textMuted, size: 48),
            const SizedBox(height: 16),
            const Text('Something went wrong',
                style: TextStyle(
                    color: _textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(provider.error ?? 'Unknown error',
                style: const TextStyle(color: _textMuted, fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: provider.fetchWeekLogs,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _calColor,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  String _dayLabel(DateTime d) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[d.weekday - 1];
  }
}
