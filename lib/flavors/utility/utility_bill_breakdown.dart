import 'package:flutter/material.dart';
import 'package:retail_test_task/core/tenant/tenant_design_tokens.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_page_section.dart';

class UtilityBillBreakdown extends PaymentPageSection {
  const UtilityBillBreakdown({super.key});

  @override
  Widget build(BuildContext context) {
    final data = PaymentPageSectionScope.of(context).state.supplement;
    final theme = Theme.of(context);
    final tokens = theme.extension<TenantDesignTokens>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(tokens.cardRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.sectionSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bill Breakdown', style: theme.textTheme.titleMedium),
            SizedBox(height: tokens.itemSpacing),
            for (final item in data.billItems)
              SizedBox(
                height: tokens.dataRowHeight,
                child: Row(
                  children: [
                    Expanded(child: Text(item.label)),
                    Text(
                      item.formattedAmount,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(),
            Row(
              children: [
                const Expanded(child: Text('Total')),
                Text(data.formattedTotal, style: theme.textTheme.titleMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
