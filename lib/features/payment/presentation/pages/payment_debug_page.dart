import 'package:flutter/material.dart';
import 'package:retail_test_task/core/tenant/tenant_design_tokens.dart';
import 'package:retail_test_task/features/payment/data/repositories/simulated_payment_repository.dart';
import 'package:retail_test_task/features/payment/data/repositories/simulated_security_repository.dart';
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
  SimulatedPaymentLoadBehavior _loadBehavior =
      SimulatedPaymentLoadBehavior.success;
  SimulatedSecurityBehavior _securityBehavior = SimulatedSecurityBehavior.clear;
  SimulatedPaymentProcessingBehavior _processingBehavior =
      SimulatedPaymentProcessingBehavior.success;

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
            _ScenarioGroup<SimulatedPaymentLoadBehavior>(
              title: 'Payment loading',
              values: SimulatedPaymentLoadBehavior.values,
              selected: _loadBehavior,
              labelFor: (value) => switch (value) {
                SimulatedPaymentLoadBehavior.success => 'Success',
                SimulatedPaymentLoadBehavior.failure => 'Failure',
              },
              onSelected: (value) => setState(() => _loadBehavior = value),
            ),
            SizedBox(height: tokens.sectionSpacing),
            _ScenarioGroup<SimulatedSecurityBehavior>(
              title: 'Security check',
              values: SimulatedSecurityBehavior.values,
              selected: _securityBehavior,
              labelFor: (value) => switch (value) {
                SimulatedSecurityBehavior.clear => 'Clear',
                SimulatedSecurityBehavior.unsupported => 'Unsupported',
                SimulatedSecurityBehavior.rooted => 'Rooted',
                SimulatedSecurityBehavior.screenRecording => 'Screen recording',
                SimulatedSecurityBehavior.rootedAndRecording => 'Both threats',
                SimulatedSecurityBehavior.failure => 'Check failure',
              },
              onSelected: (value) => setState(() => _securityBehavior = value),
            ),
            SizedBox(height: tokens.sectionSpacing),
            _ScenarioGroup<SimulatedPaymentProcessingBehavior>(
              title: 'Payment processing',
              values: SimulatedPaymentProcessingBehavior.values,
              selected: _processingBehavior,
              labelFor: (value) => switch (value) {
                SimulatedPaymentProcessingBehavior.success => 'Success',
                SimulatedPaymentProcessingBehavior.declined => 'Declined',
                SimulatedPaymentProcessingBehavior.startFailure =>
                  'Start failure',
                SimulatedPaymentProcessingBehavior.streamFailure =>
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
