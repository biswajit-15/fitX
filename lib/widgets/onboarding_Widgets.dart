import 'package:flutter/material.dart';
class OnboardingBackground extends StatelessWidget {
  final Widget child;
  final String? iconPath;

  const OnboardingBackground({
    Key? key,
    required this.child,
    this.iconPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            Colors.grey[900]!,
          ],
        ),
      ),
      child: Stack(
        children: [
          if (iconPath != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: 1,
                child: Icon(
                  Icons.fitness_center,
                  size: 200,
                  color: Colors.white,
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}

class OptionButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const OptionButton({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NumberPicker extends StatelessWidget {
  final int value;
  final int minValue;
  final int maxValue;
  final String suffix;
  final ValueChanged<int> onChanged;

  const NumberPicker({
    Key? key,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.suffix,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        itemCount: maxValue - minValue + 1,
        itemBuilder: (context, index) {
          final number = minValue + index;
          final isSelected = number == value;

          return GestureDetector(
            onTap: () => onChanged(number),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: isSelected ? Colors.grey[700] : Colors.transparent,
              child: Center(
                child: Text(
                  '$number $suffix',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontSize: isSelected ? 24 : 18,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class FinishButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool enabled;

  const FinishButton({
    Key? key,
    required this.onPressed,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.grey[700],
          disabledForegroundColor: Colors.grey[500],
        ),
        child: const Text(
          'Finish',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class NextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool enabled;

  const NextButton({
    Key? key,
    required this.onPressed,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.grey[700],
          disabledForegroundColor: Colors.grey[500],
        ),
        child: const Text(
          'Next',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  final double progress;

  const ProgressBar({
    Key? key,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}