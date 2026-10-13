import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/tokens.dart';
import '../../data/repositories/settings_repo.dart';
import '../../core/router/app_router.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    _OnboardPage(
      icon: Icons.self_improvement,
      title: 'Know Your Readiness',
      body:
          'CuraTrail reads your sleep, HRV, and resting heart rate to compute a daily readiness score — so you can work with your body, not against it.',
    ),
    _OnboardPage(
      icon: Icons.psychology_outlined,
      title: 'CBT-Guided Coaching',
      body:
          'Our coach uses proven cognitive-behavioural techniques to help you reframe thoughts, regulate stress, and build resilience — in under 5 minutes.',
    ),
    _OnboardPage(
      icon: Icons.lock_outlined,
      title: 'Private by Design',
      body:
          'All data stays on your device. No accounts. No cloud sync. No ads. CuraTrail is wellness support — not a substitute for professional care.',
    ),
  ];

  void _next() {
    if (_page < _pages.length - 1) {
      _controller.nextPage(
        duration: AppTokens.durationMedium,
        curve: Curves.easeInOut,
      );
    }
  }

  void _finish(bool useRealHealth) {
    final settings = ref.read(settingsRepoProvider);
    settings.onboarded = true;
    settings.useRealHealth = useRealHealth;
    context.go(AppRoutes.today);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLast = _page == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (p) => setState(() => _page = p),
                itemCount: _pages.length,
                itemBuilder: (_, i) => _OnboardPageView(page: _pages[i]),
              ),
            ),

            // Dot indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                return AnimatedContainer(
                  duration: AppTokens.durationFast,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _page ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _page ? cs.primary : cs.outlineVariant,
                    borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                  ),
                );
              }),
            ),

            const SizedBox(height: AppTokens.space32),

            // CTA buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTokens.space24),
              child: isLast
                  ? Column(
                      children: [
                        FilledButton.icon(
                          onPressed: () => _finish(false),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Use Sample Data'),
                        ),
                        const SizedBox(height: AppTokens.space12),
                        OutlinedButton.icon(
                          onPressed: () => _finish(true),
                          icon: const Icon(Icons.favorite_outline),
                          label: const Text('Connect Health Connect'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(AppTokens.minTouchTarget),
                          ),
                        ),
                        const SizedBox(height: AppTokens.space16),
                        Text(
                          'CuraTrail is wellness support, not medical treatment.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  : FilledButton(
                      onPressed: _next,
                      child: const Text('Next'),
                    ),
            ),

            const SizedBox(height: AppTokens.space32),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage {
  final IconData icon;
  final String title;
  final String body;
  const _OnboardPage({required this.icon, required this.title, required this.body});
}

class _OnboardPageView extends StatelessWidget {
  final _OnboardPage page;
  const _OnboardPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(AppTokens.space32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 48, color: cs.primary),
          ),
          const SizedBox(height: AppTokens.space32),
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTokens.space16),
          Text(
            page.body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
