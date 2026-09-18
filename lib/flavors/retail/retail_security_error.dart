import 'package:flutter/material.dart';
import 'package:retail_test_task/core/tenant/tenant_design_tokens.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/view_data/security_error_view_data.dart';

class RetailSecurityError extends StatelessWidget {
  const RetailSecurityError({required this.data, super.key});

  final SecurityErrorViewData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<TenantDesignTokens>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.securityErrorBackground,
        borderRadius: BorderRadius.circular(tokens.cardRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.sectionSpacing),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: tokens.securityErrorForeground,
            ),
            SizedBox(width: tokens.itemSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.title, style: theme.textTheme.titleMedium),
                  SizedBox(height: tokens.itemSpacing),
                  Text(data.message),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
