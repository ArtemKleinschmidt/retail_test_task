import 'package:flutter/material.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_page_section.dart';

class PaymentPageHeadingSection extends PaymentPageSection {
  const PaymentPageHeadingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Confirm payment',
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}
