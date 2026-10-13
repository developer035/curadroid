import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/crisis_fab.dart';
import '../../data/repositories/session_repo.dart';
import '../../domain/models/exercise_session.dart';
import '../../domain/models/technique.dart';
import 'catalog.dart';

class ExerciseRunner extends ConsumerStatefulWidget {
  final String techniqueId;
  const ExerciseRunner({super.key, required this.techniqueId});

  @override
  ConsumerState<ExerciseRunner> createState() => _ExerciseRunnerState();
}

class _ExerciseRunnerState extends ConsumerState<ExerciseRunner> {
  late Technique _technique;
  int _step = 0;
  int? _preMood;
  int? _postMood;
  final Map<String, String> _inputs = {};
  DateTime? _startedAt;
  bool _showingPreMood = true;

  @override
  void initState() {
    super.initState();
    _technique = techniqueById(widget.techniqueId) ??
        techniqueById('grounding_54321')!;
  }

  void _goNext() {
    if (_step < _technique.steps.length - 1) {
      setState(() => _step++);
    } else {
      _showPostMood();
    }
  }

  void _showPostMood() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (_) => _MoodSheet(
        title: 'How do you feel now?',
        onSelected: (mood) {
          Navigator.pop(context);
          setState(() => _postMood = mood);
          _complete();
        },
      ),
    );
  }

  Future<void> _complete() async {
    final repo = ref.read(sessionRepoProvider);
    await repo.save(ExerciseSession(
      id: 0,
      techniqueId: widget.techniqueId,
      startedAt: _startedAt ?? DateTime.now(),
      completedAt: DateTime.now(),
      preMood: _preMood,
      postMood: _postMood,
      inputs: Map.from(_inputs),
    ));
    HapticFeedback.heavyImpact();
    if (mounted) {
      // Pop back to coach screen (or today if launched from library/dashboard)
      // Pass the mood delta so coach can show the Close message
      if (context.canPop()) {
        context.pop({'preMood': _preMood, 'postMood': _postMood});
      } else {
        context.go(AppRoutes.today);
      }
    }
  }

  Future<bool> _onWillPop() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Leave exercise?'),
        content: const Text('Your progress won\'t be saved.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep going')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Leave')),
        ],
      ),
    );
    return confirm ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final step = _technique.steps[_step];

    if (_showingPreMood && _preMood == null) {
      return Scaffold(
        appBar: AppBar(title: Text(_technique.title)),
        body: _MoodSheet(
          title: 'How are you feeling right now?',
          onSelected: (mood) {
            setState(() {
              _preMood = mood;
              _showingPreMood = false;
              _startedAt = DateTime.now();
            });
          },
          embedded: true,
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final leave = await _onWillPop();
          if (leave && mounted) context.go(AppRoutes.today);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_technique.title),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final leave = await _onWillPop();
              if (leave && mounted) context.go(AppRoutes.today);
            },
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: AppTokens.space8),
              child: CrisisFab(),
            )
          ],
        ),
        body: Column(
          children: [
            // Step progress
            LinearProgressIndicator(
              value: (_step + 1) / _technique.steps.length,
            ),
            Expanded(
              child: switch (step.type) {
                StepType.breath => _BreathingStep(
                    step: step,
                    onComplete: _goNext,
                  ),
                StepType.input => _InputStep(
                    step: step,
                    value: _inputs[step.inputKey ?? ''] ?? '',
                    onChanged: (v) =>
                        setState(() => _inputs[step.inputKey ?? ''] = v),
                    onNext: _goNext,
                  ),
                StepType.timer => _TimedStep(step: step, onComplete: _goNext),
                StepType.read => _ReadStep(step: step, onNext: _goNext),
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Read step ────────────────────────────────────────────────────────────────

class _ReadStep extends StatelessWidget {
  final TechniqueStep step;
  final VoidCallback onNext;
  const _ReadStep({required this.step, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTokens.space24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(step.text,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center),
          const SizedBox(height: AppTokens.space32),
          FilledButton(onPressed: onNext, child: const Text('Continue')),
        ],
      ),
    );
  }
}

// ─── Input step ───────────────────────────────────────────────────────────────

class _InputStep extends StatelessWidget {
  final TechniqueStep step;
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onNext;
  const _InputStep({
    required this.step,
    required this.value,
    required this.onChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTokens.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppTokens.space16),
          Text(step.text, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppTokens.space16),
          Expanded(
            child: TextField(
              autofocus: true,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: 'Write here…',
                alignLabelWithHint: true,
              ),
              onChanged: onChanged,
            ),
          ),
          const SizedBox(height: AppTokens.space16),
          FilledButton(
            onPressed: value.trim().isNotEmpty ? onNext : null,
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}

// ─── Timed step ───────────────────────────────────────────────────────────────

class _TimedStep extends StatefulWidget {
  final TechniqueStep step;
  final VoidCallback onComplete;
  const _TimedStep({required this.step, required this.onComplete});

  @override
  State<_TimedStep> createState() => _TimedStepState();
}

class _TimedStepState extends State<_TimedStep> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.step.durationSec ?? 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining <= 1) {
        _timer?.cancel();
        widget.onComplete();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(widget.step.text,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center),
          const SizedBox(height: AppTokens.space32),
          Text(
            '$_remaining',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppTokens.space8),
          Text('seconds', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppTokens.space32),
          OutlinedButton(
              onPressed: widget.onComplete, child: const Text('Skip')),
        ],
      ),
    );
  }
}

