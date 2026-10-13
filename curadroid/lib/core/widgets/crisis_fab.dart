import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';
import '../theme/tokens.dart';

/// Persistent "Need help now?" entry point, present on every screen.
class CrisisFab extends StatelessWidget {
  const CrisisFab({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Need help now — open crisis resources',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(AppRoutes.crisis),
          borderRadius: BorderRadius.circular(AppTokens.radiusFull),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.space16,
              vertical: AppTokens.space8,
            ),
            decoration: BoxDecoration(
              color: cs.errorContainer,
              borderRadius: BorderRadius.circular(AppTokens.radiusFull),
              border: Border.all(color: cs.error.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite_border, size: 16, color: cs.error),
                const SizedBox(width: AppTokens.space4),
                Text(
                  'Need help now?',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: cs.onErrorContainer,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
