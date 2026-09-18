import 'package:flutter/foundation.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_page_section.dart';

@immutable
final class PaymentTenantComponents {
  PaymentTenantComponents({required Iterable<PaymentPageSection> sections})
    : sections = List.unmodifiable(sections);

  final List<PaymentPageSection> sections;
}
