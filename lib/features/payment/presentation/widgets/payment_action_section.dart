import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:retail_test_task/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_page_section.dart';

class PaymentActionSection extends PaymentPageSection {
  const PaymentActionSection({super.key});

  @override
  bool isVisible(PaymentContentState state) => state.primaryAction != null;

  @override
  Widget build(BuildContext context) {
    final action = PaymentPageSectionScope.of(context).state.primaryAction!;
    final event = switch (action.intent) {
      PaymentActionIntent.confirm => const PaymentConfirmationRequested(),
      PaymentActionIntent.reload => const PaymentLoadRequested(),
      PaymentActionIntent.none => null,
    };

    return FilledButton(
      onPressed: event == null
          ? null
          : () => context.read<PaymentBloc>().add(event),
      child: Text(action.label),
    );
  }
}
