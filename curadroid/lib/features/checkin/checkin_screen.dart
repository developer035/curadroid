import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/crisis_fab.dart';
import '../../data/repositories/checkin_repo.dart';
import '../../domain/models/checkin.dart';

final _checkinFormProvider =
    StateNotifierProvider.autoDispose<_CheckinFormNotifier, _CheckinForm>(
  (_) => _CheckinFormNotifier(),
);

class _CheckinForm {
  final int mood;
  final int energy;
  final int stress;
  final String? note;
  final Set<String> tags;
  final bool saving;
  final String? error;

  const _CheckinForm({
    this.mood = 3,
    this.energy = 3,
    this.stress = 3,
    this.note,
    this.tags = const {},
    this.saving = false,
    this.error,
  });

  _CheckinForm copyWith({
    int? mood,
    int? energy,
    int? stress,
    String? note,
    Set<String>? tags,
    bool? saving,
    String? error,
  }) =>
      _CheckinForm(
        mood: mood ?? this.mood,
        energy: energy ?? this.energy,
        stress: stress ?? this.stress,
        note: note ?? this.note,
        tags: tags ?? this.tags,
        saving: saving ?? this.saving,
        error: error ?? this.error,
      );
}

class _CheckinFormNotifier extends StateNotifier<_CheckinForm> {
  _CheckinFormNotifier() : super(const _CheckinForm());

  void setMood(int v) {
    HapticFeedback.selectionClick();
    state = state.copyWith(mood: v);
  }
  void setEnergy(int v) {
    HapticFeedback.selectionClick();
    state = state.copyWith(energy: v);
  }
  void setStress(int v) {
    HapticFeedback.selectionClick();
    state = state.copyWith(stress: v);
  }
  void setNote(String v) => state = state.copyWith(note: v.isEmpty ? null : v);

  void toggleTag(String tag) {
    final next = Set<String>.from(state.tags);
    if (next.contains(tag)) {
      next.remove(tag);
    } else {
      next.add(tag);
    }
    state = state.copyWith(tags: next);
  }

  Future<int?> save(CheckinRepository repo) async {
    state = state.copyWith(saving: true, error: null);
    try {
      final checkin = CheckIn(
        id: 0,
        ts: DateTime.now(),
        mood: state.mood,
        energy: state.energy,
        stress: state.stress,
        note: state.note,
        tags: state.tags.toList(),
      );
      final id = await repo.save(checkin);
      return id;
    } catch (e) {
      state = state.copyWith(saving: false, error: e.toString());
      return null;
    }
  }
}

const _kTags = [
  'Racing thoughts',
  'Tired',
  'Worried',
  'Calm',
  'Lonely',
  'Overwhelmed',
  'Anxious',
  'Grateful',
];

const _kMoodEmoji = ['😞', '😕', '😐', '🙂', '😄'];
const _kEnergyEmoji = ['🪫', '😴', '⚡', '🔋', '🚀'];
const _kStressEmoji = ['😌', '😊', '😤', '😰', '🤯'];

class CheckinScreen extends ConsumerWidget {
  const CheckinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(_checkinFormProvider);
    final notifier = ref.read(_checkinFormProvider.notifier);
    final repo = ref.read(checkinRepoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check In'),
        actions: const [CrisisFab()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTokens.space16),
        children: [
          Text(
            'How are you right now?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppTokens.space4),
          Text(
            'This takes under 30 seconds.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppTokens.space24),

          _ScaleRow(
            label: 'Mood',
            emojis: _kMoodEmoji,
            value: form.mood,
            onChanged: notifier.setMood,
          ),
          const SizedBox(height: AppTokens.space16),
          _ScaleRow(
            label: 'Energy',
            emojis: _kEnergyEmoji,
            value: form.energy,
            onChanged: notifier.setEnergy,
          ),
          const SizedBox(height: AppTokens.space16),
          _ScaleRow(
            label: 'Stress',
            emojis: _kStressEmoji,
            value: form.stress,
            onChanged: notifier.setStress,
          ),

          const SizedBox(height: AppTokens.space24),
          Text(
            'What\'s on your mind? (optional)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppTokens.space8),
          Wrap(
            spacing: AppTokens.space8,
            runSpacing: AppTokens.space8,
            children: _kTags.map((tag) {
              final selected = form.tags.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: selected,
                onSelected: (_) => notifier.toggleTag(tag),
              );
            }).toList(),
          ),

          const SizedBox(height: AppTokens.space16),
          TextField(
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Anything else on your mind? (optional)',
            ),
            onChanged: notifier.setNote,
          ),

          if (form.error != null) ...[
            const SizedBox(height: AppTokens.space8),
            Text(form.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],

          const SizedBox(height: AppTokens.space32),
          FilledButton(
            onPressed: form.saving
                ? null
                : () async {
                    final id = await notifier.save(repo);
                    if (id != null && context.mounted) {
                      HapticFeedback.mediumImpact();
                      context.pushReplacement(AppRoutes.coach, extra: id);
                    }
                  },
            child: form.saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save & Talk to CuraCoach'),
          ),
          const SizedBox(height: AppTokens.space16),
        ],
      ),
    );
  }
}

class _ScaleRow extends StatelessWidget {
  final String label;
  final List<String> emojis;
  final int value; // 1..5
  final ValueChanged<int> onChanged;

  const _ScaleRow({
    required this.label,
    required this.emojis,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppTokens.space8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (i) {
            final v = i + 1;
            final selected = value == v;
            return Semantics(
              button: true,
              label: '$label level $v',
              selected: selected,
              child: GestureDetector(
                onTap: () => onChanged(v),
                child: AnimatedContainer(
                  duration: AppTokens.durationFast,
                  width: AppTokens.minTouchTarget,
                  height: AppTokens.minTouchTarget,
                  decoration: BoxDecoration(
                    color: selected ? cs.primaryContainer : cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppTokens.radiusM),
                    border: selected
                        ? Border.all(color: cs.primary, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      emojis[i],
                      style: TextStyle(fontSize: selected ? 26 : 22),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
