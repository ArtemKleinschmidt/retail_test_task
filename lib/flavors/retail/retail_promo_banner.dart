import 'package:flutter/material.dart';
import 'package:retail_test_task/core/tenant/tenant_design_tokens.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_page_section.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_page_section_key.dart';

class RetailPromoBanner extends PaymentPageSection {
  const RetailPromoBanner({super.key});

  static const sectionKey = PaymentPageSectionKey.retailPromoBanner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = Theme.of(context).extension<TenantDesignTokens>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.accentContainer,
        borderRadius: BorderRadius.circular(tokens.cardRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.sectionSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Promo Banner', style: theme.textTheme.titleMedium),
            SizedBox(height: tokens.itemSpacing),
            Row(
              children: [
                Icon(Icons.local_offer_rounded, color: tokens.accent),
                SizedBox(width: tokens.itemSpacing),
                const Expanded(
                  child: Text('Payment confirmed today earns bonus rewards.'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
