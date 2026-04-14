// onboarding_screens.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/onboarding_Provider.dart';
import '../services/TargetCalculation.dart';
import '../widgets/onboarding_Widgets.dart';

// ─── Shared Design Tokens ────────────────────────────────────────────────────

const _bg = Color(0xFF0A0A0A);
const _surface = Color(0xFF141414);
const _card = Color(0xFF1C1C1C);
const _accent = Color(0xFFC6F135);       // lime green
const _accentDim = Color(0xFF2A3A00);
const _textPrimary = Colors.white;
const _textSecondary = Color(0xFF8A8A8A);
const _selectedBorder = Color(0xFFC6F135);
const _unselectedBorder = Color(0xFF2A2A2A);

// ─── Reusable Widgets ────────────────────────────────────────────────────────

class _ScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final int step;
  final int totalSteps;

  const _ScreenHeader({
    required this.title,
    required this.subtitle,
    required this.step,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 60),

        // Step indicator
        Row(
          children: List.generate(totalSteps, (i) {
            final active = i < step;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < totalSteps - 1 ? 4 : 0),
                height: 3,
                decoration: BoxDecoration(
                  color: active ? _accent : _unselectedBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 8),
        Text(
          "Step $step of $totalSteps",
          style: const TextStyle(color: _textSecondary, fontSize: 12),
        ),

        const SizedBox(height: 32),

        // Title
        Text(
          subtitle,
          style: const TextStyle(
            color: _accent,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 34,
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String text;
  final String? emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? _accentDim : _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _selectedBorder : _unselectedBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: isSelected ? _accent : _textPrimary,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? _accent : Colors.transparent,
                border: Border.all(
                  color: isSelected ? _accent : _textSecondary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.black)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback? onPressed;
  final bool isLast;

  const _PrimaryButton({
    required this.label,
    required this.enabled,
    this.onPressed,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: enabled ? _accent : _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: enabled ? _accent : _unselectedBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: enabled ? Colors.black : _textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isLast ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
              color: enabled ? Colors.black : _textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _ValueDisplay extends StatelessWidget {
  final int value;
  final String suffix;

  const _ValueDisplay({required this.value, required this.suffix});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        color: _accentDim,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accent.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "$value",
            style: const TextStyle(
              color: _accent,
              fontSize: 64,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 6),
            child: Text(
              suffix,
              style: const TextStyle(
                color: _textSecondary,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Screens ─────────────────────────────────────────────────────────────────

class MainGoalScreen extends StatelessWidget {
  const MainGoalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        return Container(
          color: _bg,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ScreenHeader(
                  title: "What's your\nmain goal?",
                  subtitle: "GOAL",
                  step: 1,
                  totalSteps: 6,
                ),
                const SizedBox(height: 36),
                _OptionCard(
                  text: "Lose Weight",
                  emoji: "🔥",
                  isSelected: provider.data.goal == 'Lose weight',
                  onTap: () => provider.setMainGoal('Lose weight'),
                ),
                _OptionCard(
                  text: "Build Muscle",
                  emoji: "💪",
                  isSelected: provider.data.goal == 'Build muscle',
                  onTap: () => provider.setMainGoal('Build muscle'),
                ),
                _OptionCard(
                  text: "Stay in Shape",
                  emoji: "⚡",
                  isSelected: provider.data.goal == 'Stay in shape',
                  onTap: () => provider.setMainGoal('Stay in shape'),
                ),
                const Spacer(),
                _PrimaryButton(
                  label: "Continue",
                  enabled: provider.data.goal != null,
                  onPressed: () => provider.nextStep(),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}

class GenderScreen extends StatelessWidget {
  const GenderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        return Container(
          color: _bg,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ScreenHeader(
                  title: "What's your\ngender?",
                  subtitle: "PROFILE",
                  step: 2,
                  totalSteps: 6,
                ),
                const SizedBox(height: 36),
                _OptionCard(
                  text: "Male",
                  emoji: "♂️",
                  isSelected: provider.data.gender == 'Male',
                  onTap: () => provider.setGender('Male'),
                ),
                _OptionCard(
                  text: "Female",
                  emoji: "♀️",
                  isSelected: provider.data.gender == 'Female',
                  onTap: () => provider.setGender('Female'),
                ),
                _OptionCard(
                  text: "Prefer not to say",
                  emoji: "🤝",
                  isSelected: provider.data.gender == 'Prefer not to say',
                  onTap: () => provider.setGender('Prefer not to say'),
                ),
                const Spacer(),
                _PrimaryButton(
                  label: "Continue",
                  enabled: provider.data.gender != null,
                  onPressed: () => provider.nextStep(),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AgeScreen extends StatelessWidget {
  const AgeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        return Container(
          color: _bg,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ScreenHeader(
                  title: "How old\nare you?",
                  subtitle: "AGE",
                  step: 3,
                  totalSteps: 6,
                ),
                const SizedBox(height: 36),
                Center(
                  child: _ValueDisplay(
                    value: provider.data.age ?? 25,
                    suffix: "yrs",
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: NumberPicker(
                    value: provider.data.age ?? 25,
                    minValue: 16,
                    maxValue: 80,
                    suffix: '',
                    onChanged: (value) => provider.setAge(value),
                  ),
                ),
                _PrimaryButton(
                  label: "Continue",
                  enabled: provider.data.age != null,
                  onPressed: () => provider.nextStep(),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}

class HeightScreen extends StatelessWidget {
  const HeightScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        return Container(
          color: _bg,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ScreenHeader(
                  title: "What's your\nheight?",
                  subtitle: "BODY",
                  step: 4,
                  totalSteps: 6,
                ),
                const SizedBox(height: 36),
                Center(
                  child: _ValueDisplay(
                    value: provider.data.height ?? 170,
                    suffix: "cm",
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: NumberPicker(
                    value: provider.data.height ?? 170,
                    minValue: 140,
                    maxValue: 220,
                    suffix: 'cm',
                    onChanged: (value) => provider.setHeight(value),
                  ),
                ),
                _PrimaryButton(
                  label: "Continue",
                  enabled: provider.data.height != null,
                  onPressed: () => provider.nextStep(),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}

class WeightScreen extends StatelessWidget {
  const WeightScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        return Container(
          color: _bg,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ScreenHeader(
                  title: "What's your\nweight?",
                  subtitle: "BODY",
                  step: 5,
                  totalSteps: 6,
                ),
                const SizedBox(height: 36),
                Center(
                  child: _ValueDisplay(
                    value: provider.data.weight ?? 75,
                    suffix: "kg",
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: NumberPicker(
                    value: provider.data.weight ?? 75,
                    minValue: 40,
                    maxValue: 200,
                    suffix: 'kg',
                    onChanged: (value) => provider.setWeight(value),
                  ),
                ),
                _PrimaryButton(
                  label: "Continue",
                  enabled: provider.data.weight != null,
                  onPressed: () => provider.nextStep(),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DietTypeScreen extends StatelessWidget {
  const DietTypeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        return Container(
          color: _bg,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ScreenHeader(
                  title: "What diet\ndo you follow?",
                  subtitle: "DIET",
                  step: 6,
                  totalSteps: 6,
                ),
                const SizedBox(height: 36),
                _OptionCard(
                  text: "Non-Vegetarian",
                  emoji: "🍗",
                  isSelected: provider.data.dietType == 'Non-Vegetarian',
                  onTap: () => provider.setDietType('Non-Vegetarian'),
                ),
                _OptionCard(
                  text: "Vegetarian",
                  emoji: "🥗",
                  isSelected: provider.data.dietType == 'Vegetarian',
                  onTap: () => provider.setDietType('Vegetarian'),
                ),
                _OptionCard(
                  text: "Vegan",
                  emoji: "🌱",
                  isSelected: provider.data.dietType == 'Vegan',
                  onTap: () => provider.setDietType('Vegan'),
                ),
                const Spacer(),
                _PrimaryButton(
                  label: "Let's Go!",
                  enabled: provider.data.dietType != null,
                  isLast: true,
                  onPressed: () async {
                    final result = calculateMacros(
                      weight: provider.data.weight!.toDouble(),
                      height: provider.data.height!.toDouble(),
                      age: provider.data.age!,
                      gender: provider.data.gender!,
                      goal: provider.data.goal!,
                    );

                    await saveTargetsToFirebase(result);
                    await provider.completeOnboarding();
                    Navigator.pushReplacementNamed(context, '/bottomNavigation');
                  },                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}