// ─── Breathing animation step ─────────────────────────────────────────────────

class _BreathingStep extends StatefulWidget {
  final TechniqueStep step;
  final VoidCallback onComplete;
  const _BreathingStep({required this.step, required this.onComplete});

  @override
  State<_BreathingStep> createState() => _BreathingStepState();
}

class _BreathingStepState extends State<_BreathingStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _totalSec;
  late int _remaining;
  Timer? _countdown;
  String _phase = 'Inhale';

  final List<String> _phases = [];
  int _phaseIndex = 0;

  @override
  void initState() {
    super.initState();
    _totalSec = widget.step.durationSec ?? 64;
    _remaining = _totalSec;

    _buildPhases();
    _controller = AnimationController(vsync: this);
    _runNextPhase();

    _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining <= 1) {
        _countdown?.cancel();
        widget.onComplete();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  void _buildPhases() {
    final inhale = widget.step.inhale ?? 4;
    final holdIn = widget.step.holdIn ?? 4;
    final exhale = widget.step.exhale ?? 4;
    final holdOut = widget.step.holdOut ?? 4;

    // Build a cycle: inhale, holdIn (if>0), exhale, holdOut (if>0)
    if (inhale > 0) _phases.add('Inhale');
    if (holdIn > 0) _phases.add('Hold');
    if (exhale > 0) _phases.add('Exhale');
    if (holdOut > 0) _phases.add('Hold');
  }

  List<int> get _phaseDurations {
    final inhale = widget.step.inhale ?? 4;
    final holdIn = widget.step.holdIn ?? 4;
    final exhale = widget.step.exhale ?? 4;
    final holdOut = widget.step.holdOut ?? 4;
    final result = <int>[];
    if (inhale > 0) result.add(inhale);
    if (holdIn > 0) result.add(holdIn);
    if (exhale > 0) result.add(exhale);
    if (holdOut > 0) result.add(holdOut);
    return result;
  }

  void _runNextPhase() {
    if (!mounted) return;
    final durations = _phaseDurations;
    final cycleIndex = _phaseIndex % _phases.length;
    final phaseName = _phases[cycleIndex];
    final duration = durations[cycleIndex];

    setState(() {
      _phase = phaseName;
    });

    HapticFeedback.lightImpact();

    final isExpand = phaseName == 'Inhale';
    final isHold = phaseName == 'Hold';

    if (!isHold) {
      _controller.duration = Duration(seconds: duration);
      if (isExpand) {
        _controller.forward(from: _controller.value).then((_) {
          if (mounted) {
            _phaseIndex++;
            _runNextPhase();
          }
        });
      } else {
        _controller.reverse(from: _controller.value).then((_) {
          if (mounted) {
            _phaseIndex++;
            _runNextPhase();
          }
        });
      }
    } else {
      Future.delayed(Duration(seconds: duration), () {
        if (mounted) {
          _phaseIndex++;
          _runNextPhase();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _countdown?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(widget.step.text,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center),
        const SizedBox(height: AppTokens.space48),

        // Breathing circle
        AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            final scale = 0.5 + _controller.value * 0.5;
            return Container(
              width: 200 * scale,
              height: 200 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    cs.primary.withOpacity(0.3 + _controller.value * 0.4),
                    cs.primaryContainer,
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  _phase,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: AppTokens.space32),
        Text(
          '$_remaining s left',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: AppTokens.space16),
        OutlinedButton(
            onPressed: widget.onComplete, child: const Text('Skip')),
      ],
    );
  }
}

// ─── Mood picker sheet ────────────────────────────────────────────────────────

class _MoodSheet extends StatelessWidget {
  final String title;
  final ValueChanged<int> onSelected;
  final bool embedded;

  const _MoodSheet({
    required this.title,
    required this.onSelected,
    this.embedded = false,
  });

  static const _emojis = ['😞', '😕', '😐', '🙂', '😄'];

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: embedded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!embedded)
          const SizedBox(height: AppTokens.space24),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppTokens.space24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (i) {
            return GestureDetector(
              onTap: () => onSelected(i + 1),
              child: Container(
                width: AppTokens.minTouchTarget + 8,
                height: AppTokens.minTouchTarget + 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppTokens.radiusM),
                ),
                child: Center(child: Text(_emojis[i], style: const TextStyle(fontSize: 28))),
              ),
            );
          }),
        ),
        const SizedBox(height: AppTokens.space24),
      ],
    );

    if (embedded) {
      return Padding(
        padding: const EdgeInsets.all(AppTokens.space24),
        child: content,
      );
    }
    return Padding(
      padding: const EdgeInsets.all(AppTokens.space16),
      child: content,
    );
  }
}
