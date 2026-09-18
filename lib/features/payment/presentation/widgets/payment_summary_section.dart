import 'package:flutter/material.dart';
import 'package:retail_test_task/core/tenant/tenant_design_tokens.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_page_section.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_page_section_key.dart';

class PaymentSummarySection extends PaymentPageSection {
  const PaymentSummarySection({super.key});

  static const sectionKey = PaymentPageSectionKey.paymentSummary;

  @override
  Widget build(BuildContext context) {
    final summary = PaymentPageSectionScope.of(context).state.summary;
    final theme = Theme.of(context);
    final tokens = theme.extension<TenantDesignTokens>()!;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(tokens.sectionSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Paying', style: theme.textTheme.labelLarge),
            SizedBox(height: tokens.itemSpacing),
            Text(summary.payeeName, style: theme.textTheme.titleLarge),
            SizedBox(height: tokens.itemSpacing),
            Text(
              summary.formattedTotal,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: tokens.accent,
              ),
            ),
            SizedBox(height: tokens.itemSpacing),
            Text('Reference ${summary.reference}'),
          ],
        ),
      ),
    );
  }
}
