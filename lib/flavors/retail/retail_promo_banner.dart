import 'package:flutter/material.dart';
import 'package:retail_test_task/core/tenant/tenant_design_tokens.dart';

class RetailPromoBanner extends StatelessWidget {
  const RetailPromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<TenantDesignTokens>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.accentContainer,
        borderRadius: BorderRadius.circular(tokens.cardRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.sectionSpacing),
        child: Row(
          children: [
            Icon(Icons.local_offer_rounded, color: tokens.accent),
            SizedBox(width: tokens.itemSpacing),
            const Expanded(
              child: Text('Payment confirmed today earns bonus rewards.'),
            ),
          ],
        ),
      ),
    );
  }
}
