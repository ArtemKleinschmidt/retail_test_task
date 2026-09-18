import 'package:flutter/material.dart';
import 'package:retail_test_task/core/tenant/tenant_design_tokens.dart';
import 'package:retail_test_task/features/payment/domain/entities/security_status.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_page_section.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_page_section_key.dart';

class PaymentSecurityOverviewSection extends PaymentPageSection {
  const PaymentSecurityOverviewSection({super.key});

  static const sectionKey = PaymentPageSectionKey.securityOverview;

  @override
  Widget build(BuildContext context) {
    final state = PaymentPageSectionScope.of(context).state;
    final theme = Theme.of(context);
    final tokens = theme.extension<TenantDesignTokens>()!;
    final status = state.visibleSecurityStatus;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(tokens.sectionSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: tokens.accentContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(tokens.itemSpacing),
                    child: Icon(Icons.shield_outlined, color: tokens.accent),
                  ),
                ),
                SizedBox(width: tokens.itemSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Security scan', style: theme.textTheme.titleMedium),
                      Text(
                        state.isCheckingSecurity
                            ? 'Checking the payment environment…'
                            : 'Device safeguards are evaluated before payment.',
                      ),
                    ],
                  ),
                ),
                if (state.isCheckingSecurity)
                  const SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            if (status != null) ...[
              SizedBox(height: tokens.sectionSpacing),
              Wrap(
                spacing: tokens.itemSpacing,
                runSpacing: tokens.itemSpacing,
                children: [
                  _SecuritySignal(label: 'Root access', state: status.root),
                  _SecuritySignal(
                    label: 'Screen recording',
                    state: status.screenRecording,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SecuritySignal extends StatelessWidget {
  const _SecuritySignal({required this.label, required this.state});

  final String label;
  final SecuritySignalState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<TenantDesignTokens>()!;
    final (icon, value, color) = switch (state) {
      SecuritySignalState.clear => (
        Icons.check_circle_outline,
        'Clear',
        theme.colorScheme.primary,
      ),
      SecuritySignalState.detected => (
        Icons.error_outline,
        'Detected',
        tokens.securityErrorForeground,
      ),
      SecuritySignalState.unsupported => (
        Icons.help_outline,
        'Unavailable',
        theme.colorScheme.secondary,
      ),
    };

    return Semantics(
      label: '$label: $value',
      child: Chip(
        avatar: Icon(icon, size: 18, color: color),
        label: Text('$label · $value'),
      ),
    );
  }
}
