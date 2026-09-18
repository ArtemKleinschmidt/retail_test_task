import 'package:flutter/foundation.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_page_section.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_page_section_key.dart';
import 'package:retail_test_task/features/payment/presentation/widgets/payment_page_sections.dart';
import 'package:retail_test_task/flavors/retail/retail_promo_banner.dart';
import 'package:retail_test_task/flavors/retail/retail_security_error.dart';
import 'package:retail_test_task/flavors/utility/utility_bill_breakdown.dart';
import 'package:retail_test_task/flavors/utility/utility_security_error.dart';

@immutable
final class PaymentPageSectionMapper {
  const PaymentPageSectionMapper();

  List<PaymentPageSection> mapAll(
    Iterable<PaymentPageSectionKey> keys, {
    required VoidCallback onPaymentAction,
  }) {
    return [for (final key in keys) _map(key, onPaymentAction)];
  }

  PaymentPageSection _map(
    PaymentPageSectionKey key,
    VoidCallback onPaymentAction,
  ) {
    return switch (key) {
      PaymentPageSectionKey.heading => const PaymentPageHeadingSection(),
      PaymentPageSectionKey.paymentSummary => const PaymentSummarySection(),
      PaymentPageSectionKey.securityOverview =>
        const PaymentSecurityOverviewSection(),
      PaymentPageSectionKey.processingProgress =>
        const PaymentProgressSection(),
      PaymentPageSectionKey.resultFeedback => const PaymentResultSection(),
      PaymentPageSectionKey.paymentAction => PaymentActionSection(
        onPressed: onPaymentAction,
      ),
      PaymentPageSectionKey.retailPromoBanner => const RetailPromoBanner(),
      PaymentPageSectionKey.retailSecurityError => const RetailSecurityError(),
      PaymentPageSectionKey.utilityBillBreakdown =>
        const UtilityBillBreakdown(),
      PaymentPageSectionKey.utilitySecurityError =>
        const UtilitySecurityError(),
    };
  }
}
