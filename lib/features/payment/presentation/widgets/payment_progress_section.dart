import 'package:flutter/material.dart';
import 'package:retail_test_task/core/tenant/tenant_design_tokens.dart';
import 'package:retail_test_task/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_page_section.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_page_section_key.dart';

class PaymentProgressSection extends PaymentPageSection {
  const PaymentProgressSection({super.key});

  static const sectionKey = PaymentPageSectionKey.processingProgress;

  @override
  bool isVisible(PaymentContentState state) {
    return state.processingPercentage != null;
  }

  @override
  Widget build(BuildContext context) {
    final percentage = PaymentPageSectionScope.of(context)
        .state
        .processingPercentage!;
    final theme = Theme.of(context);
    final tokens = theme.extension<TenantDesignTokens>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Processing payment',
                style: theme.textTheme.titleMedium,
              ),
            ),
            Text('$percentage%'),
          ],
        ),
        SizedBox(height: tokens.itemSpacing),
        LinearProgressIndicator(value: percentage / 100),
      ],
    );
  }
}
