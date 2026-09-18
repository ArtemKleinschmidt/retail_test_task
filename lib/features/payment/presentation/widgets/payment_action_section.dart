import 'package:flutter/material.dart';
import 'package:retail_test_task/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_page_section.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_page_section_key.dart';

class PaymentActionSection extends PaymentPageSection {
  const PaymentActionSection({required this.onPressed, super.key});

  static const sectionKey = PaymentPageSectionKey.paymentAction;

  final VoidCallback onPressed;

  @override
  bool isVisible(PaymentContentState state) => state.primaryAction != null;

  @override
  Widget build(BuildContext context) {
    final action = PaymentPageSectionScope.of(context).state.primaryAction!;

    return FilledButton(
      onPressed: action.isEnabled ? onPressed : null,
      child: Text(action.label),
    );
  }
}
