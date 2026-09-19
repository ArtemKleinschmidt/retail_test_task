import 'package:flutter/material.dart';
import 'package:retail_test_task/core/tenant/tenant_design_tokens.dart';
import 'package:retail_test_task/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_page_section.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_page_section_key.dart';

class PaymentResultSection extends PaymentPageSection {
  const PaymentResultSection({super.key});

  static const sectionKey = PaymentPageSectionKey.resultFeedback;

  @override
  bool isVisible(PaymentContentState state) => state.feedback != null;

  @override
  Widget build(BuildContext context) {
    final state = PaymentPageSectionScope.of(context).state;
    final feedback = state.feedback!;
    final theme = Theme.of(context);
    final tokens = theme.extension<TenantDesignTokens>()!;
    final isCompleted = state is PaymentCompleted;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: feedback.isPositive
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(tokens.cardRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          isCompleted ? tokens.itemSpacing : tokens.sectionSpacing,
        ),
        child: Row(
          crossAxisAlignment: isCompleted
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            Icon(
              feedback.isPositive
                  ? Icons.check_circle_outline
                  : Icons.error_outline,
              size: isCompleted ? 20 : null,
            ),
            SizedBox(width: tokens.itemSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feedback.title,
                    style: isCompleted
                        ? theme.textTheme.labelLarge
                        : theme.textTheme.titleMedium,
                  ),
                  SizedBox(height: isCompleted ? 2 : tokens.itemSpacing),
                  Text(
                    feedback.message,
                    style: isCompleted ? theme.textTheme.bodySmall : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
