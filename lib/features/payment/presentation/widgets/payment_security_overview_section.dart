import 'package:flutter/material.dart';
import 'package:retail_test_task/core/tenant/tenant_design_tokens.dart';
import 'package:retail_test_task/features/payment/domain/entities/security_status.dart';
import 'package:retail_test_task/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_page_section.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_page_section_key.dart';
import 'package:retail_test_task/features/payment/presentation/widgets/security_radar_sweep.dart';

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
                      AnimatedSwitcher(
                        duration: tokens.shortDuration,
                        switchInCurve: tokens.motionCurve,
                        switchOutCurve: tokens.motionCurve,
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        layoutBuilder: (currentChild, previousChildren) {
                          return Stack(
                            alignment: Alignment.centerLeft,
                            children: [...previousChildren, ?currentChild],
                          );
                        },
                        child: Text(
                          state.isCheckingSecurity
                              ? 'Security scan in progress'
                              : 'Security scan',
                          key: ValueKey(state.isCheckingSecurity),
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      const Text(
                        'Device safeguards are evaluated before payment.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.sectionSpacing),
            SecurityRadarSweep(mode: _radarModeFor(state)),
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

SecurityRadarMode _radarModeFor(PaymentContentState state) {
  return switch (state) {
    PaymentCheckingSecurity() => SecurityRadarMode.scanning,
    PaymentReady() || PaymentProcessing() => SecurityRadarMode.monitoring,
    PaymentConfirmationBlocked() ||
    PaymentSecurityCheckFailed() => SecurityRadarMode.blocked,
    PaymentCompleted(securityStatus: final status?)
        when status.root == SecuritySignalState.detected ||
            status.screenRecording == SecuritySignalState.detected =>
      SecurityRadarMode.blocked,
    PaymentCompleted() => SecurityRadarMode.resolved,
    PaymentProcessingFailed() => SecurityRadarMode.unavailable,
  };
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
        Colors.green.shade700,
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
        backgroundColor: Color.alphaBlend(
          tokens.accentContainer.withAlpha(120),
          theme.colorScheme.surfaceContainerLow,
        ),
        side: BorderSide(color: tokens.accent.withAlpha(56)),
      ),
    );
  }
}
