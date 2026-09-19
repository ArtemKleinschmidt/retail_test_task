import 'package:flutter/material.dart';
import 'package:retail_test_task/core/tenant/tenant_design_tokens.dart';
import 'package:retail_test_task/features/payment/debug/payment_debug_scenario.dart';
import 'package:retail_test_task/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:retail_test_task/features/payment/presentation/pages/payment_page.dart';

typedef DebugPaymentBlocFactory = PaymentBloc Function(
  PaymentDebugScenario scenario,
);

class PaymentDebugPage extends StatefulWidget {
  const PaymentDebugPage({required this.createBloc, super.key});

  final DebugPaymentBlocFactory createBloc;

  @override
  State<PaymentDebugPage> createState() => _PaymentDebugPageState();
}

class _PaymentDebugPageState extends State<PaymentDebugPage> {
  PaymentDebugLoadBehavior _loadBehavior = PaymentDebugLoadBehavior.success;
  PaymentDebugSecurityBehavior _securityBehavior =
      PaymentDebugSecurityBehavior.clear;
  PaymentDebugProcessingBehavior _processingBehavior =
      PaymentDebugProcessingBehavior.success;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<TenantDesignTokens>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Payment scenarios')),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(tokens.screenPadding),
          children: [
            Text('Debug controls', style: theme.textTheme.headlineMedium),
            SizedBox(height: tokens.itemSpacing),
            Text(
              'Choose deterministic outcomes, then launch a fresh payment '
              'flow. These controls are available only in debug builds.',
              style: theme.textTheme.bodyLarge,
            ),
            SizedBox(height: tokens.sectionSpacing),
            _ScenarioGroup<PaymentDebugLoadBehavior>(
              title: 'Payment loading',
              values: PaymentDebugLoadBehavior.values,
              selected: _loadBehavior,
              labelFor: (value) => switch (value) {
                PaymentDebugLoadBehavior.success => 'Success',
                PaymentDebugLoadBehavior.failure => 'Failure',
              },
              onSelected: (value) => setState(() => _loadBehavior = value),
            ),
            SizedBox(height: tokens.sectionSpacing),
            _ScenarioGroup<PaymentDebugSecurityBehavior>(
              title: 'Security check',
              values: PaymentDebugSecurityBehavior.values,
              selected: _securityBehavior,
              labelFor: (value) => switch (value) {
                PaymentDebugSecurityBehavior.clear => 'Clear',
                PaymentDebugSecurityBehavior.unsupported => 'Unsupported',
                PaymentDebugSecurityBehavior.rooted => 'Rooted',
                PaymentDebugSecurityBehavior.screenRecording =>
                  'Screen recording',
                PaymentDebugSecurityBehavior.rootedAndRecording =>
                  'Both threats',
                PaymentDebugSecurityBehavior.failure => 'Check failure',
              },
              onSelected: (value) => setState(() => _securityBehavior = value),
            ),
            SizedBox(height: tokens.sectionSpacing),
            _ScenarioGroup<PaymentDebugProcessingBehavior>(
              title: 'Payment processing',
              values: PaymentDebugProcessingBehavior.values,
              selected: _processingBehavior,
              labelFor: (value) => switch (value) {
                PaymentDebugProcessingBehavior.success => 'Success',
                PaymentDebugProcessingBehavior.declined => 'Declined',
                PaymentDebugProcessingBehavior.startFailure => 'Start failure',
                PaymentDebugProcessingBehavior.streamFailure =>
                  'Progress failure',
              },
              onSelected: (value) =>
                  setState(() => _processingBehavior = value),
            ),
            SizedBox(height: tokens.sectionSpacing),
            FilledButton.icon(
              onPressed: _launchScenario,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Launch scenario'),
            ),
          ],
        ),
      ),
    );
  }

  void _launchScenario() {
    final scenario = PaymentDebugScenario(
      loadBehavior: _loadBehavior,
      securityBehavior: _securityBehavior,
      processingBehavior: _processingBehavior,
    );

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            PaymentFlow(createBloc: () => widget.createBloc(scenario)),
      ),
    );
  }
}

class _ScenarioGroup<T extends Enum> extends StatelessWidget {
  const _ScenarioGroup({
    required this.title,
    required this.values,
    required this.selected,
    required this.labelFor,
    required this.onSelected,
  });

  final String title;
  final List<T> values;
  final T selected;
  final String Function(T value) labelFor;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<TenantDesignTokens>()!;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(tokens.sectionSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            SizedBox(height: tokens.itemSpacing),
            Wrap(
              spacing: tokens.itemSpacing,
              runSpacing: tokens.itemSpacing,
              children: [
                for (final value in values)
                  ChoiceChip(
                    label: Text(labelFor(value)),
                    selected: selected == value,
                    onSelected: (_) => onSelected(value),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
