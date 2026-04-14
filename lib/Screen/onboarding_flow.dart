import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/onboarding_Provider.dart';
import 'onboarding_screens.dart';

class OnboardingFlow extends StatelessWidget {
  const OnboardingFlow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingProvider(),
      child: const OnboardingFlowContent(),
    );
  }
}

class OnboardingFlowContent extends StatefulWidget {
  const OnboardingFlowContent({Key? key}) : super(key: key);

  @override
  State<OnboardingFlowContent> createState() => _OnboardingFlowContentState();
}

class _OnboardingFlowContentState extends State<OnboardingFlowContent> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Consumer<OnboardingProvider>(
          builder: (context, provider, child) {

            // Sync PageView with provider step
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_pageController.hasClients &&
                  _pageController.page?.round() != provider.currentStep) {
                _goToPage(provider.currentStep);
              }
            });

            return Stack(
              children: [

                // ── Pages ──────────────────────────────────────────────
                PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    MainGoalScreen(),
                    GenderScreen(),
                    AgeScreen(),
                    HeightScreen(),
                    WeightScreen(),
                    DietTypeScreen(),
                  ],
                ),

                // ── Back button overlay (top-left) ──────────────────────
                if (provider.currentStep > 0)
                  Positioned(
                    top: 5,
                    left: 8,
                    child: AnimatedOpacity(
                      opacity: provider.currentStep > 0 ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: GestureDetector(
                        onTap: () => provider.previousStep(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1C1C),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF2A2A2A)),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}