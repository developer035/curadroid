import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/tokens.dart';

class CrisisScreen extends StatelessWidget {
  const CrisisScreen({super.key});

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open $urlString')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening link: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crisis Support'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Calm banner
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: cs.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: cs.error.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shield_outlined, color: cs.error, size: 28),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'You Are Not Alone',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'If you are feeling overwhelmed, having thoughts of harming yourself, or in an immediate crisis, free and confidential support is available right now.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 988 Lifeline
            Text(
              'Immediate 24/7 Helplines',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: cs.outlineVariant),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: cs.primaryContainer,
                          child: Icon(Icons.support_agent, color: cs.onPrimaryContainer),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '988 Suicide & Crisis Lifeline',
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Free, confidential, 24/7 in the US & Canada',
                                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _launchUrl(context, 'tel:988'),
                            icon: const Icon(Icons.phone),
                            label: const Text('Call 988'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _launchUrl(context, 'sms:988'),
                            icon: const Icon(Icons.message_outlined),
                            label: const Text('Text 988'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Crisis Text Line
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: cs.outlineVariant),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: cs.secondaryContainer,
                  child: Icon(Icons.chat_bubble_outline, color: cs.onSecondaryContainer),
                ),
                title: const Text('Crisis Text Line', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Text HOME to 741741 to connect with a crisis counselor'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _launchUrl(context, 'sms:741741?body=HOME'),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // International resources
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: cs.outlineVariant),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: cs.surfaceContainerHighest,
                  child: Icon(Icons.language, color: cs.onSurface),
                ),
                title: const Text('International Resources', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Find emergency support outside the United States'),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => _launchUrl(context, 'https://findahelpline.com'),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Grounding exercise shortcut
            Text(
              'Grounding Right Now',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Card(
              color: cs.primaryContainer.withValues(alpha: 0.4),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: ListTile(
                leading: const Icon(Icons.spa_outlined),
                title: const Text('5-4-3-2-1 Sensory Grounding', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Anchor your mind using your five physical senses'),
                trailing: const Icon(Icons.play_arrow),
                onTap: () {
                  context.push('${AppRoutes.exercise}/grounding_54321');
                },
              ),
            ),

            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text(
                'In immediate physical danger, please dial 911 or visit the nearest emergency room.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
